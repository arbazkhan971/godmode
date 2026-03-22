---
name: agent
description: |
  AI agent development skill. Activates when users need to design, build, or evaluate AI agents. Covers agent architecture patterns (ReAct, plan-and-execute, multi-agent), tool design and integration, memory systems (short-term, long-term, episodic), guardrails and safety, orchestration, and evaluation. Every agent gets a structured architecture spec, tool inventory, safety guardrails, and test suite. Triggers on: /godmode:agent, "build an AI agent", "design agent tools", "add memory to agent", or when the orchestrator detects agent-related work.
---

# Agent — AI Agent Development

## When to Activate
- User invokes `/godmode:agent`
- User says "build an AI agent", "create an agent", "add tools to my agent"
- User says "design agent memory", "agent keeps looping", "agent safety"
- When building autonomous or semi-autonomous LLM-powered systems
- When `/godmode:prompt` identifies a need for agentic capabilities (tool use, multi-step reasoning)
- When `/godmode:rag` needs to be wrapped in an agent loop
- When the orchestrator detects agent frameworks (LangChain, LlamaIndex, CrewAI, AutoGen, custom agent loops) in code

## Workflow

### Step 1: Agent Discovery & Requirements
Understand what the agent must accomplish:

```
AGENT DISCOVERY:
Purpose: <what the agent must autonomously accomplish>
Type:
  - Single-agent: One agent with tools (most common)
  - Multi-agent: Multiple specialized agents coordinating
  - Human-in-the-loop: Agent proposes, human approves critical actions

User interaction:
  - Conversational: User chats with agent in real-time
  - Autonomous: Agent runs a task to completion without user input
  - Supervised: Agent asks for confirmation at decision points

Environment:
  - Tools available: <list of APIs, databases, code execution, file systems>
  - External systems: <services the agent will interact with>
```

If the user hasn't specified, ask: "What should this agent do autonomously? What tools does it need?"

### Step 2: Architecture Pattern Selection
Select the agent architecture pattern:

```
AGENT ARCHITECTURE SELECTION:

Patterns:
┌────────────────────────┬──────────────────────────────────────────────────────┐
│ Pattern                │ Best for                                             │
├────────────────────────┼──────────────────────────────────────────────────────┤
│ ReAct                  │ General-purpose tool use, step-by-step reasoning     │
│ (Reason + Act)         │ with tool calls. Simple, effective, well-understood. │
│                        │                                                      │
│ Plan-and-Execute       │ Complex tasks needing upfront planning. Planner      │
│                        │ creates step list, executor follows it. Good for     │
│                        │ multi-step tasks with clear decomposition.           │
│                        │                                                      │
│ Reflexion              │ Tasks requiring self-correction. Agent attempts,     │
│                        │ evaluates own output, and retries with feedback.     │
```

### Step 3: Agent Loop Design
Design the core agent execution loop:

```
AGENT LOOP DESIGN:

Pattern: <selected pattern>
Model: <LLM for agent reasoning — e.g., Claude 3.5 Sonnet, GPT-4>

ReAct loop:
┌─────────────────────────────────────────────────────────────────────┐
│  while not done and steps < max_steps:                              │
│    1. THINK: Reason about current state and what to do next         │
│    2. ACT: Select and call a tool with parameters                   │
│    3. OBSERVE: Process tool result                                  │
│    4. EVALUATE: Is the task complete? Should I continue?            │
│                                                                     │
│  Termination conditions:                                            │
│    - Task completed successfully -> return result                   │
```

### Step 4: Tool Design & Integration
Design the tools the agent can use:

```
TOOL INVENTORY:
┌───────────────────┬──────────────┬──────────────┬──────────────────────────┐
│ Tool              │ Type         │ Risk Level   │ Description              │
├───────────────────┼──────────────┼──────────────┼──────────────────────────┤
│ <tool_name>       │ Read-only    │ LOW          │ <what it does>           │
│ <tool_name>       │ Write        │ MEDIUM       │ <what it does>           │
│ <tool_name>       │ External API │ MEDIUM       │ <what it does>           │
│ <tool_name>       │ Code exec    │ HIGH         │ <what it does>           │
│ <tool_name>       │ Destructive  │ CRITICAL     │ <what it does>           │
└───────────────────┴──────────────┴──────────────┴──────────────────────────┘

TOOL DESIGN PRINCIPLES:
1. Single responsibility: each tool does one thing well
2. Clear naming: tool name describes the action (search_docs, create_ticket)
3. Typed parameters: every parameter has a type, description, and constraints
```

### Step 5: Memory System Design
Design how the agent remembers and learns:

```
MEMORY SYSTEM DESIGN:

Memory types:
┌─────────────────────┬──────────────────────────────────────────────────────┐
│ Type                │ Implementation                                       │
├─────────────────────┼──────────────────────────────────────────────────────┤
│ Working memory      │ Current conversation context window. Limited by      │
│ (short-term)        │ model context length. Contains current task state,   │
│                     │ recent tool results, and immediate reasoning.        │
│                     │                                                      │
│ Conversation memory │ Full conversation history, summarized as needed.     │
│ (session)           │ Stored in session store (Redis, database).           │
│                     │ Summarize older turns to fit context window.         │
│                     │                                                      │
│ Episodic memory     │ Past task executions and outcomes. "Last time I      │
```

### Step 6: Guardrails & Safety
Design safety boundaries for the agent:

```
AGENT GUARDRAILS:

Layer 1 — Input guardrails:
  ┌───────────────────────────────────────────────────────────────────┐
  │ Check                      │ Action                              │
  ├────────────────────────────┼─────────────────────────────────────┤
  │ Prompt injection detection │ Reject input, log attempt           │
  │ PII in input               │ Redact before processing            │
  │ Off-topic request          │ Redirect to appropriate channel     │
  │ Malicious intent detection │ Refuse and log                      │
  │ Input length limit         │ Truncate with warning               │
  └────────────────────────────┴─────────────────────────────────────┘

Layer 2 — Execution guardrails:
  ┌───────────────────────────────────────────────────────────────────┐
```

### Step 7: Agent Evaluation & Testing
Design a test suite for the agent:

```
AGENT TEST SUITE:

Test categories:
┌─────────────────────────┬───────┬────────────────────────────────────────────┐
│ Category                │ Tests │ Description                                │
├─────────────────────────┼───────┼────────────────────────────────────────────┤
│ Task completion         │ <N>   │ Agent successfully completes defined tasks │
│ Tool selection          │ <N>   │ Agent picks correct tool for each step     │
│ Multi-step reasoning    │ <N>   │ Agent chains tools correctly for complex   │
│                         │       │ tasks                                      │
│ Error recovery          │ <N>   │ Agent handles tool failures gracefully     │
│ Safety compliance       │ <N>   │ Agent refuses unsafe actions               │
│ Guardrail adherence     │ <N>   │ Agent stays within defined limits          │
│ Edge cases              │ <N>   │ Ambiguous inputs, missing data, conflicts  │
│ Adversarial             │ <N>   │ Injection attacks, manipulation attempts   │
```

### Step 8: Agent Artifacts & Commit
Generate the deliverables:

1. **Agent config**: `config/agents/<agent>-config.yaml`
2. **Agent implementation**: `src/agents/<agent>/agent.py`
3. **Tool definitions**: `src/agents/<agent>/tools/`
4. **Memory module**: `src/agents/<agent>/memory.py`
5. **Guardrails**: `src/agents/<agent>/guardrails.py`
6. **Test suite**: `tests/agents/<agent>/`
7. **Architecture doc**: `docs/agents/<agent>-architecture.md`

```
AGENT DEVELOPMENT COMPLETE:

Architecture:
- Pattern: <pattern name>
- Model: <LLM for reasoning>
- Tools: <N tools> (read: <N>, write: <N>, code exec: <N>)
- Memory: <memory types implemented>
- Guardrails: <N guardrail layers>

Evaluation:
- Task completion rate: <val>
- Tool selection accuracy: <val>
- Safety violation rate: <val> (require 0%)
- Avg steps per task: <N>
- Avg latency per task: <seconds>
```

Commit: `"agent: <agent name> — <pattern>, <N> tools, completion=<val>, safety=100%"`

## Key Behaviors

1. **Guardrails before capabilities.** Define what the agent must NEVER do before defining what it can do. Safety constraints are non-negotiable and non-overridable.
2. **Tools are the agent's hands.** A well-designed tool inventory determines agent effectiveness more than the LLM choice. Invest in tool design.
3. **Loops need escape hatches.** Every agent loop must have termination conditions: max steps, max cost, max time, error thresholds. An agent without limits will loop forever.
4. **Test trajectories, not just outcomes.** A correct final answer reached through unsafe or inefficient steps is not acceptable. Evaluate the full reasoning trace.
5. **Memory is context engineering.** The agent's working memory (context window) is precious. Retrieve selectively from long-term memory, summarize aggressively, and never waste tokens on irrelevant history.
6. **Human-in-the-loop for irreversible actions.** Any action that cannot be undone (delete, send, deploy, pay) requires explicit user confirmation. No exceptions.
7. **Observability is mandatory.** Log every agent step. You cannot debug an agent you cannot observe. Traces are the debugging tool for agentic systems.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full agent development workflow |
| `--pattern <name>` | Force architecture: `react`, `plan-execute`, `reflexion`, `multi-agent`, `state-machine`, `router` |
| `--tools` | Design and inventory agent tools |

## Explicit Loop Protocol

When building or debugging agent loops, use this tracking protocol:

```
AGENT BUILD/DEBUG LOOP:
current_iteration = 0
max_iterations = 20
issues_remaining = total_issues

WHILE issues_remaining > 0 AND current_iteration < max_iterations:
    current_iteration += 1

    1. IDENTIFY next issue (tool gap, guardrail weakness, test failure)
    2. IMPLEMENT fix (code change, config update, prompt edit)
    3. git commit with message: "agent: fix <issue> (iter {current_iteration})"
    4. RUN evaluation suite against the fix
    5. RECORD result:
       - Pass/fail for each test category
       - Regression check: did the fix break anything?
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. NEVER deploy an agent without guardrails defined first — safety before capabilities.
2. NEVER allow irreversible tool actions without explicit user confirmation gate.
3. EVERY agent loop MUST have a max_steps termination — no unbounded loops.
4. EVERY agent MUST have a cost budget (max tokens per task) — no runaway spending.
5. git commit BEFORE running evaluation — if eval reveals regression, revert.
6. Safety violation rate MUST equal 0% — any safety failure is a blocking issue.
7. Log every agent step in structured format:
   STEP\tACTION\tTOOL\tRESULT\tTOKENS\tLATENCY
8. Test trajectories, not just final outputs — correct answer via unsafe path is a failure.
9. NEVER give agents tools they do not need — fewer tools = better tool selection.
10. Observability is mandatory — if you cannot trace every step, do not deploy.
```

## Auto-Detection
```bash
AUTO-DETECT agent context:
  1. LLM provider: grep -r "openai\|anthropic\|google.generativeai\|ollama\|together" package.json pyproject.toml requirements.txt 2>/dev/null
  2. Agent framework: grep -r "langchain\|langgraph\|autogen\|crewai\|magentic\|pydantic-ai" package.json pyproject.toml 2>/dev/null
  3. Tool definitions: grep -rl "tool_call\|function_call\|@tool\|BaseTool\|StructuredTool" src/ --include="*.ts" --include="*.py" 2>/dev/null | head -5
  4. Vector store: grep -r "pinecone\|weaviate\|chromadb\|pgvector\|qdrant\|milvus" package.json pyproject.toml 2>/dev/null
  5. Existing agent code: grep -rl "agent\|AgentExecutor\|ReActAgent\|create_agent" src/ --include="*.ts" --include="*.py" 2>/dev/null | head -5
# ... (condensed)
```

## Success Criteria
Verify all of these before marking the task complete:
1. Agent completes its target task end-to-end with correct output (verified on at least 3 test inputs).
2. Max steps termination works (agent stops at limit, does not loop forever).
3. Cost budget enforced (token counter tracks usage, agent stops when budget exceeded).
4. Guardrails block unsafe actions (test with at least one adversarial input that the system rejects).
5. Every agent step is logged with: step number, action, tool called, result, tokens used, latency.
6. Irreversible actions (delete, send, deploy, pay) require explicit confirmation gate.
7. Tool errors are handled gracefully (agent retries or reports failure, does not crash).
8. Evaluation suite exists: test trajectories (not just final output), measure success rate, cost, and safety.

## Error Recovery
| Failure | Action |
|---------|--------|
| Agent loops without progress | Check for: repeated tool calls with same args, no new information gained. Add loop detection: if same action repeated 3x, force different action or stop. |
| Token budget exceeded | Implement token counting middleware. Set hard limit per task. When 80% consumed, switch to shorter prompts or cheaper model for remaining steps. |
| Tool returns unexpected format | Add output validation on every tool result. If validation fails, retry with clearer instructions (max 2 retries), then report failure to user. |

## Keep/Discard Discipline
```
After EACH agent change (prompt edit, tool addition, guardrail update):
  1. MEASURE: Run evaluation suite — task completion rate, safety violations, avg steps.
  2. COMPARE: Did the change improve the target metric without introducing regressions?
  3. DECIDE:
     - KEEP if: completion rate maintained or improved AND safety violations = 0 AND no new failure modes
     - DISCARD if: safety violation detected OR completion rate dropped OR new failure mode introduced
  4. COMMIT kept changes. Revert discarded changes before the next iteration.

Never keep a change that introduces any safety violation, regardless of completion rate improvement.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Agent completes target tasks end-to-end with correct output on 3+ test inputs
  - Safety violation rate = 0% across all test cases including adversarial inputs
  - All guardrails (max steps, cost budget, confirmation gates) verified working
  - User explicitly requests stop

DO NOT STOP just because:
  - Completion rate is below 100% on edge cases (document them, iterate later)
  - A single tool has high error rate (fix the tool, not the agent)
```


## TSV Logging
Append to `.godmode/agent-results.tsv`:
```
timestamp	agent_name	pattern	tools_count	test_inputs	completion_rate	safety_violations	status
```
One row per agent build/eval iteration. Never overwrite previous rows.

## Output Format
Print: `Agent: {name} ({pattern}). Tools: {N}. Completion: {rate}%. Safety violations: {N}. Status: {DONE|PARTIAL}.`
