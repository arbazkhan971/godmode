# /godmode:designconsistency

Design consistency enforcement — extracts a design contract from your codebase (colors, spacing, typography, shadows, radius, transitions), then mechanically enforces it across all UI generation. Solves AI's #1 design problem: inconsistent output across sessions.

## Usage

```
/godmode:designconsistency                  # Extract/create design contract
/godmode:designconsistency --audit <path>   # Audit files for consistency
/godmode:designconsistency --fix            # Auto-fix all inconsistencies
/godmode:designconsistency --extract        # Extract contract from existing code
/godmode:designconsistency --strict         # CI mode — fail on any inconsistency
```

## What It Does

1. Scans tailwind config, CSS variables, design tokens, and existing components
2. Builds a design contract (spacing scale, color palette, type scale, etc.)
3. Enforces contract on all future UI generation
4. Audits existing code for drift with grep-based mechanical verification
5. Auto-fixes inconsistencies to match the contract

## Output
- Design contract at `docs/design/design-contract.md`
- Audit report with line-level findings
- Auto-fix commit: `"style: align with design contract"`

## Next Step
→ `/godmode:ui` to generate consistent components
→ `/godmode:visual` for visual regression testing
