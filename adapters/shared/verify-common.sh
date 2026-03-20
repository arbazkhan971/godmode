#!/usr/bin/env bash
# Godmode — Shared verification helpers
# Sourced by each platform's verify.sh
# Provides: color codes, check functions, skill/agent counting, summary

# ---------------------------------------------------------------------------
# Color codes (disabled if stdout is not a terminal)
# ---------------------------------------------------------------------------

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BOLD=''
    RESET=''
fi

# Counters
CHECKS_TOTAL=0
CHECKS_PASSED=0
FAILURES=""

# ---------------------------------------------------------------------------
# check_pass / check_fail — record a result and print it
# ---------------------------------------------------------------------------

check_pass() {
    local label="$1"
    local detail="${2:-}"
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    if [ -n "$detail" ]; then
        printf "${GREEN}  ✓ %s${RESET} — %s\n" "$label" "$detail"
    else
        printf "${GREEN}  ✓ %s${RESET}\n" "$label"
    fi
}

check_fail() {
    local label="$1"
    local detail="${2:-}"
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    FAILURES="${FAILURES}  - ${label}: ${detail}\n"
    if [ -n "$detail" ]; then
        printf "${RED}  ✗ %s${RESET} — %s\n" "$label" "$detail"
    else
        printf "${RED}  ✗ %s${RESET}\n" "$label"
    fi
}

# ---------------------------------------------------------------------------
# verify_file_exists — check that a file exists and is readable
# ---------------------------------------------------------------------------

verify_file_exists() {
    local path="$1"
    local label="${2:-$(basename "$path")}"
    if [ -r "$path" ]; then
        check_pass "$label" "$path"
        return 0
    else
        check_fail "$label" "not found or not readable: $path"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# verify_symlink — check that a symlink exists and its target is valid
# ---------------------------------------------------------------------------

verify_symlink() {
    local path="$1"
    local label="${2:-$(basename "$path")}"
    if [ -L "$path" ]; then
        local target
        target="$(readlink "$path")"
        if [ -e "$path" ]; then
            check_pass "$label" "symlink -> $target"
            return 0
        else
            check_fail "$label" "broken symlink -> $target"
            return 1
        fi
    elif [ -e "$path" ]; then
        # Exists but not a symlink — still valid for verification purposes
        check_pass "$label" "exists (not a symlink)"
        return 0
    else
        check_fail "$label" "not found: $path"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# verify_dir_exists — check that a directory exists and is accessible
# ---------------------------------------------------------------------------

verify_dir_exists() {
    local path="$1"
    local label="${2:-$(basename "$path")}"
    if [ -d "$path" ] && [ -r "$path" ]; then
        check_pass "$label" "$path"
        return 0
    else
        check_fail "$label" "directory not found or not readable: $path"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# count_skills — count skill directories under a given skills/ path
# Returns the count; also validates each has SKILL.md
# ---------------------------------------------------------------------------

count_skills() {
    local skills_dir="$1"
    local expected="${2:-126}"
    local count=0
    local missing_md=0

    if [ ! -d "$skills_dir" ]; then
        check_fail "Skills accessible" "skills directory not found: $skills_dir"
        return 1
    fi

    for skill in "$skills_dir"/*/; do
        [ -d "$skill" ] || continue
        count=$((count + 1))
        if [ ! -f "$skill/SKILL.md" ]; then
            missing_md=$((missing_md + 1))
        fi
    done

    if [ "$count" -ge "$expected" ]; then
        if [ "$missing_md" -eq 0 ]; then
            check_pass "Skills count" "$count skills found (expected >= $expected), all have SKILL.md"
        else
            check_pass "Skills count" "$count skills found (expected >= $expected), $missing_md missing SKILL.md"
        fi
        return 0
    else
        check_fail "Skills count" "found $count skills, expected >= $expected in $skills_dir"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# count_agents — count agent definition files under a given agents/ path
# ---------------------------------------------------------------------------

count_agents() {
    local agents_dir="$1"
    local pattern="${2:-*.md}"
    local expected="${3:-7}"
    local label="${4:-Agents count}"

    if [ ! -d "$agents_dir" ]; then
        check_fail "$label" "agents directory not found: $agents_dir"
        return 1
    fi

    local count
    count=$(ls "$agents_dir"/$pattern 2>/dev/null | wc -l | tr -d ' ')

    if [ "$count" -ge "$expected" ]; then
        check_pass "$label" "$count agent definitions found (expected >= $expected)"
        return 0
    else
        check_fail "$label" "found $count agent definitions, expected >= $expected in $agents_dir"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# validate_yaml_basic — minimal YAML validation (checks non-empty, has key: value lines)
# ---------------------------------------------------------------------------

validate_yaml_basic() {
    local file="$1"
    local label="${2:-Config YAML valid}"

    if [ ! -f "$file" ]; then
        check_fail "$label" "file not found: $file"
        return 1
    fi

    if [ ! -s "$file" ]; then
        check_fail "$label" "file is empty: $file"
        return 1
    fi

    # Check that there is at least one non-comment, non-blank line with a colon
    local content_lines
    content_lines=$(grep -v '^\s*#' "$file" | grep -v '^\s*$' | grep -c ':' 2>/dev/null || echo "0")
    if [ "$content_lines" -ge 1 ]; then
        check_pass "$label" "$file ($content_lines key-value lines)"
        return 0
    else
        check_fail "$label" "no key: value lines found in $file"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# validate_json_basic — minimal JSON validation (checks non-empty, valid structure)
# ---------------------------------------------------------------------------

validate_json_basic() {
    local file="$1"
    local label="${2:-Config JSON valid}"

    if [ ! -f "$file" ]; then
        check_fail "$label" "file not found: $file"
        return 1
    fi

    if [ ! -s "$file" ]; then
        check_fail "$label" "file is empty: $file"
        return 1
    fi

    # Try python3 json validation, fall back to basic check
    if command -v python3 &>/dev/null; then
        if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
            check_pass "$label" "$file (valid JSON)"
            return 0
        else
            check_fail "$label" "invalid JSON in $file"
            return 1
        fi
    else
        # Fallback: check starts with { or [
        local first_char
        first_char=$(head -c 1 "$file" | tr -d '[:space:]')
        if [ "$first_char" = "{" ] || [ "$first_char" = "[" ]; then
            check_pass "$label" "$file (basic structure check, python3 not available)"
            return 0
        else
            check_fail "$label" "does not look like JSON: $file"
            return 1
        fi
    fi
}

# ---------------------------------------------------------------------------
# validate_toml_basic — minimal TOML validation (checks non-empty, has key = value or [section])
# ---------------------------------------------------------------------------

validate_toml_basic() {
    local file="$1"
    local label="${2:-Config TOML valid}"

    if [ ! -f "$file" ]; then
        check_fail "$label" "file not found: $file"
        return 1
    fi

    if [ ! -s "$file" ]; then
        check_fail "$label" "file is empty: $file"
        return 1
    fi

    # Check for TOML structure: [section] headers or key = value lines
    local structure_lines
    structure_lines=$(grep -v '^\s*#' "$file" | grep -v '^\s*$' | grep -cE '(\[.+\]|.+=)' 2>/dev/null || echo "0")
    if [ "$structure_lines" -ge 1 ]; then
        check_pass "$label" "$file ($structure_lines structure lines)"
        return 0
    else
        check_fail "$label" "no TOML structure found in $file"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# print_summary — final PASS/FAIL summary
# ---------------------------------------------------------------------------

print_summary() {
    local platform="${1:-Godmode}"
    echo ""
    local failed=$((CHECKS_TOTAL - CHECKS_PASSED))
    if [ "$failed" -eq 0 ]; then
        printf "${GREEN}${BOLD}Verification: %d/%d checks passed${RESET}\n" "$CHECKS_PASSED" "$CHECKS_TOTAL"
        echo ""
        printf "${GREEN}${BOLD}%s installation verified successfully.${RESET}\n" "$platform"
        return 0
    else
        printf "${RED}${BOLD}Verification: %d/%d checks passed (%d FAILED)${RESET}\n" "$CHECKS_PASSED" "$CHECKS_TOTAL" "$failed"
        echo ""
        printf "${RED}Failures:${RESET}\n"
        printf "$FAILURES"
        echo ""
        printf "${RED}${BOLD}%s installation has issues. Re-run the installer or check paths above.${RESET}\n" "$platform"
        return 1
    fi
}
