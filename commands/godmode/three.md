# /godmode:three

3D web development covering Three.js, React Three Fiber, WebGL/WebGPU fundamentals, 3D asset optimization (GLTF, Draco, KTX2), shader programming, lighting and materials, VR/AR with WebXR, and rendering performance optimization.

## Usage

```
/godmode:three                             # Full 3D project audit
/godmode:three --assets                    # 3D asset optimization pipeline
/godmode:three --shaders                   # Custom shader development guide
/godmode:three --lighting                  # Lighting and material setup
/godmode:three --xr                        # WebXR (VR/AR) integration
/godmode:three --perf                      # 3D rendering performance audit
/godmode:three --r3f                       # React Three Fiber architecture setup
/godmode:three --gltf                      # GLTF optimization pipeline
/godmode:three --particles                 # Particle system implementation
/godmode:three --postprocess               # Post-processing effects setup
```

## What It Does

1. Analyzes 3D project context (framework, assets, complexity, targets)
2. Sets up Three.js or React Three Fiber architecture
3. Explains WebGL/WebGPU rendering pipeline fundamentals
4. Optimizes 3D assets (GLTF compression, texture KTX2, mesh reduction)
5. Guides shader programming (vertex, fragment, common techniques)
6. Configures lighting and PBR materials
7. Integrates WebXR for VR/AR web experiences
8. Profiles and optimizes 3D rendering performance

## Output
- 3D audit report at `docs/three/<project>-3d-audit.md`
- Scene commit: `"three: scaffold <framework> 3D scene with <features>"`
- Asset commit: `"three: optimize assets — <before> -> <after> (<X>% reduction)"`
- Shader commit: `"three: add <effect> shader for <purpose>"`
- XR commit: `"three: add WebXR <VR/AR> support"`

## Key Principles

1. **GLTF is the standard** — use GLB for all web 3D assets
2. **Compress everything** — Draco for geometry, KTX2 for textures, gzip for transfer
3. **Dispose or leak** — Three.js does not garbage collect GPU resources
4. **Cap pixel ratio at 2** — 3x renders 44% more pixels with no visible difference
5. **Instancing for repetition** — 1000 trees as InstancedMesh = 1 draw call
6. **Test on mobile** — desktop GPU is 10-50x faster than mobile

## Next Step
After 3D setup: `/godmode:gamedev` for game mechanics, `/godmode:animation` for motion design, `/godmode:perf` for profiling, or `/godmode:ship` to deploy.

## Examples

```
/godmode:three                             # Full 3D project audit
/godmode:three --assets                    # Optimize GLTF models and textures
/godmode:three --xr                        # Add VR/AR support
/godmode:three --shaders                   # Write custom shaders
```
