# /godmode:gamedev

Game development architecture covering game loop design, entity-component systems, physics and collision detection, asset pipeline management, engine selection, and performance optimization. Supports Unity, Unreal, Godot, Bevy, Three.js, Phaser, and custom engines.

## Usage

```
/godmode:gamedev                           # Full game architecture audit
/godmode:gamedev --engine-select           # Engine/framework selection guidance
/godmode:gamedev --ecs                     # ECS architecture design and setup
/godmode:gamedev --physics                 # Physics and collision system audit
/godmode:gamedev --assets                  # Asset pipeline audit and optimization
/godmode:gamedev --perf                    # Game performance profiling
/godmode:gamedev --loop                    # Game loop design and timing analysis
/godmode:gamedev --systems                 # Core game systems checklist
/godmode:gamedev --multiplayer             # Multiplayer architecture guidance
/godmode:gamedev --mobile                  # Mobile game optimization focus
```

## What It Does

1. Analyzes game project context (genre, platform, engine, rendering mode)
2. Selects architecture pattern (ECS, component-based, scene graph)
3. Designs game loop with fixed timestep and interpolation
4. Implements physics and collision detection pipeline (broad + narrow phase)
5. Sets up asset pipeline (source -> runtime conversion, compression, loading)
6. Guides engine/framework selection based on project requirements
7. Profiles and optimizes performance (frame timing, draw calls, memory)
8. Implements common game systems (state machines, input, audio, save/load)

## Output
- Architecture report at `docs/gamedev/<project>-architecture.md`
- Scaffold commit: `"gamedev: scaffold <architecture> game architecture"`
- System commit: `"gamedev: implement <system> — <details>"`
- Performance report with frame timing breakdown

## Key Principles

1. **Fixed timestep** — physics and game logic run at a fixed rate, rendering interpolates
2. **Profile before optimizing** — the bottleneck is never where you think
3. **Object pooling** — never allocate in the game loop (GC = frame stutter)
4. **Separate logic from rendering** — enables headless testing, replays, multiplayer
5. **Budget every resource** — frame time, draw calls, memory, particles

## Next Step
After architecture: `/godmode:three` for 3D web, `/godmode:animation` for motion, `/godmode:test` for game tests, or `/godmode:perf` for profiling.

## Examples

```
/godmode:gamedev                           # Full architecture review
/godmode:gamedev --engine-select           # Choose the right engine
/godmode:gamedev --ecs                     # Design entity-component system
/godmode:gamedev --perf                    # Profile and optimize FPS
```
