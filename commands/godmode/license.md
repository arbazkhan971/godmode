# /godmode:license

License management — license selection guidance, dependency compatibility checking, SPDX identifiers and file headers, third-party attribution, and CLA/DCO setup. Everything needed to handle software licensing correctly.

## Usage

```
/godmode:license                              # Full license audit (project, deps, headers, attribution)
/godmode:license --select                     # Interactive license selection guidance
/godmode:license --check                      # Check dependency license compatibility
/godmode:license --headers                    # Add SPDX headers to source files
/godmode:license --attribution                # Generate NOTICE and third-party license files
/godmode:license --cla                        # Set up Contributor License Agreement
/godmode:license --dco                        # Set up Developer Certificate of Origin
/godmode:license --apply mit                  # Apply a specific license (mit, apache2, gpl3, etc.)
/godmode:license --audit                      # Full audit report without making changes
/godmode:license --fix                        # Auto-fix detected issues
```

## What It Does

1. Audits current licensing state (LICENSE file, file headers, package metadata)
2. Guides license selection based on project goals (permissive, copyleft, source-available)
3. Compares licenses: MIT, Apache 2.0, GPL v3, AGPL v3, MPL 2.0, BSL 1.1
4. Checks dependency license compatibility against project license
5. Adds SPDX license identifiers to source file headers
6. Generates NOTICE file and third-party license attribution
7. Sets up CLA or DCO enforcement via GitHub Actions
8. Configures CI to enforce license headers on new files

## Output
- LICENSE file with correct license text
- SPDX headers added to source files
- NOTICE and THIRD_PARTY_LICENSES files
- Dependency compatibility report
- CLA/DCO enforcement workflow: .github/workflows/cla.yml or dco.yml
- License header CI check: .github/workflows/license-check.yml
- Commit: `"license: add <license> license (SPDX: <identifier>)"`

## Next Step
After licensing: `/godmode:opensource` for full open source setup, or `/godmode:changelog` for release notes.

## Examples

```
/godmode:license                              # Full audit
/godmode:license --select                     # Help me choose a license
/godmode:license --check                      # Are my deps compatible?
/godmode:license --headers                    # Add SPDX headers everywhere
/godmode:license --apply apache2 --headers    # Apply Apache 2.0 with headers
```
