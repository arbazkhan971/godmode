# MCP Integration

Godmode ships a template `.mcp.json` at the repo root that registers a small, opinionated set of Model Context Protocol servers. This page explains what they do, which skills benefit most, and how to customize the template for your environment.

## What MCP Adds to Godmode

The Model Context Protocol (MCP) is Anthropic's open standard for letting AI assistants talk to external tools and data sources through registered "servers."
Each server runs as a local subprocess that speaks a small JSON-RPC dialect over stdio, and any MCP-aware client can enumerate the tools the server exposes and call them as if they were native.

Godmode's skills are already tool-centric — they drive `Read`, `Grep`, `Bash`, `Edit`, and friends through disciplined workflows — but MCP servers expand that tool surface with capabilities that native adapters do not always expose: scoped filesystem access, structured git history, and authenticated HTTP fetches.
When an MCP-aware client launches, these servers appear alongside the native tools, so godmode skills can pull richer context (commit history, external RFCs, cross-directory reads) without leaving the iteration loop.
Nothing in godmode's universal protocol changes; MCP just gives the agent more hands.

## Registered Servers

| Server | Package | Skills that benefit most | Rationale |
|---|---|---|---|
| `filesystem` | `@modelcontextprotocol/server-filesystem` | `explorer`, `research`, `onboard` | Scoped read access across the whole repo is ideal for mapping unfamiliar codebases beyond what the default `Grep`/`Glob` tools surface. |
| `git` | `@modelcontextprotocol/server-git` | `debug`, `fix`, `legacy`, `git` | Structured access to commit history, blame, and branch diffs turns "git is memory" from a slogan into a queryable archive for root-cause analysis. |
| `fetch` | `@modelcontextprotocol/server-fetch` | `secure`, `research`, `rag` | HTTP retrieval for CVE advisories, RFCs, framework docs, and library references — the exact context these skills need to cite authoritative sources. |

Each server is the canonical reference implementation from the `@modelcontextprotocol/*` namespace.
No custom forks, no third-party shims.

Why these three and not more?
Godmode's skill catalog already covers an enormous surface area through local tools; the goal of the template is to add the smallest set of servers that meaningfully broadens what read-only and research-heavy skills can see.
Filesystem, git, and fetch are the three capability gaps that recur most often across the 126 skills — everything else (databases, browsers, issue trackers) is workload-specific and better left to the user to opt into.

## Installation

Most MCP-aware clients auto-discover `.mcp.json` at the repo root on session start — no manual install step is required.
If you want to run a server standalone to smoke-test it, each canonical package is one `npx` away:

```bash
npx -y @modelcontextprotocol/server-filesystem .
npx -y @modelcontextprotocol/server-git --repository .
npx -y @modelcontextprotocol/server-fetch
```

The first launch downloads the package; subsequent launches use the npx cache.
No global install is needed.
You will need Node.js 18+ on `PATH` for `npx` to resolve these packages.
If your environment is air-gapped, pre-warm the cache once with network access and the same npx commands will then resolve offline.

To confirm a client has picked up the template, open a fresh session in the repo root and ask the agent to list its available tools — the server names (`filesystem`, `git`, `fetch`) should appear alongside the native toolset.

## Adapter Compatibility

| Adapter | MCP support |
|---|---|
| Claude Code | Full support — `.mcp.json` is auto-discovered |
| Cursor | Supported — reads `.mcp.json` from the workspace |
| Codex | Varies — check your installed Codex version for MCP client support |
| Gemini CLI | No native MCP support at this time |
| OpenCode | Varies — depends on the OpenCode build |

Adapters without MCP support simply ignore `.mcp.json`.
Godmode skills still function on those adapters using the built-in `Read`, `Grep`, `Glob`, `Bash`, and `Edit` tools — MCP is additive, never a hard dependency.
No skill in the 126-skill catalog requires MCP to reach its stopping conditions, and the iteration loop's keep/discard rules are identical whether a run uses MCP-exposed tools or native ones.
If you maintain a cross-adapter project, keep the template in the repo; adapters that cannot use it will not complain.

## Customizing the Template

The shipped `.mcp.json` is a starting point. Edit it freely:

- **Scope `filesystem` to a subdirectory.** Replace `${workspaceFolder}` with `./src` or `./packages/api` to keep the server from reading build artifacts or secrets.
- **Add more servers.** Drop additional entries under `mcpServers` — common additions include `@modelcontextprotocol/server-postgres` for database-backed skills or `@modelcontextprotocol/server-puppeteer` for browser-driven e2e skills.
- **Remove servers you do not need.** If your workflow never leaves the repo, delete `fetch`. If you only care about code search, delete `git`. Fewer servers means faster client startup.
- **Inject secrets via `env`.** Each server block has an empty `env: {}` — populate it with tokens (e.g., `GITHUB_TOKEN`) rather than baking them into `args`.
- **Pin versions.** Swap `-y @modelcontextprotocol/server-filesystem` for `-y @modelcontextprotocol/server-filesystem@<version>` if you want reproducible startups.
- **Keep the `_comment` field.** It is ignored by MCP clients and serves as a signal to future maintainers that this file is a template, not a hand-tuned production config.

After editing, restart your MCP client so it re-reads the config.
If a server fails to start, check the client's MCP log for the subprocess stderr — most failures are either a missing Node.js runtime or a typo in `args`.

## How Godmode Skills Pick Up MCP Tools

When an MCP client is active, the tools exported by each registered server appear in the agent's tool list alongside native tools like `Read` and `Bash`.
Skills do not need special-case branches to "detect MCP" — the iteration loop (REVIEW → IDEATE → MODIFY → VERIFY → DECIDE) uses whichever tool best fits the step, and an MCP-exposed tool is just another option the agent can reach for.
For a concrete example, see `skills/research/SKILL.md`: its REVIEW and IDEATE steps call out external documentation lookups, which map naturally onto the `fetch` server when one is available, and fall back to whatever web or read tools the adapter ships by default when it is not.
