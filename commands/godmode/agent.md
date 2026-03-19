# /godmode:agent

Design, build, and evaluate AI agents. Covers agent architecture patterns (ReAct, plan-and-execute, multi-agent), tool design and integration, memory systems (short-term, long-term, episodic), guardrails and safety, orchestration, and evaluation.

## Usage

```
/godmode:agent                             # Full agent development workflow
/godmode:agent --pattern react             # Build ReAct agent
/godmode:agent --pattern plan-execute      # Build plan-and-execute agent
/godmode:agent --pattern multi-agent       # Build multi-agent system
/godmode:agent --pattern state-machine     # Build state machine agent
/godmode:agent --pattern router            # Build query router agent
/godmode:agent --tools                     # Design and inventory tools
/godmode:agent --memory                    # Design agent memory system
/godmode:agent --guardrails                # Design safety guardrails
/godmode:agent --eval                      # Evaluate agent performance
/godmode:agent --trace <task>              # Show full trajectory for a task
/godmode:agent --debug                     # Debug failing agent task
/godmode:agent --multi                     # Design multi-agent system
/godmode:agent --roster                    # Show agent roster and comms graph
/godmode:agent --optimize                  # Reduce steps, improve tool selection
/godmode:agent --cost                      # Analyze cost per task
```

## What It Does

1. Discovers agent purpose, interaction model, tools, constraints, and success criteria
2. Selects architecture pattern (ReAct, plan-and-execute, reflexion, multi-agent, hierarchical, state machine, router)
3. Designs core agent loop with termination conditions and error handling
4. Designs tool inventory with specifications, risk levels, and rate limits
5. Designs memory system (working, conversation, episodic, semantic, procedural)
6. Implements guardrails across 5 layers (input, execution, tool, output, monitoring)
7. Defines NEVER list of hardcoded safety prohibitions
8. Creates evaluation suite testing task completion, tool selection, safety, and efficiency
9. Generates agent config, implementation, tool definitions, guardrails, and test suite

## Output
- Agent config at `config/agents/<agent>-config.yaml`
- Implementation at `src/agents/<agent>/`
- Tool definitions at `src/agents/<agent>/tools/`
- Guardrails at `src/agents/<agent>/guardrails.py`
- Test suite at `tests/agents/<agent>/`
- Architecture doc at `docs/agents/<agent>-architecture.md`
- Commit: `"agent: <name> — <pattern>, <N> tools, completion=<val>, safety=100%"`

## Next Step
After agent development: `/godmode:rag` to add knowledge retrieval, `/godmode:prompt` to optimize the reasoning prompt, `/godmode:eval` for comprehensive evaluation, or `/godmode:secure` to audit safety.

## Examples

```
/godmode:agent Build an agent that researches topics and writes reports
/godmode:agent --pattern multi-agent Build a code review system with specialized agents
/godmode:agent --tools Design tools for a customer support agent
/godmode:agent --guardrails Add safety guardrails to our existing agent
/godmode:agent --eval Test our agent on 50 tasks
/godmode:agent --debug The agent keeps looping on refund requests
```
