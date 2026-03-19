# /godmode:think

Collaborative brainstorming and design sessions. Explores 2-3 approaches, facilitates a decision, and produces a written specification.

## Usage

```
/godmode:think <what to design>
/godmode:think --quick <what to design>       # Skip deep codebase research
/godmode:think --spec-only <description>      # Skip brainstorming, write spec directly
/godmode:think --predict                      # Run expert evaluation after brainstorming
/godmode:think --scenario                     # Run edge case exploration after design
```

## What It Does

1. Asks ONE clarifying question (if needed)
2. Researches the codebase for existing patterns and constraints
3. Generates 2-3 concrete approaches with pros/cons
4. Presents a comparison matrix
5. Helps you decide
6. Writes a formal specification to `docs/specs/`

## Output
- A spec file saved to `docs/specs/<feature-name>.md`
- A git commit: `"spec: <feature-name> — <summary>"`

## Next Step
After think completes: `/godmode:plan` to decompose the spec into tasks.

## Examples

```
/godmode:think I need to add real-time notifications to our app
/godmode:think Should we use a monorepo or polyrepo?
/godmode:think --quick Design a caching layer for our API
/godmode:think --predict How should we handle rate limiting?
```
