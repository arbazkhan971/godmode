#!/usr/bin/env bash
# =============================================================================
# validate-structure.sh — Structure Validation Script for Godmode Plugin
# =============================================================================
# Validates:
#   1. Required top-level directories and files exist
#   2. Skill directory conventions
#   3. No orphaned files (files outside expected locations)
#   4. All command files have correct format
#   5. No broken cross-references in docs
#   6. No harness-specific "claude" wording in skills (allowlist below)
#   7. godmode.models.json role values match provider/id (optional file; missing = valid)
#
# Usage: bash tests/validate-structure.sh
# Exit code: 0 = all pass, 1 = failures found
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SKILLS_DIR="$ROOT_DIR/skills"
COMMANDS_DIR="$ROOT_DIR/commands"
DOCS_DIR="$ROOT_DIR/docs"
AGENTS_DIR="$ROOT_DIR/agents"
HOOKS_DIR="$ROOT_DIR/hooks"
PLUGIN_DIR="$ROOT_DIR/.claude-plugin"

# Files exempt from the claude-wording check (justified factual mentions only).
# Justified: research/SKILL.md matches CLAUDE.md by filename (find -name) — functional reference to on-disk instruction files, not harness-specific wording.
CLAUDE_ALLOWLIST=(
  "skills/research/SKILL.md"
)

PASS=0
FAIL=0
WARN=0

pass() {
  PASS=$((PASS + 1))
  echo "  PASS: $1"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "  FAIL: $1"
}

warn() {
  WARN=$((WARN + 1))
  echo "  WARN: $1"
}

separator() {
  echo ""
  echo "=== $1 ==="
}

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 1: Required top-level directories exist
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 1: Required Directory Structure"

required_dirs=(
  "skills"
  "commands"
  "commands/godmode"
  "docs"
  "agents"
  "hooks"
  ".claude-plugin"
)

for dir in "${required_dirs[@]}"; do
  if [ -d "$ROOT_DIR/$dir" ]; then
    pass "Directory $dir/ exists"
  else
    fail "Required directory $dir/ is missing"
  fi
done

# Required top-level files
required_files=(
  "README.md"
  "LICENSE"
  "package.json"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  ".claude-plugin/marketplace.json"
)

for file in "${required_files[@]}"; do
  if [ -f "$ROOT_DIR/$file" ]; then
    pass "File $file exists"
  else
    fail "Required file $file is missing"
  fi
done

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 2: Skill directory conventions
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 2: Skill Directory Conventions"

while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"

  # Check naming convention: lowercase, alphanumeric, hyphens only
  if echo "$skill_name" | grep -qE '^[a-z][a-z0-9-]*$'; then
    pass "$skill_name — valid directory name"
  else
    fail "$skill_name — invalid directory name (must be lowercase alphanumeric with hyphens)"
  fi

  # Check for unexpected file types in skill directories
  while IFS= read -r file; do
    ext="${file##*.}"
    case "$ext" in
      md|json|yaml|yml|txt)
        # Expected file types
        ;;
      *)
        warn "$skill_name/ contains unexpected file type: $(basename "$file") (.$ext)"
        ;;
    esac
  done < <(find "$skill_dir" -type f 2>/dev/null)

  # Check subdirectory conventions (only references/ and templates/ expected)
  while IFS= read -r subdir; do
    subdir_name="$(basename "$subdir")"
    case "$subdir_name" in
      references|templates)
        pass "$skill_name/$subdir_name/ — valid subdirectory"
        ;;
      *)
        warn "$skill_name/$subdir_name/ — unexpected subdirectory (expected: references/, templates/)"
        ;;
    esac
  done < <(find "$skill_dir" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 3: Orphaned files detection
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 3: Orphaned Files Detection"

# Check for files in the root that shouldn't be there
while IFS= read -r file; do
  filename="$(basename "$file")"
  case "$filename" in
    README.md|LICENSE|CHANGELOG.md|CONTRIBUTING.md|package.json|package-lock.json|.gitignore|.markdownlint.json|.markdownlintrc|icon.png|index.js|godmode.models.json)
      pass "Root file $filename — expected"
      ;;
    *.md|*.json|*.js|*.ts|*.yaml|*.yml)
      warn "Root file $filename — possibly orphaned (review if intentional)"
      ;;
    .DS_Store|Thumbs.db|*.swp|*.swo|*~)
      warn "Root file $filename — system/editor artifact (should be in .gitignore)"
      ;;
    *)
      : # skip dotfiles/directories handled elsewhere
      ;;
  esac
done < <(find "$ROOT_DIR" -maxdepth 1 -type f 2>/dev/null)

# Check for .md files in skills/ root (should be inside subdirectories)
while IFS= read -r file; do
  warn "Orphaned file in skills/ root: $(basename "$file") (should be in a skill subdirectory)"
done < <(find "$SKILLS_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null)

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 4: Command file format validation
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 4: Command File Format"

if [ -d "$COMMANDS_DIR/godmode" ]; then
  while IFS= read -r cmd_file; do
    cmd_name="$(basename "$cmd_file" .md)"

    # Check file is not empty
    if [ ! -s "$cmd_file" ]; then
      fail "Command $cmd_name.md — file is empty"
      continue
    fi

    # Check starts with markdown heading
    first_content_line="$(grep -m1 "^#" "$cmd_file" 2>/dev/null || true)"
    if [ -n "$first_content_line" ]; then
      pass "Command $cmd_name.md — has markdown heading"
    else
      fail "Command $cmd_name.md — missing markdown heading (should start with # /godmode:$cmd_name)"
    fi

    # Check for Usage section
    if grep -q "^## Usage" "$cmd_file" 2>/dev/null || grep -q "^## What It Does" "$cmd_file" 2>/dev/null; then
      pass "Command $cmd_name.md — has Usage or What It Does section"
    else
      warn "Command $cmd_name.md — missing '## Usage' or '## What It Does' section"
    fi

    # Check naming convention matches
    if echo "$cmd_name" | grep -qE '^[a-z][a-z0-9-]*$'; then
      pass "Command $cmd_name.md — valid filename"
    else
      fail "Command $cmd_name.md — invalid filename (must be lowercase alphanumeric with hyphens)"
    fi
  done < <(find "$COMMANDS_DIR/godmode" -name "*.md" -type f | sort)
fi

# Also check the root command file
if [ -f "$COMMANDS_DIR/godmode.md" ]; then
  if [ -s "$COMMANDS_DIR/godmode.md" ]; then
    pass "Root command godmode.md exists and is non-empty"
  else
    fail "Root command godmode.md is empty"
  fi
else
  fail "Root command godmode.md is missing"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 5: Broken cross-references in docs
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 5: Documentation Cross-References"

if [ -d "$DOCS_DIR" ]; then
  while IFS= read -r doc_file; do
    doc_name="$(basename "$doc_file")"

    # Find markdown links: [text](path)
    # Extract relative paths (not http/https links)
    while IFS= read -r link_path; do
      # Skip external links, anchors, and empty
      case "$link_path" in
        http://*|https://*|mailto:*|"#"*|"")
          continue
          ;;
      esac

      # Resolve relative to the doc file's directory
      doc_dir="$(dirname "$doc_file")"
      resolved_path="$doc_dir/$link_path"

      # Remove anchor fragments
      resolved_path="${resolved_path%%#*}"

      if [ -z "$resolved_path" ]; then
        continue
      fi

      if [ -e "$resolved_path" ]; then
        pass "$doc_name -> $link_path (valid)"
      else
        fail "$doc_name -> $link_path (BROKEN — file not found)"
      fi
    done < <(grep -o '\]([^)]*)' "$doc_file" 2>/dev/null | sed 's/\](//' | sed 's/)$//' || true)
  done < <(find "$DOCS_DIR" -name "*.md" -type f | sort)
else
  fail "Docs directory not found"
fi

# Also check references in README
if [ -f "$ROOT_DIR/README.md" ]; then
  while IFS= read -r link_path; do
    case "$link_path" in
      http://*|https://*|mailto:*|"#"*|"")
        continue
        ;;
    esac

    resolved_path="$ROOT_DIR/$link_path"
    resolved_path="${resolved_path%%#*}"

    if [ -z "$resolved_path" ]; then
      continue
    fi

    if [ -e "$resolved_path" ]; then
      pass "README.md -> $link_path (valid)"
    else
      fail "README.md -> $link_path (BROKEN — file not found)"
    fi
  done < <(grep -oP '\]\(\K[^)]+' "$ROOT_DIR/README.md" 2>/dev/null || true)
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 6: No "claude" wording in skills content
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 6: No Claude Wording in Skills"

is_allowlisted() {
  local rel="$1"
  local allowed
  for allowed in "${CLAUDE_ALLOWLIST[@]}"; do
    if [ "$rel" = "$allowed" ]; then
      return 0
    fi
  done
  return 1
}

claude_offenses=0
while IFS= read -r file; do
  rel_path="${file#"$ROOT_DIR"/}"
  if is_allowlisted "$rel_path"; then
    continue
  fi
  # Single grep capture: avoids a second grep whose exit 1 could trip
  # pipefail under set -e if matches vanished between the two greps.
  matches="$(grep -in "claude" "$file" 2>/dev/null || true)"
  if [ -n "$matches" ]; then
    claude_offenses=$((claude_offenses + 1))
    fail "$rel_path contains 'claude':"
    echo "$matches" | while IFS= read -r line; do
      echo "    $rel_path:$line"
    done
  fi
done < <(find "$SKILLS_DIR" -type f 2>/dev/null | sort)

if [ "$claude_offenses" -eq 0 ]; then
  pass "No 'claude' wording in skills (allowlist size: ${#CLAUDE_ALLOWLIST[@]})"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 7: godmode.models.json
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 7: godmode.models.json"

MODELS_JSON="$ROOT_DIR/godmode.models.json"

if [ ! -f "$MODELS_JSON" ]; then
  pass "godmode.models.json absent — zero-config default (valid)"
elif ! command -v python3 >/dev/null 2>&1; then
  warn "godmode.models.json present but python3 unavailable — format check skipped"
else
  if out="$(python3 - "$MODELS_JSON" 2>&1 <<'PYEOF'
import json
import re
import sys

try:
    with open(sys.argv[1], encoding="utf-8-sig") as f:
        data = json.load(f)
except ValueError as e:
    print("invalid JSON: %s" % e)
    sys.exit(1)

if not isinstance(data, dict):
    print("top level must be a JSON object")
    sys.exit(1)

roles = data.get("roles", {})
if not isinstance(roles, dict):
    print('"roles" must be a JSON object')
    sys.exit(1)

bad = 0
for key, value in roles.items():
    valid = isinstance(value, str) and (
        value == ""
        or re.fullmatch(r"[A-Za-z0-9._-]+/[A-Za-z0-9._-]+", value.strip())
    )
    if not valid:
        print('roles.%s: value must be "provider/id" or ""' % key)
        bad += 1

sys.exit(1 if bad else 0)
PYEOF
)"; then
    pass "godmode.models.json — all role values are provider/id (or empty)"
  else
    fail "godmode.models.json — invalid (see below)"
    if [ -n "$out" ]; then
      while IFS= read -r line; do
        echo "    $line"
      done <<<"$out"
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  STRUCTURE VALIDATION RESULTS"
echo "============================================"
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  WARN: $WARN"
echo "============================================"

if [ "$FAIL" -gt 0 ]; then
  echo "  STATUS: FAIL"
  echo "============================================"
  exit 1
else
  echo "  STATUS: PASS"
  echo "============================================"
  exit 0
fi
