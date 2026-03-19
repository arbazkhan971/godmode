---
name: gamedev
description: |
  Game development skill. Activates when user needs to architect game systems, implement game loops, design entity-component systems, manage physics and collision, set up asset pipelines, or optimize game performance. Covers Unity, Unreal, Godot, Bevy, Three.js, Phaser, and custom engines. Triggers on: /godmode:gamedev, "game architecture", "game loop", "ECS", "collision detection", "game performance", or when building interactive games.
---

# Gamedev — Game Development Architecture

## When to Activate
- User invokes `/godmode:gamedev`
- User says "game architecture," "game loop," "ECS," "entity component system"
- When designing or building a game from scratch
- When choosing a game engine or framework
- When implementing physics, collision detection, or input handling
- When managing game assets (sprites, models, audio, levels)
- When optimizing game performance (FPS, draw calls, memory, LOD)

## Workflow

### Step 1: Analyze Game Project Context
Survey the game project requirements and current state:

```
GAME PROJECT ANALYSIS:
Genre: <platformer/RPG/puzzle/FPS/strategy/simulation/other>
Platform targets: <web/desktop/mobile/console>
Engine/framework: <Unity/Unreal/Godot/Bevy/Three.js/Phaser/custom>
Language: <C#/C++/GDScript/Rust/TypeScript/JavaScript>
Rendering: <2D/3D/isometric/hybrid>
Multiplayer: <none/local/online/MMO>

Project state:
  Prototype: <yes/no>
  Core loop: <defined/undefined>
  Asset pipeline: <established/partial/none>
  Build pipeline: <established/partial/none>

Target performance:
  FPS: <30/60/120/unlocked>
  Target devices: <spec>
  Memory budget: <MB>
  Load time budget: <seconds>
```

### Step 2: Architecture Pattern Selection
Choose the right architecture for the game's needs:

#### Entity-Component-System (ECS)
```
ECS ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│ Entities     │ Lightweight IDs — no data, no behavior           │
│ Components   │ Pure data structs — Position, Velocity, Sprite   │
│ Systems      │ Logic that operates on component sets            │
└─────────────────────────────────────────────────────────────────┘

When to use ECS:
- Large number of entities (> 1000 active)
- Entities share behaviors in varied combinations
- Cache-friendly performance is critical
- Systems need to run in parallel

ECS implementation checklist:
- [ ] Entity manager with ID recycling
- [ ] Component storage (sparse set, archetype, or dense array)
- [ ] System scheduler with dependency ordering
- [ ] World queries (entity iteration by component set)
- [ ] Event/message bus for cross-system communication
- [ ] Serialization for save/load

Frameworks:
  Unity: DOTS (Burst + Jobs + Entities)
  Bevy: Built-in ECS (archetype-based)
  Custom: EnTT (C++), hecs (Rust), bitECS (JS), ecsy (JS)
```

#### Component-Based Architecture
```
COMPONENT-BASED ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│ GameObject      │ Container with transform + component list     │
│ Component       │ Data + behavior attached to a game object     │
│ Prefab          │ Reusable game object template                 │
└─────────────────────────────────────────────────────────────────┘

When to use component-based:
- Moderate entity count (< 1000)
- Rapid iteration and designer-friendly
- Rich per-entity behavior differences
- Unity MonoBehaviour, Godot Node, Unreal Actor+Component

Component quality checklist:
- [ ] Single responsibility per component
- [ ] No direct references to sibling components (use GetComponent/signals)
- [ ] Serializable fields for editor tweaking
- [ ] Initialize in Awake/Ready, subscribe in OnEnable, cleanup in OnDisable
- [ ] No Update() for components that rarely change (use events)
```

#### Scene Graph Architecture
```
SCENE GRAPH ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│ Root Node       │ Top-level scene container                     │
│ Branch Nodes    │ Transform groups, layers, cameras             │
│ Leaf Nodes      │ Meshes, sprites, lights, audio sources        │
└─────────────────────────────────────────────────────────────────┘

When to use scene graph:
- 3D rendering with hierarchical transforms
- Camera management with multiple viewports
- UI overlay systems
- Three.js, Godot, Babylon.js, PlayCanvas
```

#### Architecture Decision Matrix
```
ARCHITECTURE DECISION:
┌─────────────────────────────────────────────────────────────────────┐
│ Factor              │ ECS        │ Component  │ Scene Graph        │
├─────────────────────────────────────────────────────────────────────┤
│ Entity count        │ 1000+      │ < 1000     │ Varies             │
│ Cache performance   │ Excellent  │ Moderate   │ Moderate           │
│ Iteration speed     │ Moderate   │ Fast       │ Fast               │
│ Designer-friendly   │ Low        │ High       │ High               │
│ Parallel execution  │ Natural    │ Manual     │ Difficult          │
│ Learning curve      │ Steep      │ Moderate   │ Moderate           │
│ Serialization       │ Efficient  │ Per-object │ Tree-based         │
│ Best for            │ Simulations│ Action/RPG │ 3D visualization   │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 3: Game Loop Design
Implement the core game loop with proper timing:

#### Fixed Timestep Game Loop
```
GAME LOOP — FIXED TIMESTEP:

const FIXED_DT = 1 / 60;       // 60 Hz physics
let accumulator = 0;
let previousTime = performance.now();

function gameLoop(currentTime) {
  const frameTime = Math.min((currentTime - previousTime) / 1000, 0.25); // cap spiral of death
  previousTime = currentTime;
  accumulator += frameTime;

  // Input — poll once per frame
  inputSystem.poll();

  // Fixed update — deterministic physics
  while (accumulator >= FIXED_DT) {
    physicsSystem.update(FIXED_DT);
    gameLogicSystem.update(FIXED_DT);
    accumulator -= FIXED_DT;
  }

  // Interpolation factor for smooth rendering
  const alpha = accumulator / FIXED_DT;

  // Render — variable timestep with interpolation
  renderSystem.draw(alpha);

  requestAnimationFrame(gameLoop);
}

LOOP PHASES:
┌──────────┬──────────────┬─────────────┬──────────────┐
│  Input   │ Fixed Update │  Late Update│   Render     │
│  (1x)    │ (Nx @ 60Hz) │   (1x)      │  (1x @ VSync)│
├──────────┼──────────────┼─────────────┼──────────────┤
│ Keyboard │ Physics      │ Camera      │ Interpolate  │
│ Mouse    │ Collision    │ UI layout   │ Draw calls   │
│ Gamepad  │ AI           │ Animation   │ Post-process │
│ Touch    │ Game logic   │ Audio       │ Present      │
└──────────┴──────────────┴─────────────┴──────────────┘
```

#### Timing Considerations
```
TIMING CHECKLIST:
- [ ] Fixed timestep for physics (deterministic simulation)
- [ ] Frame time capped to prevent spiral of death (max 250ms)
- [ ] Interpolation between physics states for smooth rendering
- [ ] Delta time never used directly for physics (use fixed dt)
- [ ] Time scale support for pause/slow-motion
- [ ] Frame-independent input (buffer inputs, process in fixed update)
- [ ] VSync awareness (render at monitor refresh rate)
```

### Step 4: Physics & Collision Detection
Implement physics simulation and collision handling:

#### Collision Detection Pipeline
```
COLLISION DETECTION PIPELINE:
┌────────────────────────────────────────────────────────────────┐
│ Phase            │ Purpose              │ Complexity            │
├────────────────────────────────────────────────────────────────┤
│ 1. Broad phase   │ Find potential pairs │ O(n log n)           │
│    - Spatial hash │ Grid-based           │ Best for uniform     │
│    - Quadtree/Oct│ Hierarchical         │ Best for varied sizes│
│    - Sweep & prune│ Sorted axis         │ Best for moving objs │
│    - BVH          │ Bounding volumes    │ Best for static scene│
│                                                                │
│ 2. Narrow phase  │ Exact intersection   │ O(pairs)             │
│    - AABB vs AABB│ Axis-aligned box     │ Cheapest             │
│    - Circle/Sphere│ Distance check      │ Fast                 │
│    - SAT          │ Separating axis     │ Convex polygons      │
│    - GJK+EPA     │ General convex      │ Complex but robust   │
│                                                                │
│ 3. Resolution    │ Separate & respond   │ O(contacts)          │
│    - Position fix│ Push apart           │ Projection           │
│    - Velocity fix│ Bounce/friction      │ Impulse-based        │
│    - Constraints │ Joints, limits       │ Iterative solver     │
└────────────────────────────────────────────────────────────────┘

Collision layers:
  Player   = 0b0001
  Enemy    = 0b0010
  Bullet   = 0b0100
  Terrain  = 0b1000

  Player collides with: Enemy | Terrain
  Bullet collides with: Enemy | Terrain
  Enemy collides with: Player | Bullet | Terrain
```

#### Physics Libraries
```
PHYSICS LIBRARY SELECTION:
┌────────────────────────────────────────────────────────────────┐
│ Engine/Framework │ Built-in Physics    │ Alternative            │
├────────────────────────────────────────────────────────────────┤
│ Unity            │ PhysX (3D), Box2D   │ Havok (DOTS)          │
│ Unreal           │ Chaos Physics       │ PhysX (legacy)        │
│ Godot            │ GodotPhysics, Jolt  │ Box2D (2D)            │
│ Bevy             │ Rapier (via plugin) │ —                      │
│ Three.js         │ None                │ Rapier, Cannon-es     │
│ Phaser           │ Arcade, Matter.js   │ Planck.js (Box2D)     │
│ Custom (C++)     │ —                   │ Box2D, Bullet, Jolt   │
│ Custom (Rust)    │ —                   │ Rapier                │
│ Custom (JS)      │ —                   │ Matter.js, p2.js      │
└────────────────────────────────────────────────────────────────┘
```

### Step 5: Asset Pipeline Management
Set up efficient asset workflows:

```
ASSET PIPELINE:
┌────────────────────────────────────────────────────────────────┐
│ Asset Type    │ Source Format │ Runtime Format │ Tool           │
├────────────────────────────────────────────────────────────────┤
│ 2D sprites    │ PSD/Aseprite │ Atlas (PNG+JSON)│ TexturePacker │
│ 3D models     │ FBX/Blend    │ GLTF/GLB       │ Blender export│
│ Textures      │ PSD/TIFF     │ KTX2/Basis     │ KTX-Software  │
│ Audio SFX     │ WAV          │ OGG/WebM/MP3   │ FFmpeg/Audacity│
│ Music         │ WAV/FLAC     │ OGG/AAC stream │ FFmpeg         │
│ Levels        │ Tiled/Editor │ JSON/Binary    │ Custom export  │
│ Fonts         │ OTF/TTF      │ MSDF/BMFont    │ msdf-atlas-gen│
│ Shaders       │ GLSL/HLSL    │ SPIRV/compiled │ shaderc/DXC   │
│ Animations    │ FBX/Spine    │ JSON/Binary    │ Spine/DragonBones│
└────────────────────────────────────────────────────────────────┘

ASSET PIPELINE CHECKLIST:
- [ ] Source assets in version control (Git LFS for large files)
- [ ] Automated conversion from source to runtime format
- [ ] Texture atlasing for 2D (reduce draw calls)
- [ ] Texture compression for target platform (ASTC mobile, BC desktop)
- [ ] Audio compression with appropriate quality per type
- [ ] Asset manifest with checksums for cache invalidation
- [ ] Hot-reload support in development builds
- [ ] Asset bundles/chunks for streaming and lazy loading
- [ ] Size budget per asset category
- [ ] Naming convention enforced (lowercase, kebab-case, category prefix)
```

#### Asset Loading Strategy
```
LOADING STRATEGY:
┌────────────────────────────────────────────────────────────────┐
│ Strategy        │ When                │ Implementation          │
├────────────────────────────────────────────────────────────────┤
│ Eager (upfront) │ Small games         │ Load all at startup    │
│ Level-based     │ Linear progression  │ Load per level/scene   │
│ Streaming       │ Open world          │ Load by proximity      │
│ On-demand       │ Web games           │ Load when first needed │
│ Predictive      │ Story-driven        │ Preload next likely    │
└────────────────────────────────────────────────────────────────┘

Loading screen requirements:
- [ ] Progress bar with real percentage (not fake animation)
- [ ] Async loading (never block main thread)
- [ ] Priority queue (gameplay-critical assets first)
- [ ] Fallback/placeholder assets while loading
- [ ] Cancel/interrupt support for scene changes
- [ ] Memory budget enforcement (unload before loading)
```

### Step 6: Engine/Framework Selection
Guide engine choice based on project needs:

```
ENGINE DECISION MATRIX:
┌────────────────────────────────────────────────────────────────────────┐
│ Factor          │ Unity     │ Unreal    │ Godot    │ Bevy     │ Web    │
├────────────────────────────────────────────────────────────────────────┤
│ 2D support      │ Good      │ Basic     │ Excellent│ Good     │ Best   │
│ 3D support      │ Good      │ Excellent │ Good     │ Growing  │ Good   │
│ Learning curve  │ Moderate  │ Steep     │ Easy     │ Steep    │ Varies │
│ Performance     │ Good      │ Excellent │ Good     │ Excellent│ Limited│
│ Language        │ C#        │ C++/BP    │ GDScript │ Rust     │ JS/TS  │
│ Mobile          │ Yes       │ Yes       │ Yes      │ No       │ Web    │
│ Console         │ Yes       │ Yes       │ Partial  │ No       │ No     │
│ Open source     │ No        │ Source avl│ Yes      │ Yes      │ Yes    │
│ Asset store     │ Large     │ Large     │ Growing  │ Small    │ npm    │
│ Team size       │ Any       │ Medium+   │ Small    │ Small    │ Any    │
│ Cost            │ Revenue   │ Royalty   │ Free     │ Free     │ Free   │
│ VR/AR           │ Good      │ Good      │ Partial  │ Partial  │ WebXR  │
├────────────────────────────────────────────────────────────────────────┤
│ Best for        │ Mobile,   │ AAA,      │ Indie,   │ Custom   │ Casual,│
│                 │ indie     │ FPS       │ 2D, jam  │ perf-crit│ browser│
└────────────────────────────────────────────────────────────────────────┘

Web game frameworks:
  Three.js — 3D rendering, custom game architecture
  Phaser — 2D games, arcade physics, rich plugin ecosystem
  PixiJS — 2D rendering, build your own game framework
  PlayCanvas — 3D engine with web editor
  Babylon.js — 3D engine with physics and XR
  Excalibur — TypeScript-first 2D game engine
  Kaplay (Kaboom) — Simple 2D game library
```

### Step 7: Game Performance Optimization
Profile and optimize for target frame rates:

```
PERFORMANCE BUDGET:
┌────────────────────────────────────────────────────────────────┐
│ Target FPS    │ Frame budget │ Typical allocation              │
├────────────────────────────────────────────────────────────────┤
│ 30 FPS        │ 33.3ms      │ Game: 20ms, Render: 10ms, OS: 3ms│
│ 60 FPS        │ 16.6ms      │ Game: 8ms, Render: 6ms, OS: 2ms │
│ 120 FPS       │ 8.3ms       │ Game: 4ms, Render: 3ms, OS: 1ms │
└────────────────────────────────────────────────────────────────┘

OPTIMIZATION CHECKLIST:
CPU:
- [ ] Profile before optimizing (use engine profiler)
- [ ] Object pooling (avoid allocation in game loop)
- [ ] Spatial partitioning for queries (grid, quadtree, BVH)
- [ ] LOD for AI/logic (reduce update frequency for distant entities)
- [ ] Job system for parallel work (physics, pathfinding, AI)
- [ ] Cache-friendly data layout (struct of arrays for hot paths)
- [ ] Avoid GC pressure (pool, preallocate, avoid closures in loops)

GPU / Rendering:
- [ ] Draw call batching (< 100 for mobile, < 1000 for desktop)
- [ ] Texture atlasing (reduce texture switches)
- [ ] Level of Detail (LOD) for 3D meshes
- [ ] Frustum culling (don't render off-screen objects)
- [ ] Occlusion culling (don't render hidden objects)
- [ ] Shader complexity audit (avoid branching, reduce ALU)
- [ ] Resolution scaling for performance headroom
- [ ] Particle system budgets (max particles per emitter/scene)

Memory:
- [ ] Asset streaming (don't load everything at once)
- [ ] Texture compression per platform (ASTC, BC, ETC2)
- [ ] Mesh compression (Draco, Meshopt)
- [ ] Audio streaming for music (don't decode entire files)
- [ ] Memory budgets per category (textures, meshes, audio, code)
- [ ] Leak detection (track allocations in debug builds)

Network (multiplayer):
- [ ] Delta compression (send only changes)
- [ ] Client-side prediction with server reconciliation
- [ ] Entity interpolation for smooth remote entities
- [ ] Bandwidth budget per tick (< 10KB/s for mobile)
- [ ] Priority queue (critical state > cosmetic updates)
```

#### Frame Timing Analysis
```
FRAME TIMING REPORT:
┌────────────────────────────────────────────────────────────────┐
│ Phase              │ Budget   │ Actual   │ Status              │
├────────────────────────────────────────────────────────────────┤
│ Input polling      │ 0.5ms    │ <X>ms    │ OK / OVER          │
│ Physics (fixed)    │ 3.0ms    │ <X>ms    │ OK / OVER          │
│ Game logic         │ 3.0ms    │ <X>ms    │ OK / OVER          │
│ AI / pathfinding   │ 2.0ms    │ <X>ms    │ OK / OVER          │
│ Animation          │ 1.0ms    │ <X>ms    │ OK / OVER          │
│ Render submission  │ 2.0ms    │ <X>ms    │ OK / OVER          │
│ GPU render         │ 4.0ms    │ <X>ms    │ OK / OVER          │
│ Post-processing    │ 1.0ms    │ <X>ms    │ OK / OVER          │
├────────────────────────────────────────────────────────────────┤
│ Total              │ 16.6ms   │ <X>ms    │ TARGET MET / MISSED│
│ Draw calls         │ < 500    │ <X>      │ OK / OVER          │
│ Triangles          │ < 500K   │ <X>      │ OK / OVER          │
│ Texture memory     │ < 256MB  │ <X>MB    │ OK / OVER          │
└────────────────────────────────────────────────────────────────┘
```

### Step 8: Game-Specific Patterns
Common patterns across game development:

#### State Machine (Game States, AI, Animation)
```
STATE MACHINE PATTERNS:
Finite State Machine (FSM):
  Idle -> Walk -> Run -> Jump -> Fall -> Land -> Idle
  Each state: enter(), update(dt), exit()
  Transitions: condition-based with optional guards

Hierarchical State Machine (HFSM):
  Combat
    ├── Melee
    │   ├── Attack
    │   ├── Block
    │   └── Dodge
    └── Ranged
        ├── Aim
        ├── Fire
        └── Reload
  Super-state handles shared behavior (damage, death)

Behavior Tree (AI):
  Selector (OR — try until one succeeds)
  ├── Sequence (AND — all must succeed)
  │   ├── HasTarget?
  │   ├── InRange?
  │   └── Attack
  ├── Sequence
  │   ├── HasTarget?
  │   └── MoveTo(target)
  └── Patrol
```

#### Common Game Systems
```
SYSTEM CHECKLIST:
- [ ] Input system (rebindable, multi-device, action maps)
- [ ] Camera system (follow, shake, zoom, cinematic)
- [ ] Audio system (spatial, music layers, SFX pooling)
- [ ] Save/load system (serialization, versioning, migration)
- [ ] UI system (menus, HUD, inventory, dialogue)
- [ ] Particle system (pooled emitters, world vs local space)
- [ ] Tween/animation system (easing, sequences, callbacks)
- [ ] Event/message system (decouple systems, command pattern)
- [ ] Localization system (string tables, pluralization)
- [ ] Achievement/progression system (conditions, persistence)
- [ ] Debug tools (console, gizmos, time control, inspector)
```

### Step 9: Recommendations Report

```
+------------------------------------------------------------+
|  GAME ARCHITECTURE REPORT — <project>                       |
+------------------------------------------------------------+
|  Genre: <genre>                                             |
|  Engine: <engine/framework>                                 |
|  Architecture: <ECS/Component/Scene Graph>                  |
|  Target: <platform(s)> @ <target FPS>                       |
|                                                             |
|  Systems Status:                                            |
|  Core loop:       <implemented/missing>                     |
|  Physics:         <engine built-in/custom/library>          |
|  Asset pipeline:  <automated/manual/missing>                |
|  Input handling:  <robust/basic/missing>                    |
|  Audio:           <spatial/basic/missing>                   |
|  Save system:     <versioned/basic/missing>                 |
|                                                             |
|  Performance:                                               |
|  Frame time:      <X>ms / <budget>ms                       |
|  Draw calls:      <X> / <budget>                            |
|  Memory:          <X>MB / <budget>MB                        |
|                                                             |
|  Priority Actions:                                          |
|  1. <highest impact improvement>                            |
|  2. <second improvement>                                    |
|  3. <third improvement>                                     |
+------------------------------------------------------------+
```

### Step 10: Commit and Transition
1. If architecture was set up:
   - Commit: `"gamedev: scaffold <architecture> game architecture for <project>"`
2. If systems were implemented:
   - Commit: `"gamedev: implement <system> — <details>"`
3. If performance was optimized:
   - Commit: `"gamedev: optimize <area> — <metric before> -> <metric after>"`
4. Save report: `docs/gamedev/<project>-architecture.md`
5. Transition: "Game architecture ready. Run `/godmode:three` for 3D web, `/godmode:animation` for motion design, or `/godmode:test` to add game tests."

## Key Behaviors

1. **Fixed timestep is non-negotiable.** Physics and game logic run at a fixed rate. Variable timestep for physics creates non-deterministic behavior, impossible-to-reproduce bugs, and speed-dependent gameplay. Cap frame time to prevent spiral of death.
2. **Profile before optimizing.** The bottleneck is never where you think it is. Use the engine profiler, measure frame timing per phase, and fix the actual hotspot. Premature optimization in games wastes time on systems that are already fast enough.
3. **Object pooling for anything created at runtime.** Bullets, particles, enemies, VFX, audio sources. Allocation in the game loop causes GC spikes that show up as frame stutters. Pre-allocate and recycle.
4. **Separate game logic from rendering.** The simulation must be independent of the frame rate. This enables headless servers, replay systems, deterministic lockstep multiplayer, and automated testing.
5. **Design for iteration speed.** Hot-reload assets, tweak values without recompiling, visual debugging tools, level editors. The game will be iterated on 100x more than it is architected. Optimize for the common case: tweaking and testing.
6. **Collision layers prevent combinatorial explosion.** Not everything needs to collide with everything. Define layers, define which layers interact, and the physics engine skips impossible pairs automatically.
7. **Budget every resource.** Frame time, draw calls, memory, audio channels, particle counts. Set budgets at project start and enforce them. A game that runs well on the target hardware is a game that ships.

## Example Usage

### Full game architecture review
```
User: /godmode:gamedev

Gamedev: Analyzing game project...

GAME PROJECT ANALYSIS:
Genre: 2D platformer
Engine: Phaser 3 (TypeScript)
Architecture: Scene-based with component mixin pattern
Target: Web (mobile + desktop) @ 60 FPS

Systems Status:
Core loop:       Phaser built-in (fixed update supported)
Physics:         Arcade Physics (AABB only)
Asset pipeline:  Manual (no atlasing, no compression)
Input handling:  Basic keyboard only (no gamepad)
Audio:           Howler.js (no spatial audio)
Save system:     localStorage (no versioning)

FINDING 1: No texture atlasing — 47 individual sprite loads = 47 draw calls
  Recommendation: Use TexturePacker to generate sprite atlases

FINDING 2: Physics using Arcade (AABB) but level has slopes
  Recommendation: Switch to Matter.js for polygon collision

FINDING 3: No object pooling for bullets/particles
  Recommendation: Implement pool with pre-allocated instances

Priority Actions:
1. Texture atlas generation (reduce draw calls from 47 to ~4)
2. Object pooling for projectiles and particles
3. Matter.js migration for slope collision support

Verdict: FUNCTIONAL but not production-optimized.
```

### Engine selection consultation
```
User: /godmode:gamedev --engine-select

Gamedev: Gathering project requirements...

Requirements:
- 3D first-person puzzle game
- PC and Mac release
- Solo developer
- No multiplayer
- Moderate visual fidelity

Recommendation: Godot 4 with GDScript

Justification:
- Free with no royalties (solo dev budget)
- GDScript is fastest for iteration (solo dev velocity)
- 3D pipeline is mature in Godot 4
- Built-in editor tools reduce external dependencies
- Active community for puzzle game references

Alternative: Unity (larger asset store, more tutorials)
Avoid: Unreal (overkill for puzzle game, steep solo learning curve)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full game architecture audit |
| `--engine-select` | Engine/framework selection guidance |
| `--ecs` | ECS architecture design and setup |
| `--physics` | Physics and collision system audit |
| `--assets` | Asset pipeline audit and optimization |
| `--perf` | Game performance profiling and optimization |
| `--loop` | Game loop design and timing analysis |
| `--systems` | Core game systems checklist and audit |
| `--multiplayer` | Multiplayer architecture guidance |
| `--mobile` | Mobile game optimization focus |

## Auto-Detection

On activation, automatically detect the game project context:

```
AUTO-DETECT SEQUENCE:
1. Detect engine: Unity (*.unity, *.cs, ProjectSettings/), Unreal (*.uproject, *.cpp), Godot (project.godot, *.gd), Bevy (Cargo.toml with bevy dep)
2. Detect web framework: Phaser (phaser in package.json), Three.js, PixiJS, Babylon.js, PlayCanvas, Excalibur
3. Check rendering type: 2D (sprite assets, tilemap files) vs 3D (model files, shader assets)
4. Detect physics: Box2D, Matter.js, Rapier, PhysX, custom collision code
5. Scan for asset pipeline: TexturePacker configs, Aseprite files, Blender exports, atlases
6. Check for ECS patterns: archetype queries, component structs, system functions
7. Detect multiplayer: networking libraries, WebSocket connections, state sync code
8. Identify build pipeline: webpack/vite for web, Xcode/Gradle for mobile, engine build settings
9. Check for performance tooling: profiler configs, frame budget constants, LOD settings
10. Detect platform targets from build configs or engine settings
```

## Explicit Loop Protocol

When implementing multiple game systems iteratively:

```
GAME SYSTEM BUILD LOOP:
current_iteration = 0
systems = [input, physics, camera, audio, save_load, UI, ...]  // from analysis

WHILE current_iteration < len(systems) AND NOT user_says_stop:
  1. SELECT next system by priority (core loop systems first)
  2. DESIGN system architecture (ECS system, component, or manager pattern)
  3. IMPLEMENT system with fixed timestep awareness (physics) or variable (rendering)
  4. INTEGRATE with existing systems (event bus connections, component dependencies)
  5. TEST system in isolation AND in game loop context
  6. PROFILE: measure frame time contribution, compare against budget
  7. IF over budget: OPTIMIZE before proceeding (object pooling, spatial partitioning, etc.)
  8. current_iteration += 1
  9. REPORT: "System <N>/<total>: <name> — <frame_time>ms / <budget>ms"

ON COMPLETION:
  RUN full frame timing analysis (Step 7)
  REPORT: "<N> systems, total frame time: <X>ms / <budget>ms, <M> over budget"
```

## Multi-Agent Dispatch

For large game projects, dispatch parallel agents per domain:

```
PARALLEL GAMEDEV AGENTS:
When building multiple game systems simultaneously:

Agent 1 (worktree: game-core):
  - Implement core game loop with fixed timestep
  - Build input system (rebindable, multi-device)
  - Implement entity/component management (ECS or component-based)
  - Set up event/message bus for cross-system communication

Agent 2 (worktree: game-rendering):
  - Set up rendering pipeline (sprites, meshes, shaders)
  - Implement camera system (follow, shake, zoom)
  - Build particle system with object pooling
  - Optimize draw calls (atlasing, batching, culling)

Agent 3 (worktree: game-gameplay):
  - Implement physics and collision detection
  - Build AI systems (state machines, behavior trees)
  - Implement save/load system with versioned serialization
  - Create UI system (menus, HUD, inventory)

MERGE STRATEGY: Core merges first (other systems depend on game loop and events).
  Rendering and gameplay merge independently (minimal overlap).
  Final: run full frame timing profiler on target hardware.
```

## Hard Rules

```
HARD RULES — GAMEDEV:
1. ALWAYS use fixed timestep for physics and game logic. Variable timestep = frame-rate-dependent gameplay.
2. NEVER allocate in the game loop. new Bullet(), new Array(), closures in loops all cause GC stutter. Pool everything.
3. ALWAYS cap frame time to prevent spiral of death (max 250ms per frame).
4. NEVER put game logic in the render function. Simulation must be independent of frame rate.
5. ALWAYS use collision layers and masks. Checking every entity against every other is O(n^2).
6. NEVER hardcode input bindings. Use action mapping so controls are rebindable and multi-device.
7. ALWAYS profile on minimum-spec target hardware, not just development machine.
8. ALWAYS set frame time budgets per system BEFORE building. Measure against budget continuously.
9. NEVER skip object pooling for anything created at runtime (bullets, particles, enemies, VFX, audio sources).
10. ALWAYS separate game state from rendering state. This enables headless servers, replays, and deterministic lockstep.
```

## Anti-Patterns

- **Do NOT use variable timestep for physics.** `position += velocity * deltaTime` creates frame-rate-dependent behavior. A player running at 30 FPS will jump differently than one at 60 FPS. Use fixed timestep with interpolation.
- **Do NOT allocate in the game loop.** `new Bullet()` every frame triggers garbage collection. Pool objects, pre-allocate arrays, reuse instances. GC pauses are frame stutters.
- **Do NOT skip the broad phase.** Checking every entity against every other entity is O(n^2). Use spatial hashing, quadtrees, or sweep-and-prune to reduce collision pairs before narrow-phase testing.
- **Do NOT put game logic in the render function.** Rendering should only read state and draw. Game logic in render creates frame-rate-dependent behavior and makes headless testing impossible.
- **Do NOT hardcode input bindings.** `if (key === 'W')` breaks for non-QWERTY keyboards, gamepads, touch, and accessibility. Use an action-mapping system where actions are abstract and bindings are configurable.
- **Do NOT ignore mobile thermal throttling.** A phone that hits 60 FPS in the first minute will throttle to 30 FPS after sustained load. Budget for the throttled state, not the peak.
- **Do NOT ship without a profiler pass.** "It runs fine on my machine" is not a performance guarantee. Profile on minimum-spec target hardware before shipping.
