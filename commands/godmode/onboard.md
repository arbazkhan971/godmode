# /godmode:onboard

Codebase onboarding and architecture discovery. Generates architecture walkthroughs, identifies key files, analyzes naming conventions, visualizes dependencies, and creates guided code tours.

## Usage

```
/godmode:onboard                        # Full onboarding — architecture, key files, code tour
/godmode:onboard --quick                # Quick architecture overview only
/godmode:onboard --tour                 # Generate code tour only
/godmode:onboard --deps                 # Dependency graph and analysis only
/godmode:onboard --naming               # Naming convention analysis only
/godmode:onboard --files                # Key file identification only
/godmode:onboard --health               # Project health signals only
```

## What It Does

1. Scans project to identify type, language, framework, and structure
2. Generates architecture walkthrough with directory map and data flow diagram
3. Identifies key files a new developer should read first (ordered reading list)
4. Analyzes naming conventions for files, variables, functions, types, and APIs
5. Maps internal module dependencies and external package dependencies
6. Creates a guided code tour with annotated stops through critical code paths

## Output
- Onboarding report at `docs/onboarding/<project>-onboarding.md`
- Code tour at `docs/onboarding/<project>-code-tour.md`
- Commit: `"onboard: <project> — architecture walkthrough with <N>-stop code tour"`

## Next Step
After onboarding: `/godmode:think` to design your first feature in this codebase.

## Examples

```
/godmode:onboard                        # Full onboarding walkthrough
/godmode:onboard --quick                # Just the architecture overview
/godmode:onboard --tour                 # Generate a guided code tour
/godmode:onboard --deps                 # Dependency graph analysis
```
