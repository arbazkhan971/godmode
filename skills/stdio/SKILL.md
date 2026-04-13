---
name: stdio
description: >
  Canonical command patterns — the in-skill convention for reading tool
  output without wasting context. Ships 13 high-value terse equivalents
  every skill should prefer over verbose defaults. Pure documentation,
  zero binary deps. Complements terse (emit side) and pairs with rtk
  (shell-hook side) for users who install it.
---

# Stdio — Canonical Command Patterns

**Purpose.** Tool output is the largest source of wasted context in a
coding loop. `ls -la` on a 500-file directory, `git log` with full
bodies, `pytest` with verbose traces on a passing run — all emit kilobytes
the model will re-read and never use. This skill is the godmode-native
convention for reading input terse-by-default. It is pure behavior:
no binary to install, no hook to register, just 13 patterns every
skill should reach for before the verbose alternative.

**Scope.** Governs the *input* side of every skill — what you pipe into
context when you ask bash a question. Sibling to `terse` (output side)
and `principles` (authoring side). On conflict with the Universal
Protocol in `SKILL.md`, Protocol wins.

## Activate When

- Any skill about to invoke bash to inspect repo state, tool output,
  container status, or test results
- The verbose form would emit > ~40 lines and you only need a slice
- You are in an autonomous loop where every emitted line is re-read by
  the next round's REVIEW step

Do NOT activate for: explicit debugging sessions where the user asked
to see full output, unfamiliar-codebase exploration (see Hard Rules),
or error investigation (always read the full trace).

## The Four Layers

Godmode has four context-discipline skills, one per phase of the loop:

| Layer | Skill | Phase |
|--|--|--|
| Read input | `stdio` | Before REVIEW — what you pull into context |
| Author code | `principles` | MODIFY — what you decide to write |
| Emit output | `terse` | After DECIDE/LOG — what you print |
| Measure | `bench` | VERIFY — how you compare variants honestly |

`stdio` is the first gate. Verbose input pollutes every downstream
phase. Cut it at the source.

## Canonical Patterns

Prefer the terse form unless the Hard Rules section says otherwise.

| Verbose | Terse | Why | Information preserved |
|--|--|--|--|
| `git log` | `git log --oneline -20` | Full bodies are rarely read; 20 commits covers a typical REVIEW window | Sha, subject, order |
| `git diff` | `git diff --stat` (summary) OR `git diff --unified=1` (context) | `--stat` for "what changed", `-U1` for "show me the edit" — pick by intent | File list + line counts, or hunks with 1 line of context |
| `cat <file>` | `wc -l <file>` (count only) OR `head -20 <file>` (preview) | Reading a whole file to check one thing is the #1 waste | Length, or top-of-file shape |
| `ls -la` | `ls -1` | Permissions/owners/sizes rarely affect logic decisions | Filenames, one per line |
| `npm test` | `npm test -- --silent` or `--reporter=minimal` | Dot reporters are ~10x smaller than spec reporters | Pass/fail count, failing test names |
| `pytest` | `pytest -q --tb=line` | Quiet mode + one-line tracebacks keeps failures visible, drops noise | Pass/fail, single-line failure summaries |
| `grep -r <pat>` | `grep -rc <pat>` (count) OR `grep -rl <pat>` (files only) | "Does it exist?" rarely needs full matching lines | File list or per-file count |
| `find .` | `find . -maxdepth 2 -type f` | Unbounded walks on large repos dump thousands of paths | Top-N levels, type-filtered |
| `docker ps -a` | `docker ps --format 'table {{.Names}}\t{{.Status}}'` | Default columns include ports, command, image — usually irrelevant | Name + status |
| `kubectl get pods -o yaml` | `kubectl get pods` | YAML is multi-kilobyte per pod; drop it unless you need a specific field | Name, ready, status, restarts, age |
| `tree` | `tree -L 2` OR `ls -R \| head -40` | Unbounded recursion blows context on monorepos | Top 2 levels, directory shape |
| `go test ./...` | `go test -run TestName ./pkg` (targeted) OR `go test -count=1 -failfast ./...` (first-fail) | Full suite is wasteful when you edited one package | Pass/fail for the code you actually touched |
| `ps aux` | `ps -o pid,comm,stat --sort=-pcpu \| head -10` | Default columns dump env and args for every process | Top CPU consumers, named |

13 patterns. If a 14th is worth adding, it is probably worth adding as
an rtk handler upstream instead — this list is intentionally small
enough to memorize.

## Hard Rules — When NOT to Compress

1. **Errors need full stack traces.** A failing test, a panicking
   binary, a non-zero exit — always capture the complete output.
   `pytest --tb=line` is fine on a passing run; on a failing run,
   re-run with `--tb=long` before you diagnose.
2. **Writing a commit context needs `git log` with full bodies.**
   `--oneline` loses message body and is the wrong input for anything
   that will quote prior commits.
3. **Unfamiliar codebases need one full `ls -la` + one `tree -L 3`
   up front.** Terse patterns assume you already know the shape.
   First-contact exploration pays full freight once, then switches.
4. **Security / audit skills need everything.** `docker ps -a` with
   full fields, `kubectl get -o yaml`, `ps auxf` with args — these
   skills read fields other skills ignore.
5. **Reproducibility artifacts stay verbose.** Bench results, CI logs,
   anything that gets committed as evidence must be full-fidelity.

If Hard Rules apply, use the verbose form — it is not `complexity_tax`,
it is required context.

## Integration Contract

Every skill that invokes bash for diagnostic reads SHOULD include one
line in its Hard Rules section:

```
N. Prefer stdio patterns per skills/stdio/SKILL.md — terse input by
   default, verbose only when Hard Rules apply.
```

That is the entire contract. No code change, no dispatch, no env var.
A skill is compliant iff its example commands in its own SKILL.md use
the terse column of the table above.

## Interaction With rtk

[rtk](https://github.com/rtk-ai/rtk) is a separate Rust binary that
compresses 100+ tool outputs at the shell-hook level before they enter
model context. If installed, rtk handles input compression
automatically for every bash call — stdio patterns become
belt-and-braces redundancy. Both are designed to coexist:

- `rtk` installed → shell hook compresses everything, stdio is a
  written convention reinforcing what rtk already does
- `rtk` not installed → stdio is the only compression on the input
  side; skills must actively choose terse forms

Neither replaces the other. rtk covers 100+ tools; stdio caps at 13
patterns every author can memorize. rtk is opt-in infrastructure;
stdio is always-on discipline.

## Keep / Discard Discipline

Stdio compliance feeds the Universal Protocol's discard table:

```
KEEP    if  skill-example uses terse form from the table
KEEP    if  skill-example uses verbose form AND a Hard Rule applies
DISCARD if  skill-example uses verbose form AND no Hard Rule applies
        → classify: unnecessary_verbosity
```

`unnecessary_verbosity` is a new failure class narrower than
`complexity_tax`. It applies to input-side waste (verbose bash calls),
not code-authoring waste. Log to
`.godmode/<skill>-failures.tsv` with the same schema.

## Success Criterion

A skill is stdio-compliant when:

1. Its SKILL.md Hard Rules reference stdio.
2. Every example bash command in its SKILL.md uses the terse form from
   the table, OR invokes a Hard Rule and annotates why.
3. `grep -n "git log$\|cat .*\.\(py\|ts\|go\|rs\)$\|ls -la$\|pytest$\|find \.$" skills/<name>/SKILL.md` returns zero lines.

Check #3 is the mechanical verifier — a one-liner a reviewer can run.

## Stop Conditions

- **fully_compliant** — all three success criteria met
- **hard_rule_documented** — verbose form used, exception annotated in
  a comment on the same line
- **unnecessary_verbosity** — verbose form used with no exception;
  discard per Keep/Discard rules above
