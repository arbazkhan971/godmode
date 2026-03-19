#!/usr/bin/env bash
# =============================================================================
# validate-skills.sh — Skill Validation Script for Godmode Plugin
# =============================================================================
# Validates:
#   1. Every SKILL.md has valid frontmatter (name, description)
#   2. Every skill directory has a SKILL.md
#   3. Every command file references a valid skill
#   4. marketplace.json lists all skills
#   5. Cross-reference: all skills in design doc exist as files
#
# Usage: bash tests/validate-skills.sh
# Exit code: 0 = all pass, 1 = failures found
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SKILLS_DIR="$ROOT_DIR/skills"
COMMANDS_DIR="$ROOT_DIR/commands/godmode"
MARKETPLACE="$ROOT_DIR/.claude-plugin/marketplace.json"
DESIGN_DOC="$ROOT_DIR/docs/godmode-design.md"

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
# CHECK 1: Every SKILL.md has valid frontmatter (name, description)
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 1: SKILL.md Frontmatter Validation"

skill_md_count=0
skill_md_valid=0

while IFS= read -r skill_file; do
  skill_md_count=$((skill_md_count + 1))
  skill_name="$(basename "$(dirname "$skill_file")")"

  # Check for opening frontmatter delimiter
  first_line="$(head -1 "$skill_file")"
  if [ "$first_line" != "---" ]; then
    fail "$skill_name/SKILL.md — missing frontmatter (no opening ---)"
    continue
  fi

  # Extract frontmatter block (between first and second ---)
  frontmatter="$(sed -n '2,/^---$/p' "$skill_file" | sed '$d')"

  # Check for 'name:' field
  if echo "$frontmatter" | grep -q "^name:"; then
    name_value="$(echo "$frontmatter" | grep "^name:" | head -1 | sed 's/^name: *//')"
    if [ -z "$name_value" ]; then
      fail "$skill_name/SKILL.md — 'name' field is empty"
      continue
    fi
  else
    fail "$skill_name/SKILL.md — missing 'name' field in frontmatter"
    continue
  fi

  # Check for 'description:' field
  if echo "$frontmatter" | grep -q "^description:"; then
    # Description can be multiline (YAML block scalar), just check it exists
    pass "$skill_name/SKILL.md — valid frontmatter (name: $name_value)"
    skill_md_valid=$((skill_md_valid + 1))
  else
    fail "$skill_name/SKILL.md — missing 'description' field in frontmatter"
    continue
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f | sort)

echo ""
echo "  Summary: $skill_md_valid/$skill_md_count SKILL.md files have valid frontmatter"

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 2: Every skill directory has a SKILL.md
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 2: Skill Directory Completeness"

dirs_total=0
dirs_with_skill=0
dirs_missing_skill=()

while IFS= read -r skill_dir; do
  dirs_total=$((dirs_total + 1))
  skill_name="$(basename "$skill_dir")"

  if [ -f "$skill_dir/SKILL.md" ]; then
    dirs_with_skill=$((dirs_with_skill + 1))
    pass "$skill_name/ has SKILL.md"
  else
    dirs_missing_skill+=("$skill_name")
    fail "$skill_name/ is missing SKILL.md"
  fi
done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

echo ""
echo "  Summary: $dirs_with_skill/$dirs_total skill directories have SKILL.md"

if [ ${#dirs_missing_skill[@]} -gt 0 ]; then
  echo "  Missing SKILL.md in: ${dirs_missing_skill[*]}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 3: Every command file references a valid skill directory
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 3: Command-to-Skill Cross-Reference"

if [ -d "$COMMANDS_DIR" ]; then
  cmd_total=0
  cmd_valid=0

  while IFS= read -r cmd_file; do
    cmd_total=$((cmd_total + 1))
    cmd_name="$(basename "$cmd_file" .md)"

    # A command should reference an existing skill directory
    if [ -d "$SKILLS_DIR/$cmd_name" ]; then
      if [ -f "$SKILLS_DIR/$cmd_name/SKILL.md" ]; then
        pass "Command $cmd_name -> skill $cmd_name/ (with SKILL.md)"
        cmd_valid=$((cmd_valid + 1))
      else
        warn "Command $cmd_name -> skill $cmd_name/ exists but has no SKILL.md"
      fi
    else
      warn "Command $cmd_name has no matching skill directory"
    fi
  done < <(find "$COMMANDS_DIR" -name "*.md" -type f | sort)

  echo ""
  echo "  Summary: $cmd_valid/$cmd_total commands have matching skills with SKILL.md"
else
  warn "Commands directory not found at $COMMANDS_DIR"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 4: marketplace.json lists all skills
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 4: marketplace.json Completeness"

if [ -f "$MARKETPLACE" ]; then
  # Get all skill keys from marketplace.json
  marketplace_skills=()
  while IFS= read -r skill; do
    marketplace_skills+=("$skill")
  done < <(grep -o '"[^"]*": "skills/[^"]*"' "$MARKETPLACE" | sed 's/"\([^"]*\)".*/\1/')

  # Get all skill directories that have SKILL.md
  actual_skills=()
  while IFS= read -r skill_dir; do
    skill_name="$(basename "$skill_dir")"
    if [ -f "$skill_dir/SKILL.md" ]; then
      actual_skills+=("$skill_name")
    fi
  done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

  # Check: every actual skill should be in marketplace
  missing_from_marketplace=()
  for skill in "${actual_skills[@]}"; do
    found=false
    for mp_skill in "${marketplace_skills[@]}"; do
      if [ "$skill" = "$mp_skill" ]; then
        found=true
        break
      fi
    done
    if $found; then
      pass "Skill '$skill' is listed in marketplace.json"
    else
      missing_from_marketplace+=("$skill")
      fail "Skill '$skill' has SKILL.md but is NOT in marketplace.json"
    fi
  done

  # Check: every marketplace skill should exist on disk
  orphaned_in_marketplace=()
  for mp_skill in "${marketplace_skills[@]}"; do
    if [ -f "$SKILLS_DIR/$mp_skill/SKILL.md" ]; then
      : # already checked above
    else
      orphaned_in_marketplace+=("$mp_skill")
      fail "Skill '$mp_skill' is in marketplace.json but has no SKILL.md on disk"
    fi
  done

  echo ""
  echo "  Marketplace lists ${#marketplace_skills[@]} skills, disk has ${#actual_skills[@]} skills with SKILL.md"
  if [ ${#missing_from_marketplace[@]} -gt 0 ]; then
    echo "  Missing from marketplace: ${missing_from_marketplace[*]}"
  fi
  if [ ${#orphaned_in_marketplace[@]} -gt 0 ]; then
    echo "  Orphaned in marketplace (no SKILL.md): ${orphaned_in_marketplace[*]}"
  fi
else
  fail "marketplace.json not found at $MARKETPLACE"
fi

# ─────────────────────────────────────────────────────────────────────────────
# CHECK 5: Cross-reference design doc skills with actual files
# ─────────────────────────────────────────────────────────────────────────────
separator "Check 5: Design Doc Cross-Reference"

if [ -f "$DESIGN_DOC" ]; then
  # Extract skill names referenced in design doc skill tables
  # Pattern: | **SkillName** | or skill references like skills/name/
  design_skills=()

  # Extract skill names from design doc skill table rows that contain /godmode: commands
  # Pattern: | **SkillName** | `/godmode:xxx` | — targets actual skill definitions
  while IFS= read -r skill; do
    # Normalize to lowercase
    skill_lower="$(echo "$skill" | tr '[:upper:]' '[:lower:]')"
    design_skills+=("$skill_lower")
  done < <(grep '/godmode' "$DESIGN_DOC" | grep -o '\*\*[A-Za-z]*\*\*' | sed 's/\*\*//g' | sort -u)

  # Also extract from explicit path references like skills/name/SKILL.md or skills/name/
  while IFS= read -r skill; do
    skill_lower="$(echo "$skill" | tr '[:upper:]' '[:lower:]')"
    # Skip empty
    if [ -z "$skill_lower" ]; then continue; fi
    # Avoid duplicates
    found=false
    for existing in "${design_skills[@]}"; do
      if [ "$existing" = "$skill_lower" ]; then
        found=true
        break
      fi
    done
    if ! $found; then
      design_skills+=("$skill_lower")
    fi
  done < <(grep -o 'skills/[a-z0-9_-]*/' "$DESIGN_DOC" 2>/dev/null | sed 's|skills/||; s|/||' | sort -u)

  # Check each design doc skill against actual skill dirs
  design_matched=0
  design_missing=()
  for skill in "${design_skills[@]}"; do
    # Skip empty entries
    if [ -z "$skill" ]; then
      continue
    fi
    if [ -d "$SKILLS_DIR/$skill" ]; then
      design_matched=$((design_matched + 1))
    else
      # Only flag as missing if it looks like a real skill name (not generic words)
      case "$skill" in
        the|a|an|and|or|for|to|in|on|with|from|by|is|it|of|at|as|this|that|no|do|all|any|one|two|three|four|code|user|loop|file|core|phase|each|spec|task|red|new|run|set|get|use|git|ci|cd|has|can|will|may|pre|post|not|per|max|min|top|end|out|up|key|log|api|app|web|dev|ops|data|test|plan|ship|fix|if|so|go|be|we|us|me|he|she|them|our|my|your|its|how|why|what|when|who|where|good|bad|best|more|less|than|then|now|here|just|like|make|take|know|see|find|give|tell|ask|work|call|try|need|keep|let|begin|seem|help|show|hear|play|move|live|believe|happen|ok|none|only|also|even|much|very|too|most|some|many|well|still|way|part|long|after|before|first|last|next|same|old|right|left|high|low|big|small|great|little|own|other|early|late|real|sure|free|full|open|close|true|false|able|simple|hard|easy|fast|slow|single|double|total|every|both|few|between)
          # Skip common English words that appear in bold in docs
          ;;
        *)
          design_missing+=("$skill")
          ;;
      esac
    fi
  done

  if [ ${#design_missing[@]} -gt 0 ]; then
    for skill in "${design_missing[@]}"; do
      warn "Design doc references skill '$skill' but no directory exists at skills/$skill/"
    done
  fi

  echo ""
  echo "  Design doc references ${#design_skills[@]} potential skill names"
  echo "  Matched $design_matched to existing directories"
  if [ ${#design_missing[@]} -gt 0 ]; then
    echo "  Unmatched references: ${design_missing[*]}"
  fi
else
  warn "Design doc not found at $DESIGN_DOC"
fi

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  VALIDATION RESULTS"
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
