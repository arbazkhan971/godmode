# /godmode:state

State management design and implementation. Classifies state by category, selects the right tools (Redux, Zustand, Jotai, MobX, React Query, SWR, XState), designs store architecture, implements optimistic updates, cache synchronization, persistence, and SSR hydration.

## Usage

```
/godmode:state                                # Interactive state management design
/godmode:state --audit                        # Audit current state architecture
/godmode:state --classify                     # Classify all state by category
/godmode:state --migrate                      # Migration plan between state libraries
/godmode:state --optimistic                   # Design optimistic update patterns
/godmode:state --machine                      # Design a state machine (XState)
/godmode:state --persist                      # Set up state persistence and hydration
/godmode:state --ssr                          # SSR-compatible state with hydration
/godmode:state --realtime                     # Real-time state sync (WebSocket/SSE)
/godmode:state --devtools                     # Configure state debugging tools
/godmode:state --selectors                    # Optimize selectors to prevent re-renders
/godmode:state --report                       # Full state architecture report
```

## What It Does

1. Audits current state management (libraries, patterns, pain points)
2. Classifies state by category (server, client UI, client domain, form, URL, persisted, computed, machine)
3. Selects the right tool for each category with comparison matrix
4. Designs store architecture (structure, selectors, actions)
5. Implements server state caching with React Query/SWR (query keys, staleness, invalidation)
6. Designs optimistic updates with rollback on error
7. Builds state machines for complex workflows (XState)
8. Configures persistence and SSR hydration
9. Sets up real-time cache synchronization

## Output
- State classification report (what goes where)
- Store architecture design (structure, query keys, selectors)
- Implementation code (store definitions, hooks, machines)
- Commit: `"state: design <description> state architecture"`

## Next Step
After state design: `/godmode:schema` to design the data models backing the state, or `/godmode:orm` to optimize data access.

## Examples

```
/godmode:state I need state management for a dashboard with real-time updates
/godmode:state --audit                        # What's wrong with our current state?
/godmode:state --migrate                      # Migrate from Redux to React Query + Zustand
/godmode:state --machine                      # Design checkout flow state machine
/godmode:state --optimistic                   # Add optimistic updates to mutations
```
