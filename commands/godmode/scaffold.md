# /godmode:scaffold

Generate boilerplate code for any framework. Creates projects, CRUD resources, API endpoints, components, and services by analyzing and matching existing project patterns.

## Usage

```
/godmode:scaffold <description>           # Interactive scaffolding
/godmode:scaffold --crud <resource>       # Generate full CRUD for a resource
/godmode:scaffold --endpoint <path>       # Generate a single API endpoint
/godmode:scaffold --component <name>      # Generate a frontend component
/godmode:scaffold --service <name>        # Generate a service/provider module
/godmode:scaffold --project <framework>   # Generate a new project skeleton
/godmode:scaffold --dry-run               # Show plan without creating files
/godmode:scaffold --from <template>       # Use a specific file as template
/godmode:scaffold --no-tests              # Skip test file generation
```

## What It Does

1. Detects project language, framework, and conventions
2. Analyzes existing code for patterns (naming, imports, error handling, DI)
3. Generates all files following detected patterns exactly
4. Always generates corresponding test files (unless --no-tests)
5. Verifies generated code compiles and passes lint checks
6. Reports what was generated and what requires manual work

## Output
- Generated code files matching project conventions
- Corresponding test files with basic test cases
- A git commit: `"scaffold: <type> for <name> — <N> files generated"`
- Summary of generated files with TODOs for manual work

## Next Step
After scaffolding: add business logic to generated stubs, then `/godmode:build` for TDD implementation.

## Examples

```
/godmode:scaffold --crud orders           # Full CRUD for orders resource
/godmode:scaffold --endpoint /api/reports # Single API endpoint
/godmode:scaffold --component UserProfile # React/Vue component
/godmode:scaffold --service notification  # Service module
/godmode:scaffold --project "Express + TypeScript"  # New project
/godmode:scaffold --dry-run --crud products  # Preview without generating
```
