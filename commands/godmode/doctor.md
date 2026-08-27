# /godmode:doctor

Model-routing doctor — print the resolved role -> model table with each value's source (env / file / session). One command, no guessing.

## Usage

```
/godmode:doctor          # Print the resolved role -> model table
```

Equivalent natural-language triggers: "which model is each role using", "model routing check". In a godmode repo checkout the same table is available on the CLI:

```bash
bash adapters/pi/models.sh doctor
```

## What It Does

1. Resolves every role through the pinned order: `GODMODE_MODEL_<ROLE>` env -> `godmode.models.json` roles -> session model (repo-root file wins per key over `~/.config/godmode/models.json`)
2. Prints one TSV row per role: role, model, source (env / file / session), origin (env var name or config path)
3. Always exits 0 — missing config is the valid zero-config default: every role inherits the session model
4. Never prints secrets — env sweeps list variable names only, never values

Full protocol: `skills/verify/SKILL.md` (Workflow step 0, Doctor Mode).
