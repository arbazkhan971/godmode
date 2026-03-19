# /godmode:learn

Interactive learning and teaching using the actual codebase. Creates tutorials, recommends design patterns for specific problems, enforces best practices per language and framework, builds codebase knowledge bases, and generates personalized learning paths.

## Usage

```
/godmode:learn                                   # Interactive learning session
/godmode:learn --pattern strategy                # Explain Strategy pattern with codebase examples
/godmode:learn --best-practices typescript       # TypeScript best practices audit
/godmode:learn --tutorial "testing"              # Create testing tutorial
/godmode:learn --codebase                        # Build codebase knowledge base
/godmode:learn --assess                          # Skill assessment and learning path
/godmode:learn --next                            # Continue learning path
/godmode:learn --level beginner                  # Set explanation level
```

## What It Does

1. Assesses learning context (topic, current level, learning style)
2. Provides targeted learning experiences:
   - **Tutorials**: Step-by-step, hands-on tutorials using actual project code
   - **Patterns**: Design pattern recommendations with trade-offs and codebase examples
   - **Best Practices**: Language/framework-specific practices with compliance audit
   - **Knowledge Base**: Structured codebase understanding (architecture, conventions, gotchas)
   - **Learning Path**: Personalized skill assessment and growth plan
3. Uses real code from the user's project for all examples
4. Calibrates explanations to the user's skill level

## Output
- Interactive teaching session with exercises
- Pattern recommendations with before/after code
- Best practices checklist with codebase compliance status
- Codebase knowledge base document
- Personalized learning path with milestones

## Next Step
After learning: `/godmode:build` to apply concepts, `/godmode:review` for feedback on implementation.

## Examples

```
/godmode:learn                                   # "What do you want to learn?"
/godmode:learn --pattern observer                # Observer pattern deep dive
/godmode:learn --best-practices react            # React best practices
/godmode:learn --codebase                        # "Help me understand this project"
/godmode:learn --assess                          # "Where should I improve?"
```
