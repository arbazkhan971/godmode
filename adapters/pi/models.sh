#!/usr/bin/env bash
# Godmode — multi-model routing reference implementation (pi adapter)
# Usage: bash adapters/pi/models.sh <resolve|doctor|selftest> [args]
#
# Resolution order per role (zero-config default: session model):
#   1. GODMODE_MODEL_<ROLE> env var. Role -> env name: uppercase with '.',
#      '_' and '-' all mapped to '_' (tr '[:lower:]._-' '[:upper:]___').
#      Set-but-empty is NOT an override (fall through). Case-folded roles
#      (Plan/plan) collapse to one env var by design — not special-cased.
#   2. godmode.models.json at the current project root (git toplevel of
#      the cwd, else the cwd itself), then ~/.config/godmode/models.json;
#      per-role merge — the project file wins per key.
#   3. session model.
#
# A model value is valid iff it fully matches ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$
# or is the literal "session". An invalid value at ANY layer prints one
# stderr warning and is treated as absent (fall through to the next layer).
# Values are pasted into dispatch text, never shell-eval'd; validation is
# defense in depth.
#
# "Project root" means the user's current project (cwd-based), NOT this repo.

set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
MODELS_SELF="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)/$(basename "$SCRIPT_PATH")"

MODELS_WARNED_PY=0
MODELS_WARNED_JSON="|"
MODELS_ROOT=""

usage() {
    cat >&2 <<'USAGE'
Usage: bash adapters/pi/models.sh <command> [args]

Commands:
  resolve <role>   Print "<model>\t<source>" for one role (env|file|session).
  doctor           TSV — one row per role: role, model, source, origin.
  selftest         Run the internal routing test suite (exit 0 pass / 1 fail).

Model resolution order per role:
  GODMODE_MODEL_<ROLE> env (role uppercased; '.', '_', '-' -> '_')
    -> godmode.models.json at the current project root
    -> ~/.config/godmode/models.json
    -> session model

"Project root" is the user's current project (cwd-based), not the godmode
repo. Missing config is the valid zero-config default: every role inherits
the session model.
USAGE
}

models_warn_invalid() {
    printf '[models] warning: ignoring invalid model value for role %s\n' "$1" >&2
}

# One "invalid JSON" warning per file path per process (doctor re-reads).
models_warn_bad_json() {
    case "$MODELS_WARNED_JSON" in
        *"|$1|"*) return 0 ;;
    esac
    MODELS_WARNED_JSON="$MODELS_WARNED_JSON$1|"
    printf '[models] warning: %s is invalid JSON — ignoring\n' "$1" >&2
}

models_valid_value() {
    case "$1" in
        session) return 0 ;;
    esac
    printf '%s' "$1" | grep -qE '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$'
}

models_env_name() {
    printf 'GODMODE_MODEL_%s' "$(printf '%s' "$1" | tr '[:lower:]._-' '[:upper:]___')"
}

models_project_root() {
    if [ -z "$MODELS_ROOT" ]; then
        MODELS_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD")"
    fi
    printf '%s' "$MODELS_ROOT"
}

# read_models_json <file> [<role>]
#   with <role>:  print the role's string value; exit 4 if absent
#   without:      print "role<TAB>value" per string value
#   exit 3 = file unusable (missing, unreadable, or malformed JSON)
read_models_json() {
    python3 - "$@" <<'PYEOF'
import json
import sys

try:
    with open(sys.argv[1], encoding="utf-8-sig") as fh:
        data = json.load(fh)
    roles = data.get("roles", {}) if isinstance(data, dict) else {}
    if not isinstance(roles, dict):
        roles = {}
    if len(sys.argv) > 2:
        value = roles.get(sys.argv[2])
        if isinstance(value, str) and value != "":
            print(value)
            sys.exit(0)
        sys.exit(4)
    for key, value in roles.items():
        if isinstance(value, str) and value != "":
            print("%s\t%s" % (key, value))
    sys.exit(0)
except Exception:
    sys.exit(3)
PYEOF
}

# File layer for one role. Sets FILE_VALUE / FILE_ORIGIN; rc 0 = value found
# (may still be invalid — validated by the caller), rc 1 = not found.
models_file_lookup() {
    FILE_VALUE=""
    FILE_ORIGIN=""
    local role="$1"
    local root
    local home_cfg
    local f
    local val
    local rc
    root="$(models_project_root)"
    home_cfg="${HOME:-}/.config/godmode/models.json"
    for f in "$root/godmode.models.json" "$home_cfg"; do
        if ! command -v python3 >/dev/null 2>&1; then
            if [ "$MODELS_WARNED_PY" -eq 0 ]; then
                printf '[models] warning: python3 not found — skipping godmode.models.json\n' >&2
                MODELS_WARNED_PY=1
            fi
            continue
        fi
        [ -f "$f" ] || continue
        if val="$(read_models_json "$f" "$role")"; then
            FILE_VALUE="$val"
            if [ "$f" = "$root/godmode.models.json" ]; then
                FILE_ORIGIN="godmode.models.json (project)"
            else
                FILE_ORIGIN="~/.config/godmode/models.json"
            fi
            return 0
        else
            rc=$?
        fi
        if [ "$rc" -eq 3 ]; then
            models_warn_bad_json "$f"
        fi
        # rc 4 = role absent in this file — try the next layer.
    done
    return 1
}

# Full layered lookup for one role. Sets LOOKUP_MODEL / LOOKUP_SOURCE /
# LOOKUP_ORIGIN. Always returns 0 (session fallback is a successful resolve).
models_lookup() {
    LOOKUP_MODEL="session"
    LOOKUP_SOURCE="session"
    LOOKUP_ORIGIN="-"
    local role="$1"
    local env_name
    local env_val
    env_name="$(models_env_name "$role")"
    env_val="$(printenv "$env_name" 2>/dev/null || true)"
    if [ -n "$env_val" ]; then
        if models_valid_value "$env_val"; then
            LOOKUP_MODEL="$env_val"
            LOOKUP_SOURCE="env"
            LOOKUP_ORIGIN="$env_name"
            return 0
        fi
        models_warn_invalid "$role"
    fi
    if models_file_lookup "$role"; then
        if models_valid_value "$FILE_VALUE"; then
            LOOKUP_MODEL="$FILE_VALUE"
            LOOKUP_SOURCE="file"
            LOOKUP_ORIGIN="$FILE_ORIGIN"
            return 0
        fi
        models_warn_invalid "$role"
    fi
    return 0
}

cmd_resolve() {
    if [ $# -ne 1 ]; then
        usage
        exit 2
    fi
    models_lookup "$1"
    printf '%s\t%s\n' "$LOOKUP_MODEL" "$LOOKUP_SOURCE"
}

ROLES=()
ROLE_SEEN="|"
role_add() {
    case "$ROLE_SEEN" in
        *"|$1|"*) return 0 ;;
    esac
    ROLE_SEEN="$ROLE_SEEN$1|"
    ROLES+=("$1")
}

# Roles discovered from GODMODE_MODEL_* env names (names only, never the
# values): strip the prefix, lowercase, '_' -> '-'.
models_env_roles() {
    local line
    local name
    local rest
    while IFS= read -r line; do
        case "$line" in
            GODMODE_MODEL_=*) ;;
            GODMODE_MODEL_*)
                name="${line%%=*}"
                rest="${name#GODMODE_MODEL_}"
                [ -n "$rest" ] || continue
                role_add "$(printf '%s' "$rest" | tr '[:upper:]_' '[:lower:]-')"
                ;;
        esac
    done < <(printenv | grep '^GODMODE_MODEL_' || true)
}

cmd_doctor() {
    local role
    local f
    local keys
    local rc
    local root
    local home_cfg
    local repo_path
    local home_path

    ROLES=()
    ROLE_SEEN="|"
    for role in plan build review optimize explore security test docs; do
        role_add "$role"
    done

    root="$(models_project_root)"
    home_cfg="${HOME:-}/.config/godmode/models.json"
    for f in "$root/godmode.models.json" "$home_cfg"; do
        if ! command -v python3 >/dev/null 2>&1; then
            if [ "$MODELS_WARNED_PY" -eq 0 ]; then
                printf '[models] warning: python3 not found — skipping godmode.models.json\n' >&2
                MODELS_WARNED_PY=1
            fi
            continue
        fi
        [ -f "$f" ] || continue
        # A malformed file is ignored entirely: its roles are simply absent.
        if keys="$(read_models_json "$f" | cut -f1)"; then
            while IFS= read -r role; do
                [ -n "$role" ] && role_add "$role"
            done <<<"$keys"
        else
            rc=$?
            if [ "$rc" -eq 3 ]; then
                models_warn_bad_json "$f"
            fi
        fi
    done
    models_env_roles

    printf 'role\tmodel\tsource\torigin\n'
    for role in "${ROLES[@]}"; do
        models_lookup "$role"
        printf '%s\t%s\t%s\t%s\n' "$role" "$LOOKUP_MODEL" "$LOOKUP_SOURCE" "$LOOKUP_ORIGIN"
    done

    repo_path="none"
    home_path="none"
    if [ -f "$root/godmode.models.json" ]; then
        repo_path="$root/godmode.models.json"
    fi
    if [ -f "$home_cfg" ]; then
        home_path="$home_cfg"
    fi
    printf 'config\trepo=%s\thome=%s\n' "$repo_path" "$home_path"
    exit 0
}

cmd_selftest() {
    local home
    local repo
    local pass=0
    local fail=0

    sandbox="$(mktemp -d)"
    trap 'rm -rf "$sandbox"' EXIT
    home="$sandbox/home"
    repo="$sandbox/repo"
    mkdir -p "$home/.config/godmode" "$repo"
    git -C "$repo" init -q 2>/dev/null || true

    st_check() {
        if [ "$2" = "$3" ]; then
            printf 'PASS: %s\n' "$1"
            pass=$((pass + 1))
        else
            printf 'FAIL: %s — expected [%s] got [%s]\n' "$1" "$2" "$3" >&2
            fail=$((fail + 1))
        fi
    }

    # st_run [VAR=v ...] -- <models.sh args...>: sets ST_OUT / ST_RC / ST_ERR.
    st_run() {
        local pairs=()
        while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
            pairs+=("$1")
            shift
        done
        shift
        if ST_OUT="$(cd "$repo" && env -i PATH="$PATH" HOME="$home" \
            ${pairs[@]+"${pairs[@]}"} bash "$MODELS_SELF" "$@" \
            2>"$sandbox/err")"; then
            ST_RC=0
        else
            ST_RC=$?
        fi
        ST_ERR="$(cat "$sandbox/err" 2>/dev/null || true)"
    }

    st_rc_is() {
        if [ "$ST_RC" -eq "$2" ]; then
            printf 'PASS: %s\n' "$1"
            pass=$((pass + 1))
        else
            printf 'FAIL: %s — expected rc %s got %s\n' "$1" "$2" "$ST_RC" >&2
            fail=$((fail + 1))
        fi
    }

    st_err_has() {
        if printf '%s' "$ST_ERR" | grep -qF "$2"; then
            printf 'PASS: %s\n' "$1"
            pass=$((pass + 1))
        else
            printf 'FAIL: %s — stderr missing [%s]\n' "$1" "$2" >&2
            fail=$((fail + 1))
        fi
    }

    # 1. Zero-config: no env, no files -> session for every layer.
    st_run -- resolve build
    st_check "zero-config resolve" "$(printf 'session\tsession')" "$ST_OUT"
    st_rc_is "zero-config exit 0" 0

    # 2. Env wins over file.
    printf '{"roles":{"build":"t/file"}}' >"$repo/godmode.models.json"
    st_run GODMODE_MODEL_BUILD=t/env -- resolve build
    st_check "env wins over file" "$(printf 't/env\tenv')" "$ST_OUT"

    # 3. File layer.
    st_run -- resolve build
    st_check "file layer" "$(printf 't/file\tfile')" "$ST_OUT"

    # 4. Malformed file falls through to session, exit 0, one warning.
    printf '{"roles": {' >"$repo/godmode.models.json"
    st_run -- resolve build
    st_check "malformed falls through" "$(printf 'session\tsession')" "$ST_OUT"
    st_rc_is "malformed exit 0" 0
    st_err_has "malformed JSON warning" "is invalid JSON — ignoring"

    # 5. Invalid value falls through with a warning (never shell-eval'd).
    printf '{"roles":{"build":"x; rm -rf /"}}' >"$repo/godmode.models.json"
    st_run -- resolve build
    st_check "invalid value falls through" "$(printf 'session\tsession')" "$ST_OUT"
    st_err_has "invalid value warning" "ignoring invalid model value for role build"

    # 6. Dotted role: '.' maps to '_' in the env name (tr fix).
    rm -f "$repo/godmode.models.json"
    st_run GODMODE_MODEL_V2_REVIEW=t/env -- resolve v2.review
    st_check "dotted role env name" "$(printf 't/env\tenv')" "$ST_OUT"

    # 7. Set-but-empty env is not an override.
    printf '{"roles":{"build":"t/file"}}' >"$repo/godmode.models.json"
    st_run GODMODE_MODEL_BUILD= -- resolve build
    st_check "empty env ignored" "$(printf 't/file\tfile')" "$ST_OUT"

    # 8. Doctor with zero GODMODE_MODEL_* env: header, >= 8 rows, trailer,
    #    exit 0, no ANSI escapes.
    rm -f "$repo/godmode.models.json"
    st_run -- doctor
    st_rc_is "doctor zero-env exit 0" 0
    st_check "doctor header" "$(printf 'role\tmodel\tsource\torigin')" \
        "$(printf '%s\n' "$ST_OUT" | head -n1)"
    if [ "$(printf '%s\n' "$ST_OUT" | wc -l | tr -d ' ')" -ge 10 ]; then
        printf 'PASS: doctor rows >= 8 (header + rows + trailer)\n'
        pass=$((pass + 1))
    else
        printf 'FAIL: doctor produced fewer than 10 lines\n' >&2
        fail=$((fail + 1))
    fi
    if printf '%s\n' "$ST_OUT" | tail -n1 | grep -qE $'^config\trepo=.+\thome=.+'; then
        printf 'PASS: doctor config trailer\n'
        pass=$((pass + 1))
    else
        printf 'FAIL: doctor config trailer missing or malformed\n' >&2
        fail=$((fail + 1))
    fi
    if printf '%s' "$ST_OUT" | grep -qP '\033'; then
        printf 'FAIL: doctor output contains ANSI escapes\n' >&2
        fail=$((fail + 1))
    else
        printf 'PASS: doctor output has no ANSI escapes\n'
        pass=$((pass + 1))
    fi

    printf 'selftest: %d passed, %d failed\n' "$pass" "$fail"
    [ "$fail" -eq 0 ]
}

main() {
    if [ $# -lt 1 ]; then
        usage
        exit 2
    fi
    case "$1" in
        resolve) shift; cmd_resolve "$@" ;;
        doctor) shift; cmd_doctor "$@" ;;
        selftest) shift; cmd_selftest "$@" ;;
        -h|--help|*) usage; exit 2 ;;
    esac
}

main "$@"
