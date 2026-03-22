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
  - Data access: <what data the agent can read/write>

Constraints:
  - Max steps per task: <limit to prevent infinite loops>
  - Max tokens per task: <budget for entire agent run>
  - Max cost per task: <dollar budget>
  - Latency budget: <acceptable time for task completion>
  - Safety: <what the agent must NEVER do>
  - Reversibility: <which actions are reversible vs irreversible>

Success criteria:
  - Task completion rate: <target percentage>
  - Accuracy: <correctness of final output>
  - Efficiency: <avg steps to complete task>
  - Safety: <zero unsafe actions>
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
│                        │ Good for code generation, research.                  │
│                        │                                                      │
│ Multi-Agent            │ Complex tasks requiring diverse expertise. Multiple  │
│ (Collaboration)        │ specialized agents with a coordinator. Good for      │
│                        │ research, analysis, content creation.                │
│                        │                                                      │
│ Multi-Agent            │ Adversarial tasks or quality-critical output.        │
│ (Debate/Review)        │ One agent produces, another critiques. Good for      │
│                        │ writing, code review, decision-making.               │
│                        │                                                      │
│ Hierarchical           │ Enterprise workflows with delegation. Manager agent  │
│                        │ delegates subtasks to worker agents. Good for        │
│                        │ complex, multi-domain tasks.                         │
│                        │                                                      │
│ State Machine          │ Predictable workflows with defined states and        │
│                        │ transitions. Good for customer service, forms,       │
│                        │ structured processes.                                │
│                        │                                                      │
│ Router                 │ Query routing to specialized handlers. Good for      │
│                        │ multi-domain assistants where each domain has        │
│                        │ different tools and prompts.                         │
└────────────────────────┴──────────────────────────────────────────────────────┘

SELECTED: <Pattern> — <justification based on task complexity and requirements>
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
│    - Max steps reached -> return partial result + explanation       │
│    - Error threshold exceeded -> halt and report                    │
│    - Safety guardrail triggered -> halt immediately                 │
│    - User cancellation -> halt and save state                       │
└─────────────────────────────────────────────────────────────────────┘

Plan-and-Execute loop:
┌─────────────────────────────────────────────────────────────────────┐
│  1. PLAN: Generate ordered list of steps to accomplish task         │
│  2. for each step in plan:                                          │
│       a. EXECUTE: Run step using tools                              │
│       b. VERIFY: Check step output against expected result          │
│       c. REPLAN: If step failed or new info, revise remaining plan  │
│  3. SYNTHESIZE: Combine step results into final output              │
│                                                                     │
│  Replanning triggers:                                               │
│    - Step produces unexpected result                                │
│    - New information invalidates remaining plan                     │
│    - User provides additional context mid-execution                 │
└─────────────────────────────────────────────────────────────────────┘

Multi-Agent loop:
┌─────────────────────────────────────────────────────────────────────┐
│  COORDINATOR:                                                       │
│    1. Decompose task into sub-tasks                                 │
│    2. Assign sub-tasks to specialized agents                        │
│    3. Collect and integrate results                                 │
│    4. Resolve conflicts between agent outputs                       │
│    5. Synthesize final response                                     │
│                                                                     │
│  AGENT ROSTER:                                                      │
│  ┌──────────────┬────────────────┬────────────────────────────────┐ │
│  │ Agent        │ Specialization │ Tools                          │ │
│  ├──────────────┼────────────────┼────────────────────────────────┤ │
│  │ Researcher   │ Information    │ search, browse, RAG            │ │
│  │ Analyst      │ Data analysis  │ SQL, pandas, plotting          │ │
│  │ Writer       │ Content        │ text generation, formatting    │ │
│  │ Coder        │ Implementation │ code exec, file I/O, git       │ │
│  │ Reviewer     │ Quality        │ eval, critique, fact-check     │ │
│  └──────────────┴────────────────┴────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘

Loop parameters:
  Max steps: <N> (typical: 10-50 per task)
  Max tokens: <N> (budget for entire agent run)
  Max wall time: <seconds>
  Retry policy: <max retries per tool call, backoff strategy>
  Checkpoint frequency: <save state every N steps>
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
4. Predictable output: tool returns structured, consistent results
5. Error handling: tools return structured errors, never raw exceptions
6. Idempotency: read operations are idempotent; write operations report if repeated

TOOL SPECIFICATION (per tool):
Tool: <name>
Description: <1-2 sentence description for the LLM to understand when to use it>
Parameters:
  - <param_name>: <type> (<required|optional>) — <description>
  - <param_name>: <type> (<required|optional>) — <description>
Returns:
  Success: { "result": <type>, "metadata": { ... } }
  Error: { "error": <code>, "message": <description> }
Rate limits: <max calls per minute>
Side effects: <none | creates/modifies/deletes resource>
Confirmation required: <yes | no> (for irreversible actions)

Example:
  Tool: search_knowledge_base
  Description: "Search the internal knowledge base for relevant documents.
                Use this when the user asks a question about company policies,
                procedures, or technical documentation."
  Parameters:
    - query: string (required) — Natural language search query
    - filters: object (optional) — Metadata filters (department, date_range)
    - top_k: integer (optional, default=5) — Number of results to return
  Returns:
    Success: { "results": [{ "title": str, "content": str, "score": float, "source": str }] }
    Error: { "error": "INDEX_UNAVAILABLE", "message": "Knowledge base is being reindexed" }
  Rate limits: 30/min
  Side effects: none
  Confirmation required: no
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
│ Conversation memory │ Full conversation history, possibly summarized.      │
│ (session)           │ Stored in session store (Redis, database).           │
│                     │ Summarize older turns to fit context window.         │
│                     │                                                      │
│ Episodic memory     │ Past task executions and outcomes. "Last time I      │
│ (long-term)         │ tried X, it failed because Y." Stored as embeddings │
│                     │ in vector store, retrieved by similarity.            │
│                     │                                                      │
│ Semantic memory     │ Learned facts and knowledge. "User prefers Python." │
│ (long-term)         │ "The deploy process requires VPN." Stored as        │
│                     │ structured facts in database or vector store.        │
│                     │                                                      │
│ Procedural memory   │ Learned procedures and workflows. "To deploy, first │
│ (long-term)         │ run tests, then build, then push." Stored as        │
│                     │ step-by-step procedures, retrieved by task type.     │
└─────────────────────┴──────────────────────────────────────────────────────┘

Working memory management:
  Context window: <N tokens>
  Allocation:
    System prompt:       <N tokens> (fixed)
    Memory context:      <N tokens> (retrieved from long-term memory)
    Conversation history:<N tokens> (recent turns + summaries)
    Tool results:        <N tokens> (current step)
    Output reservation:  <N tokens>

  When context exceeds budget:
    1. Summarize oldest conversation turns
    2. Drop least-relevant tool results
    3. Compress memory context to key facts
    4. Never drop system prompt or current tool result

Long-term memory storage:
  Store: <vector DB for episodic/semantic | relational DB for structured facts>
  Retrieval: Query memory before each agent step
  Write-back: Save task outcomes after completion
  Decay: <forget old memories | keep all | relevance-based pruning>

Memory retrieval at each step:
  1. Query episodic memory: "Have I done a similar task before?"
  2. Query semantic memory: "What do I know about this user/domain?"
  3. Query procedural memory: "What is the standard procedure for this task type?"
  4. Inject top-K relevant memories into working context
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
  │ Guardrail                  │ Limit          │ On violation        │
  ├────────────────────────────┼────────────────┼─────────────────────┤
  │ Max steps per task         │ <N>            │ Halt, return partial│
  │ Max tokens per task        │ <N>            │ Halt, summarize     │
  │ Max cost per task          │ $<N>           │ Halt, notify user   │
  │ Max wall time              │ <seconds>      │ Halt, checkpoint    │
  │ Max consecutive errors     │ <N>            │ Halt, report errors │
  │ Tool call rate limit       │ <N/min>        │ Throttle            │
  │ Infinite loop detection    │ <same state N> │ Halt, report loop   │
  │ Irreversible action gate   │ Always         │ Require confirmation│
  └────────────────────────────┴────────────────┴─────────────────────┘

Layer 3 — Tool guardrails:
  ┌───────────────────────────────────────────────────────────────────┐
  │ Tool risk level │ Guardrail                                       │
  ├─────────────────┼─────────────────────────────────────────────────┤
  │ LOW (read-only) │ Rate limiting only                              │
  │ MEDIUM (write)  │ Validate parameters, log action, rate limit     │
  │ HIGH (code exec)│ Sandboxed execution, output validation, timeout │
  │ CRITICAL (delete)│ Require explicit user confirmation             │
  └─────────────────┴─────────────────────────────────────────────────┘

Layer 4 — Output guardrails:
  ┌───────────────────────────────────────────────────────────────────┐
  │ Check                      │ Action                              │
  ├────────────────────────────┼─────────────────────────────────────┤
  │ PII in output              │ Redact before returning to user     │
  │ Harmful content            │ Block, log, alert                   │
  │ Hallucinated citations     │ Validate against sources            │
  │ Confidential data leakage  │ Block, log, alert                   │
  │ Output format validation   │ Retry or return error               │
  └────────────────────────────┴─────────────────────────────────────┘

Layer 5 — Monitoring guardrails:
  - Log every agent step (thought, action, observation)
  - Alert on unusual patterns (high error rate, excessive tool calls)
  - Track cost per task, per user, per day
  - Human review queue for flagged interactions
  - Kill switch: ability to halt all agent tasks immediately

NEVER list (hardcoded, non-overridable):
  - Never execute arbitrary code from untrusted user input
  - Never access credentials or secrets directly
  - Never modify production data without confirmation
  - Never send external communications (email, Slack) without approval
  - Never share data between tenants
  - <domain-specific prohibitions>
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
│ Efficiency              │ <N>   │ Agent completes tasks within step budgets  │
│ Memory utilization      │ <N>   │ Agent correctly uses past context          │
│ Regression              │ <N>   │ Previously-fixed failure modes             │
└─────────────────────────┴───────┴────────────────────────────────────────────┘

Evaluation metrics:
  Task completion rate: <percentage of tasks completed correctly>
  Avg steps per task: <N> (lower is better, shows efficiency)
  Tool selection accuracy: <percentage of correct tool choices>
  Error recovery rate: <percentage of errors recovered without halting>
  Safety violation rate: <must be 0%>
  Guardrail trigger rate: <percentage of tasks hitting limits>
  Avg tokens per task: <N> (cost proxy)
  Avg latency per task: <seconds>
  User satisfaction: <rating if available>

Trajectory evaluation:
  For each test task, evaluate the full agent trajectory:
  1. Was each step necessary? (no redundant or circular steps)
  2. Was the tool choice optimal? (right tool for each sub-task)
  3. Was the reasoning correct? (thought process matches actions)
  4. Was the final answer correct and complete?
  5. Were safety guardrails respected?

VERDICT: <PASS | NEEDS IMPROVEMENT>
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
- Safety violation rate: <val> (must be 0%)
- Avg steps per task: <N>
- Avg latency per task: <seconds>

Artifacts:
- Config: config/agents/<agent>-config.yaml
- Implementation: src/agents/<agent>/
- Tools: src/agents/<agent>/tools/ (<N> tools)
- Tests: tests/agents/<agent>/ (<N> test cases)
- Docs: docs/agents/<agent>-architecture.md

Next steps:
-> /godmode:rag — Add knowledge retrieval as an agent tool
-> /godmode:prompt — Optimize the agent's reasoning prompt
-> /godmode:eval — Run comprehensive agent evaluation
-> /godmode:secure — Audit agent safety and guardrails
-> /godmode:deploy — Deploy the agent
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

## Example Usage

### Building a ReAct Agent
```
User: /godmode:agent Build an agent that can research topics and write reports

Agent: Starting discovery...

AGENT DISCOVERY:
Purpose: Research a topic using web search and knowledge base, then write a structured report
Type: Single-agent with tools
Interaction: Autonomous — user gives topic, agent returns report

ARCHITECTURE: ReAct (Reason + Act)
  Simple, well-understood, sufficient for sequential research tasks

TOOLS:
  1. web_search (read-only, LOW) — Search the web for information
  2. browse_url (read-only, LOW) — Read a specific web page
  3. search_knowledge_base (read-only, LOW) — Search internal docs
  4. write_section (write, MEDIUM) — Write a section of the report
  5. save_report (write, MEDIUM) — Save final report to file

MEMORY:
  Working: conversation context (current research state)
  Episodic: past research reports (similar topic retrieval)
  Semantic: learned facts about user preferences (format, depth, style)

GUARDRAILS:
  Max steps: 25
  Max tokens: 50,000
  Max time: 120 seconds
  Safety: No copyrighted content reproduction, cite all sources

EVALUATION (20 test topics):
  Task completion: 95%
  Source accuracy: 92%
  Report quality (LLM judge): 4.2/5
  Avg steps: 12
  Avg latency: 45 seconds

Verdict: PASS — Agent meets all targets.
```

### Designing a Multi-Agent System
```
User: /godmode:agent Build a multi-agent system for code review

Agent: ARCHITECTURE: Multi-Agent (Collaboration + Review)

AGENT ROSTER:
  1. Coordinator — Decomposes PR, assigns to specialists
  2. Security Reviewer — Vulnerabilities, injection, auth
  3. Performance Reviewer — N+1 queries, memory leaks
  4. Style Reviewer — Conventions, naming, documentation
  5. Test Reviewer — Coverage, edge cases, test quality
  6. Synthesizer — Combines reviews, ranks by severity

EVALUATION (30 test PRs):
  Finding recall: 87%, False positive rate: 12%
  Avg review time: 30s (vs 15 min human)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full agent development workflow |
| `--pattern <name>` | Force architecture: `react`, `plan-execute`, `reflexion`, `multi-agent`, `state-machine`, `router` |
| `--tools` | Design and inventory agent tools |
| `--memory` | Design agent memory system |
| `--guardrails` | Design safety guardrails |
| `--eval` | Run agent evaluation suite |
| `--trace <task>` | Show full agent trajectory for a task |
| `--debug` | Debug a failing agent task (step-by-step analysis) |
| `--multi` | Design multi-agent system |
| `--roster` | Show multi-agent roster and communication graph |
| `--optimize` | Optimize agent (reduce steps, improve tool selection) |
| `--cost` | Analyze and optimize agent cost per task |

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
    6. IF regression detected:
       - git revert the commit
       - Try alternative approach
    7. UPDATE issues_remaining

    IF current_iteration % 5 == 0:
        PRINT STATUS:
        "Iteration {current_iteration}/{max_iterations}"
        "Issues fixed: {total_issues - issues_remaining}/{total_issues}"
        "Test pass rate: {pass_rate}%"
        "Safety violations: {safety_violations} (must be 0)"

IF issues_remaining > 0:
    PRINT "Remaining issues require manual review: {issues_remaining}"
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. NEVER deploy an agent without guardrails defined first — safety before capabilities.
2. NEVER allow irreversible tool actions without explicit user confirmation gate.
3. EVERY agent loop MUST have a max_steps termination — no unbounded loops.
4. EVERY agent MUST have a cost budget (max tokens per task) — no runaway spending.
5. git commit BEFORE running evaluation — if eval reveals regression, revert.
6. Safety violation rate MUST be 0% — any safety failure is a blocking issue.
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
  6. Observability: grep -r "langsmith\|langfuse\|phoenix\|wandb\|helicone" package.json pyproject.toml 2>/dev/null

  USE detected context to:
    - Reuse existing LLM provider and framework (don't switch unless asked)
    - Match existing tool definition patterns
    - Identify gaps (no guardrails? no observability? no evaluation?)
    - Determine if building new agent or extending existing one
```

## Success Criteria
All of these must be true before marking the task complete:
1. Agent completes its target task end-to-end with correct output (verified on at least 3 test inputs).
2. Max steps termination works (agent stops at limit, does not loop forever).
3. Cost budget enforced (token counter tracks usage, agent stops when budget exceeded).
4. Guardrails block unsafe actions (test with at least one adversarial input that should be rejected).
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
| Safety guardrail triggered | Log the full context (input, intended action, guardrail rule matched). Do not bypass. Report to user with explanation of what was blocked and why. |
| LLM provider rate limited | Implement exponential backoff with jitter. If persistent, switch to fallback provider or queue the request. Never retry immediately in a tight loop. |
| Evaluation reveals regression | Compare trajectory diffs between versions. Identify which step diverged. Revert to last known good version. Fix the specific failure case and re-evaluate. |

## Multi-Agent Dispatch
```
Agent 1 (worktree: agent-core):
  - Implement agent loop with LLM provider and tool calling
  - Add max steps, token budget, and termination conditions
  - Build structured step logging

Agent 2 (worktree: agent-tools):
  - Define and implement all tools with input validation and error handling
  - Add confirmation gates for irreversible actions
  - Build tool result validators

Agent 3 (worktree: agent-safety):
  - Implement guardrail system (input validation, output filtering, action blocking)
  - Set up observability (tracing, cost tracking, latency monitoring)
  - Write evaluation suite with trajectory testing

MERGE ORDER: core -> tools -> safety
CONFLICT ZONES: agent loop integration, tool registry, guardrail middleware
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run agent tasks sequentially: core loop first, then tools, then guardrails and evaluation.
- Use branch isolation per task: `git checkout -b godmode-agent-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.

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

## Anti-Patterns

- **Do NOT build agents without guardrails.** Define limits (max steps, cost budget, confirmation gates) before writing capabilities.
- **Do NOT give agents tools they do not need.** Fewer well-designed tools beat many vague tools.
- **Do NOT skip trajectory evaluation.** A correct answer from a broken reasoning path will fail on the next different input.
- **Do NOT let agents take irreversible actions without confirmation.** Delete, send, deploy, pay require human approval.
- **Do NOT ignore cost.** Track tokens per task and set budgets. Agent loops with large models are expensive.
- **Do NOT build multi-agent systems when a single agent suffices.** Start with one agent. Add more only when one cannot handle the task.
- **Do NOT hardcode agent behavior.** System prompt, tool inventory, and guardrails should be configurable.
- **Do NOT deploy without observability.** If you cannot trace every step, you cannot debug failures.
