#!/usr/bin/env bash
# =============================================================================
# count-skills.sh — Skill Counter for Godmode Plugin
# =============================================================================
# Counts total skills, commands, reference docs, guides, and other assets.
# Outputs summary statistics suitable for README badge generation.
#
# Usage: bash scripts/count-skills.sh [--json] [--badges]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SKILLS_DIR="$ROOT_DIR/skills"
COMMANDS_DIR="$ROOT_DIR/commands"
DOCS_DIR="$ROOT_DIR/docs"
AGENTS_DIR="$ROOT_DIR/agents"
HOOKS_DIR="$ROOT_DIR/hooks"

OUTPUT_FORMAT="${1:-text}"

# ── Count skill directories ──────────────────────────────────────────────────
total_skill_dirs=$(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

# ── Count skills with SKILL.md (complete skills) ────────────────────────────
complete_skills=$(find "$SKILLS_DIR" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')

# ── Count skill directories without SKILL.md (incomplete) ───────────────────
incomplete_skills=$((total_skill_dirs - complete_skills))

# ── Count command files ──────────────────────────────────────────────────────
total_commands=0
if [ -d "$COMMANDS_DIR/godmode" ]; then
  total_commands=$(find "$COMMANDS_DIR/godmode" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# Add root command if it exists
if [ -f "$COMMANDS_DIR/godmode.md" ]; then
  total_commands=$((total_commands + 1))
fi

# ── Count reference docs ────────────────────────────────────────────────────
reference_docs=$(find "$SKILLS_DIR" -path "*/references/*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

# ── Count template files ────────────────────────────────────────────────────
template_files=$(find "$SKILLS_DIR" -path "*/templates/*" -type f 2>/dev/null | wc -l | tr -d ' ')

# ── Count guides and documentation ──────────────────────────────────────────
guide_docs=0
if [ -d "$DOCS_DIR" ]; then
  guide_docs=$(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── Count agents ────────────────────────────────────────────────────────────
total_agents=0
if [ -d "$AGENTS_DIR" ]; then
  total_agents=$(find "$AGENTS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── Count hooks ─────────────────────────────────────────────────────────────
total_hooks=0
if [ -d "$HOOKS_DIR" ]; then
  total_hooks=$(find "$HOOKS_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── Count example docs ──────────────────────────────────────────────────────
example_docs=0
if [ -d "$DOCS_DIR/examples" ]; then
  example_docs=$(find "$DOCS_DIR/examples" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── Count language docs ─────────────────────────────────────────────────────
language_docs=0
if [ -d "$DOCS_DIR/languages" ]; then
  language_docs=$(find "$DOCS_DIR/languages" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# ── Total markdown files in project ─────────────────────────────────────────
total_md_files=$(find "$ROOT_DIR" -name "*.md" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')

# ── Skill categories (by phase from design doc) ────────────────────────────
# We determine categories by checking SKILL.md content for phase indicators
think_skills=0
build_skills=0
optimize_skills=0
ship_skills=0
meta_skills=0
domain_skills=0

while IFS= read -r skill_file; do
  content="$(cat "$skill_file")"
  skill_name="$(basename "$(dirname "$skill_file")")"

  case "$skill_name" in
    think|predict|scenario)
      think_skills=$((think_skills + 1)) ;;
    plan|build|test|review)
      build_skills=$((build_skills + 1)) ;;
    optimize|debug|fix|secure)
      optimize_skills=$((optimize_skills + 1)) ;;
    ship|finish)
      ship_skills=$((ship_skills + 1)) ;;
    godmode|setup|verify)
      meta_skills=$((meta_skills + 1)) ;;
    *)
      domain_skills=$((domain_skills + 1)) ;;
  esac
done < <(find "$SKILLS_DIR" -name "SKILL.md" -type f | sort)

# ── Output ──────────────────────────────────────────────────────────────────

case "$OUTPUT_FORMAT" in
  --json)
    cat <<ENDJSON
{
  "skills": {
    "total_directories": $total_skill_dirs,
    "complete": $complete_skills,
    "incomplete": $incomplete_skills
  },
  "commands": $total_commands,
  "reference_docs": $reference_docs,
  "templates": $template_files,
  "guides": $guide_docs,
  "examples": $example_docs,
  "language_docs": $language_docs,
  "agents": $total_agents,
  "hooks": $total_hooks,
  "total_md_files": $total_md_files,
  "categories": {
    "think": $think_skills,
    "build": $build_skills,
    "optimize": $optimize_skills,
    "ship": $ship_skills,
    "meta": $meta_skills,
    "domain": $domain_skills
  }
}
ENDJSON
    ;;

  --badges)
    echo "![Skills](https://img.shields.io/badge/skills-${complete_skills}-blue)"
    echo "![Commands](https://img.shields.io/badge/commands-${total_commands}-green)"
    echo "![Docs](https://img.shields.io/badge/docs-${guide_docs}-orange)"
    echo "![Agents](https://img.shields.io/badge/agents-${total_agents}-purple)"
    echo "![Total MD](https://img.shields.io/badge/total_files-${total_md_files}-lightgrey)"
    ;;

  *)
    echo "============================================"
    echo "  GODMODE PLUGIN — STATISTICS"
    echo "============================================"
    echo ""
    echo "  SKILLS"
    echo "    Skill directories:    $total_skill_dirs"
    echo "    With SKILL.md:        $complete_skills"
    echo "    Missing SKILL.md:     $incomplete_skills"
    echo ""
    echo "  SKILL CATEGORIES"
    echo "    Think phase:          $think_skills"
    echo "    Build phase:          $build_skills"
    echo "    Optimize phase:       $optimize_skills"
    echo "    Ship phase:           $ship_skills"
    echo "    Meta skills:          $meta_skills"
    echo "    Domain skills:        $domain_skills"
    echo ""
    echo "  COMMANDS"
    echo "    Total commands:       $total_commands"
    echo ""
    echo "  DOCUMENTATION"
    echo "    Reference docs:       $reference_docs"
    echo "    Templates:            $template_files"
    echo "    Guides:               $guide_docs"
    echo "    Examples:             $example_docs"
    echo "    Language guides:      $language_docs"
    echo ""
    echo "  OTHER ASSETS"
    echo "    Agents:               $total_agents"
    echo "    Hooks:                $total_hooks"
    echo ""
    echo "  TOTALS"
    echo "    Total .md files:      $total_md_files"
    echo ""
    echo "============================================"
    ;;
esac
