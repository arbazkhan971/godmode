---
name: three
description: |
  3D web development skill. Activates when user needs to build 3D web experiences with Three.js, React Three Fiber, WebGL, or WebGPU. Covers 3D scene architecture, asset optimization (GLTF, Draco, KTX2), shader programming, lighting and materials, VR/AR with WebXR, and rendering performance. Triggers on: /godmode:three, "three.js", "react three fiber", "3D web", "WebGL", "WebGPU", "WebXR", "shader", or when building 3D interactive experiences.
---

# Three — 3D Web Development

## When to Activate
- User invokes `/godmode:three`
- User says "three.js," "react three fiber," "3D web," "WebGL," "WebGPU"
- When building 3D interactive experiences for the web
- When optimizing 3D asset delivery (GLTF, textures, meshes)
- When writing custom shaders (vertex, fragment, compute)
- When building VR/AR web experiences with WebXR
- When troubleshooting 3D rendering performance

## Workflow

### Step 1: Analyze 3D Project Context
Survey the 3D project requirements and current state:

```
3D PROJECT ANALYSIS:
Framework: <Three.js/R3F/Babylon.js/PlayCanvas/custom>
React integration: <React Three Fiber/drei/none>
Rendering API: <WebGL 2/WebGPU/fallback>
Scene complexity: <low/medium/high>
Asset types: <GLTF/OBJ/FBX/procedural>
Interaction: <orbit/first-person/VR/AR/none>

Project inventory:
  3D models: <N> (total triangles: <N>)
  Textures: <N> (total size: <MB>)
  Materials: <N> (PBR/basic/custom shader)
  Lights: <N> (type breakdown)
  Animations: <N> (skeletal/morph/keyframe)
  Post-processing: <list>

Target performance:
  FPS: <30/60>
  Devices: <desktop/mobile/VR headset>
  Max draw calls: <budget>
  Max triangles: <budget>
  Max texture memory: <budget MB>
  Initial load: <budget seconds>
```

### Step 2: Three.js / React Three Fiber Architecture
Set up the 3D application architecture:

#### Three.js Core Architecture
```
THREE.JS ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│ Renderer       │ WebGLRenderer / WebGPURenderer                 │
│ Scene          │ Scene graph — root of all 3D objects            │
│ Camera         │ PerspectiveCamera / OrthographicCamera          │
│ Mesh           │ Geometry + Material = visible object            │
│ Light          │ Ambient, Directional, Point, Spot, Hemisphere   │
│ Controls       │ OrbitControls, FlyControls, PointerLockControls │
│ Loader         │ GLTFLoader, TextureLoader, KTX2Loader           │
│ Post-process   │ EffectComposer, RenderPass, custom passes       │
└─────────────────────────────────────────────────────────────────┘

SCENE SETUP (vanilla Three.js):
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({
  antialias: true,
  alpha: false,
  powerPreference: 'high-performance',
});
renderer.setSize(width, height);
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); // cap at 2x
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.0;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;

// Render loop
function animate() {
  requestAnimationFrame(animate);
  controls.update();
  renderer.render(scene, camera);
}
animate();

// Resize handler
window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

// Cleanup
renderer.dispose();
scene.traverse((object) => {
  if (object.geometry) object.geometry.dispose();
  if (object.material) {
    if (Array.isArray(object.material)) {
      object.material.forEach(m => m.dispose());
    } else {
      object.material.dispose();
    }
  }
});
```

#### React Three Fiber Architecture
```
R3F ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│ Canvas         │ Root component — creates renderer, scene, camera│
│ mesh/group     │ Declarative scene graph (JSX = Three.js objects)│
│ useFrame       │ Per-frame update hook (game loop equivalent)    │
│ useThree       │ Access renderer, scene, camera, gl context      │
│ useLoader      │ Suspense-compatible asset loading               │
│ drei           │ Helper library (OrbitControls, Environment, etc)│
│ rapier/cannon  │ Physics via react-three-rapier or use-cannon    │
│ postprocessing │ Post-processing via @react-three/postprocessing │
└─────────────────────────────────────────────────────────────────┘

R3F SCENE SETUP:
import { Canvas } from '@react-three/fiber';
import { OrbitControls, Environment, Preload } from '@react-three/drei';

function App() {
  return (
    <Canvas
      camera={{ position: [0, 2, 5], fov: 50 }}
      gl={{
        antialias: true,
        powerPreference: 'high-performance',
        alpha: false,
      }}
      dpr={[1, 2]}       // clamp pixel ratio
      shadows
      flat                // disable tone mapping (optional)
    >
      <Suspense fallback={<Loader />}>
        <Scene />
        <Environment preset="city" />
        <OrbitControls />
        <Preload all />
      </Suspense>
    </Canvas>
  );
}

R3F COMPONENT PATTERN:
function Box({ position, color = 'orange' }) {
  const meshRef = useRef();
  const [hovered, setHovered] = useState(false);

  useFrame((state, delta) => {
    meshRef.current.rotation.y += delta * 0.5;
  });

  return (
    <mesh
      ref={meshRef}
      position={position}
      onPointerOver={() => setHovered(true)}
      onPointerOut={() => setHovered(false)}
    >
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color={hovered ? 'hotpink' : color} />
    </mesh>
  );
}

R3F HOOKS:
  useFrame((state, delta) => { })   // animation loop
  useThree()                         // renderer, scene, camera, size
  useLoader(GLTFLoader, url)         // load assets with Suspense
  useTexture(url)                    // load textures (drei)
  useGLTF(url)                       // load GLTF models (drei)
  useAnimations(gltf.animations)     // play GLTF animations (drei)
```

### Step 3: WebGL / WebGPU Fundamentals
Understanding the rendering pipeline:

```
RENDERING PIPELINE:
┌─────────────────────────────────────────────────────────────────┐
│ 1. Vertex Shader    │ Transform vertices (model -> clip space)  │
│ 2. Rasterization    │ Convert triangles to fragments (pixels)    │
│ 3. Fragment Shader  │ Calculate color per pixel (lighting, tex)  │
│ 4. Depth Test       │ Discard occluded fragments (z-buffer)      │
│ 5. Blending         │ Combine with framebuffer (transparency)    │
│ 6. Output           │ Final pixel on screen                      │
└─────────────────────────────────────────────────────────────────┘

WEBGL vs WEBGPU:
┌────────────────────────────────────────────────────────────────┐
│ Feature           │ WebGL 2          │ WebGPU                  │
├────────────────────────────────────────────────────────────────┤
│ Shader language   │ GLSL ES 3.0      │ WGSL                    │
│ Compute shaders   │ No               │ Yes                     │
│ Multi-threaded    │ No               │ Yes (command buffers)   │
│ Indirect drawing  │ Limited          │ Yes                     │
│ Bindless textures │ No               │ Yes (bind groups)       │
│ API style         │ Stateful (global)│ Stateless (pipelines)   │
│ Browser support   │ Universal        │ Chrome, Edge, Firefox*  │
│ Performance       │ Good             │ Better (lower overhead) │
│ Three.js support  │ Full             │ Experimental            │
└────────────────────────────────────────────────────────────────┘
* Firefox WebGPU behind flag as of 2025

RECOMMENDATION:
IF broad browser support needed → WebGL 2 (Three.js default)
IF compute shaders needed → WebGPU (particle simulations, GPGPU)
IF cutting-edge performance → WebGPU with WebGL fallback
IF React project → R3F (abstracts renderer choice)
```

### Step 4: 3D Asset Optimization
Optimize models and textures for web delivery:

```
GLTF OPTIMIZATION PIPELINE:
┌────────────────────────────────────────────────────────────────┐
│ Step               │ Tool              │ Impact                 │
├────────────────────────────────────────────────────────────────┤
│ 1. Clean up        │ Blender/gltf-     │ Remove unused nodes,   │
│                    │ transform         │ materials, animations  │
│ 2. Mesh simplify   │ Blender Decimate  │ Reduce triangle count  │
│ 3. Draco compress  │ gltf-transform    │ 80-90% geometry savings│
│ 4. Meshopt compress│ gltf-transform    │ 70-80% + GPU decode    │
│ 5. Texture resize  │ Sharp/Squoosh     │ Power-of-2, max 2048px │
│ 6. Texture compress│ KTX2 + Basis      │ 75% GPU memory savings │
│ 7. Pack to GLB     │ gltf-transform    │ Single binary file     │
│ 8. Serve with gzip │ Server config     │ 30-50% transfer savings│
└────────────────────────────────────────────────────────────────┘

GLTF-TRANSFORM COMMANDS:
# Full optimization pipeline
npx @gltf-transform/cli optimize input.glb output.glb \
  --compress draco \
  --texture-compress ktx2 \
  --texture-size 2048

# Draco compression only
npx @gltf-transform/cli draco input.glb output.glb

# Meshopt compression (GPU-decodable)
npx @gltf-transform/cli meshopt input.glb output.glb

# Texture compression to KTX2
npx @gltf-transform/cli ktx2 input.glb output.glb --slots "baseColor,normal,emissive"

# Reduce texture resolution
npx @gltf-transform/cli resize input.glb output.glb --width 1024 --height 1024

# Remove unused data
npx @gltf-transform/cli prune input.glb output.glb
npx @gltf-transform/cli dedup input.glb output.glb

TEXTURE OPTIMIZATION:
┌────────────────────────────────────────────────────────────────┐
│ Map Type         │ Format    │ Max Size │ Channels │ Notes     │
├────────────────────────────────────────────────────────────────┤
│ Base color       │ KTX2/JPEG │ 2048     │ RGB(A)   │ sRGB     │
│ Normal map       │ KTX2/PNG  │ 2048     │ RG(B)    │ Linear   │
│ Metallic-rough   │ KTX2/JPEG │ 1024     │ GB       │ Linear   │
│ Occlusion        │ KTX2/JPEG │ 1024     │ R        │ Linear   │
│ Emissive         │ KTX2/JPEG │ 1024     │ RGB      │ sRGB     │
│ Environment map  │ HDR/EXR   │ 512-1024 │ RGB      │ Prefilter│
└────────────────────────────────────────────────────────────────┘

ASSET SIZE BUDGETS (web):
┌────────────────────────────────────────────────────────────────┐
│ Category         │ Budget (mobile)    │ Budget (desktop)       │
├────────────────────────────────────────────────────────────────┤
│ Total scene      │ < 5MB              │ < 20MB                 │
│ Single model     │ < 1MB              │ < 5MB                  │
│ Textures total   │ < 3MB transfer     │ < 10MB transfer        │
│ GPU tex memory   │ < 128MB            │ < 512MB                │
│ Triangle count   │ < 100K             │ < 1M                   │
│ Draw calls       │ < 50               │ < 200                  │
│ Initial load     │ < 3 seconds        │ < 5 seconds            │
└────────────────────────────────────────────────────────────────┘
```

### Step 5: Shader Programming
Write custom shaders for visual effects:

```
SHADER FUNDAMENTALS (Three.js ShaderMaterial):

// Vertex shader — runs per vertex
const vertexShader = `
  uniform float uTime;
  varying vec2 vUv;
  varying vec3 vNormal;

  void main() {
    vUv = uv;
    vNormal = normalize(normalMatrix * normal);

    vec3 pos = position;
    pos.z += sin(pos.x * 4.0 + uTime) * 0.2; // wave displacement

    gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
  }
`;

// Fragment shader — runs per pixel
const fragmentShader = `
  uniform float uTime;
  uniform vec3 uColor;
  uniform sampler2D uTexture;
  varying vec2 vUv;
  varying vec3 vNormal;

  void main() {
    vec4 texColor = texture2D(uTexture, vUv);
    float light = dot(vNormal, normalize(vec3(1.0, 1.0, 1.0)));
    light = clamp(light, 0.2, 1.0); // ambient minimum

    gl_FragColor = vec4(texColor.rgb * uColor * light, texColor.a);
  }
`;

// ShaderMaterial setup
const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: {
    uTime: { value: 0 },
    uColor: { value: new THREE.Color('#ff6600') },
    uTexture: { value: texture },
  },
  transparent: true,
  side: THREE.DoubleSide,
});

// Update in animation loop
material.uniforms.uTime.value = clock.getElapsedTime();

COMMON SHADER TECHNIQUES:
┌────────────────────────────────────────────────────────────────┐
│ Technique          │ Purpose                │ Complexity        │
├────────────────────────────────────────────────────────────────┤
│ UV scrolling       │ Water, lava, clouds    │ Beginner          │
│ Fresnel effect     │ Rim lighting, glow     │ Beginner          │
│ Noise (Simplex)    │ Terrain, distortion    │ Intermediate      │
│ Normal mapping     │ Surface detail         │ Intermediate      │
│ Dissolve effect    │ Disintegration         │ Intermediate      │
│ Toon/cel shading   │ Stylized look          │ Intermediate      │
│ Screen-space FX    │ Bloom, SSAO, DOF       │ Advanced          │
│ Ray marching       │ Volumetric, SDF        │ Advanced          │
│ PBR custom         │ Custom material model  │ Advanced          │
│ Instanced shaders  │ Grass, particles       │ Advanced          │
└────────────────────────────────────────────────────────────────┘

R3F SHADER INTEGRATION (with drei):
import { shaderMaterial } from '@react-three/drei';
import { extend } from '@react-three/fiber';

const WaveMaterial = shaderMaterial(
  { uTime: 0, uColor: new THREE.Color('#ff6600') },
  vertexShader,
  fragmentShader
);

extend({ WaveMaterial });

function WaveMesh() {
  const materialRef = useRef();
  useFrame((state) => {
    materialRef.current.uTime = state.clock.elapsedTime;
  });
  return (
    <mesh>
      <planeGeometry args={[10, 10, 64, 64]} />
      <waveMaterial ref={materialRef} />
    </mesh>
  );
}
```

### Step 6: Lighting & Materials
Set up physically-based lighting:

```
LIGHTING SETUP:
┌────────────────────────────────────────────────────────────────┐
│ Light Type       │ Use Case               │ Shadow │ Cost      │
├────────────────────────────────────────────────────────────────┤
│ AmbientLight     │ Base fill light         │ No     │ Cheap     │
│ DirectionalLight │ Sun, key light          │ Yes    │ Moderate  │
│ PointLight       │ Lamps, orbs             │ Yes    │ Expensive │
│ SpotLight        │ Flashlight, stage light │ Yes    │ Expensive │
│ HemisphereLight  │ Sky + ground bounce     │ No     │ Cheap     │
│ RectAreaLight    │ Window, screen light    │ No     │ Moderate  │
│ Environment map  │ Image-based lighting    │ No     │ Moderate  │
└────────────────────────────────────────────────────────────────┘

RECOMMENDED LIGHTING SETUP:
// Three-point lighting (key + fill + back)
<ambientLight intensity={0.2} />
<directionalLight
  position={[5, 5, 5]}
  intensity={1.5}
  castShadow
  shadow-mapSize={[2048, 2048]}
  shadow-bias={-0.0001}
/>
<hemisphereLight args={['#87CEEB', '#362907', 0.3]} />

// Environment-based lighting (most realistic)
<Environment
  preset="city"          // or files={['px.hdr', ...]}
  background={false}     // don't show as background
  environmentIntensity={1.0}
/>

PBR MATERIAL PROPERTIES:
┌────────────────────────────────────────────────────────────────┐
│ Property         │ Range   │ Description                       │
├────────────────────────────────────────────────────────────────┤
│ color            │ RGB     │ Base albedo color                 │
│ metalness        │ 0-1     │ 0 = dielectric, 1 = metal        │
│ roughness        │ 0-1     │ 0 = mirror, 1 = matte            │
│ normalMap        │ Texture │ Surface detail without geometry   │
│ aoMap            │ Texture │ Ambient occlusion (contact shadow)│
│ emissive         │ RGB     │ Self-illumination color           │
│ emissiveIntensity│ 0+      │ Glow brightness                  │
│ envMapIntensity  │ 0+      │ Environment reflection strength   │
│ transmission     │ 0-1     │ Transparency (glass, water)       │
│ ior              │ 1-2.33  │ Index of refraction               │
│ thickness        │ 0+      │ Volume thickness for transmission │
└────────────────────────────────────────────────────────────────┘

MATERIAL REFERENCE:
  Plastic:    metalness=0, roughness=0.4-0.6
  Metal:      metalness=1, roughness=0.1-0.4
  Wood:       metalness=0, roughness=0.6-0.9
  Glass:      transmission=1, ior=1.5, roughness=0
  Ceramic:    metalness=0, roughness=0.1-0.3
  Fabric:     metalness=0, roughness=0.8-1.0
  Water:      transmission=0.9, ior=1.33, roughness=0
```

### Step 7: VR/AR Web Experiences (WebXR)
Build immersive experiences for the web:

```
WEBXR ARCHITECTURE:
┌─────────────────────────────────────────────────────────────────┐
│ Session Types:                                                  │
│   'immersive-vr'    — Full VR headset experience               │
│   'immersive-ar'    — AR with camera passthrough               │
│   'inline'          — Non-immersive 3D on page                 │
│                                                                 │
│ Input Sources:                                                  │
│   Controllers       — 6DOF tracked controllers                 │
│   Hands             — Hand tracking (quest, vision pro)        │
│   Gaze              — Head/eye direction                       │
│   Transient         — Screen tap in AR                         │
└─────────────────────────────────────────────────────────────────┘

THREE.JS WEBXR SETUP:
renderer.xr.enabled = true;

// VR button
import { VRButton } from 'three/addons/webxr/VRButton.js';
document.body.appendChild(VRButton.createButton(renderer));

// AR button
import { ARButton } from 'three/addons/webxr/ARButton.js';
document.body.appendChild(ARButton.createButton(renderer, {
  requiredFeatures: ['hit-test'],
  optionalFeatures: ['hand-tracking', 'plane-detection'],
}));

// XR render loop (replaces requestAnimationFrame)
renderer.setAnimationLoop((time, frame) => {
  // frame is XRFrame — available in XR session
  if (frame) {
    const session = renderer.xr.getSession();
    const referenceSpace = renderer.xr.getReferenceSpace();
    // Handle XR input, hit testing, etc.
  }
  renderer.render(scene, camera);
});

R3F WEBXR (with @react-three/xr):
import { XR, Controllers, Hands, VRButton } from '@react-three/xr';

function App() {
  return (
    <>
      <VRButton />
      <Canvas>
        <XR>
          <Controllers />
          <Hands />
          <Scene />
        </XR>
      </Canvas>
    </>
  );
}

// Interaction in XR
import { useXREvent } from '@react-three/xr';

function InteractiveBox() {
  const ref = useRef();
  useXREvent('select', (event) => {
    // Controller trigger pressed
    ref.current.material.color.set('red');
  });
  return (
    <mesh ref={ref}>
      <boxGeometry />
      <meshStandardMaterial />
    </mesh>
  );
}

WEBXR CHECKLIST:
- [ ] Feature detection: navigator.xr?.isSessionSupported('immersive-vr')
- [ ] Fallback for non-XR browsers (desktop orbit, mobile touch)
- [ ] Comfortable locomotion (teleport, snap-turn, no vection)
- [ ] Controller model loading (XRControllerModelFactory)
- [ ] Hand tracking support (XRHandModelFactory)
- [ ] Hit testing for AR placement
- [ ] Fixed foveated rendering for performance
- [ ] 72/90Hz render loop (match headset refresh)
- [ ] Stereo rendering (handled by Three.js XR manager)
- [ ] Accessibility: audio cues, haptic feedback
```

### Step 8: 3D Performance Optimization
Optimize rendering for smooth frame rates:

```
3D PERFORMANCE CHECKLIST:

Geometry:
- [ ] LOD (Level of Detail) for distant objects
- [ ] Instanced rendering for repeated objects (InstancedMesh)
- [ ] Merged static geometry (BufferGeometryUtils.mergeGeometries)
- [ ] Triangle budget per scene (mobile < 100K, desktop < 1M)
- [ ] Backface culling enabled (default in Three.js)
- [ ] Frustum culling enabled (default in Three.js)
- [ ] Occlusion culling for complex scenes (three-mesh-bvh)

Textures:
- [ ] KTX2/Basis compressed textures (GPU-decoded)
- [ ] Power-of-2 dimensions (256, 512, 1024, 2048)
- [ ] Mipmaps generated (default for power-of-2)
- [ ] Max 2048px for web (1024 for mobile)
- [ ] Texture atlas for many small textures
- [ ] Dispose unused textures (texture.dispose())

Materials:
- [ ] Share materials between identical meshes
- [ ] Avoid transparency when possible (sort order cost)
- [ ] Use MeshBasicMaterial for unlit objects (cheaper)
- [ ] Limit real-time shadow casters
- [ ] Bake lighting for static scenes

Draw calls:
- [ ] Batch similar materials (instancing, merging)
- [ ] Monitor with renderer.info.render.calls
- [ ] Mobile budget: < 50 draw calls
- [ ] Desktop budget: < 200 draw calls

Shadows:
- [ ] Shadow map size appropriate (1024 for mobile, 2048 desktop)
- [ ] Shadow cascade for large scenes (CSM)
- [ ] Shadow bias tuned (no peter-panning or acne)
- [ ] Only critical objects cast/receive shadows
- [ ] Bake shadows for static objects

Post-processing:
- [ ] Render at lower resolution, upscale (resolution scaling)
- [ ] Limit post-processing passes (each = full-screen draw)
- [ ] FXAA over MSAA for post-processed scenes
- [ ] Disable effects on mobile (or use lighter alternatives)

PERFORMANCE MONITORING:
// Three.js built-in stats
import Stats from 'three/addons/libs/stats.module.js';
const stats = new Stats();
document.body.appendChild(stats.dom);

// In render loop
stats.update();

// Renderer info
console.log(renderer.info.render.calls);      // draw calls
console.log(renderer.info.render.triangles);   // triangle count
console.log(renderer.info.memory.textures);    // texture count
console.log(renderer.info.memory.geometries);  // geometry count

// R3F: usePerf from r3f-perf
import { Perf } from 'r3f-perf';
<Perf position="top-left" />
```

### Step 9: Recommendations Report

```
+------------------------------------------------------------+
|  3D WEB REPORT — <project>                                  |
+------------------------------------------------------------+
|  Framework: <Three.js/R3F/Babylon.js>                       |
|  Rendering API: <WebGL 2/WebGPU>                            |
|  Scene complexity: <triangles> tris, <draw calls> calls     |
|  Target: <platform(s)> @ <target FPS>                       |
|                                                             |
|  Assets:                                                    |
|  Models: <N> (<total MB> transfer, <total MB> GPU)          |
|  Textures: <N> (<format>, <total MB> GPU memory)            |
|  Compression: <Draco/Meshopt/KTX2/none>                     |
|                                                             |
|  Performance:                                               |
|  FPS: <current> / <target>                                  |
|  Draw calls: <current> / <budget>                           |
|  Triangles: <current> / <budget>                            |
|  GPU memory: <current MB> / <budget MB>                     |
|  Load time: <current s> / <budget s>                        |
|                                                             |
|  Issues:                                                    |
|  Uncompressed assets: <N>                                   |
|  Oversized textures: <N>                                    |
|  Undisposed resources: <N>                                  |
|  Missing LOD: <N> models                                    |
|                                                             |
|  Priority Actions:                                          |
|  1. <highest impact improvement>                            |
|  2. <second improvement>                                    |
|  3. <third improvement>                                     |
+------------------------------------------------------------+
```

### Step 10: Commit and Transition
1. If 3D scene was set up:
   - Commit: `"three: scaffold <framework> 3D scene with <features>"`
2. If assets were optimized:
   - Commit: `"three: optimize assets — <before MB> -> <after MB> (<X>% reduction)"`
3. If shaders were implemented:
   - Commit: `"three: add <effect> shader for <purpose>"`
4. If WebXR was integrated:
   - Commit: `"three: add WebXR <VR/AR> support with <input method>"`
5. Save report: `docs/three/<project>-3d-audit.md`
6. Transition: "3D scene ready. Run `/godmode:animation` for motion design, `/godmode:gamedev` for game mechanics, or `/godmode:perf` for performance profiling."

## Key Behaviors

1. **GLTF is the standard.** Use GLTF/GLB for all 3D models on the web. It is the "JPEG of 3D" — universally supported, compact, and GPU-ready. Do not use OBJ, FBX, or proprietary formats for web delivery.
2. **Compress everything.** Draco or Meshopt for geometry. KTX2/Basis for textures. Gzip/Brotli for transfer. Uncompressed 3D assets on the web are unacceptable — a 50MB GLTF that could be 5MB wastes user bandwidth and time.
3. **Dispose resources or leak memory.** Three.js does not garbage collect GPU resources. Every geometry, material, texture, and render target must be explicitly disposed when no longer needed. `scene.traverse()` + dispose on unmount is mandatory.
4. **Pixel ratio capped at 2.** `renderer.setPixelRatio(Math.min(devicePixelRatio, 2))`. A 3x Retina display renders 9x the pixels of 1x. Capping at 2x is visually indistinguishable from 3x but renders 44% fewer pixels.
5. **Instancing for repeated geometry.** 1000 trees as 1000 meshes = 1000 draw calls. 1000 trees as one InstancedMesh = 1 draw call. Use instancing for any repeated object (vegetation, particles, buildings, crowds).
6. **Environment maps over many lights.** A single HDR environment map provides realistic image-based lighting that would require dozens of point lights to approximate. Use `Environment` from drei for easy setup. Add one directional light for key shadows.
7. **Test on mobile.** A scene that runs at 60 FPS on a desktop GPU will run at 5 FPS on a mobile GPU. Set mobile-first budgets and test on real devices. The Performance panel in Chrome DevTools with 4x CPU slowdown does not simulate GPU limitations.

## Example Usage

### Full 3D project audit
```
User: /godmode:three

Three: Analyzing 3D web project...

3D PROJECT ANALYSIS:
Framework: React Three Fiber + drei
Rendering: WebGL 2
Models: 12 GLTF files (47MB total, uncompressed)
Textures: 34 (PNG, max 4096px, no KTX2)
Materials: 18 (all MeshStandardMaterial)
Draw calls: 340 (budget: 200)
Triangles: 890K (budget: 500K)

FINDING 1: No asset compression — 47MB GLTF, no Draco, no KTX2
  Estimated after optimization: ~6MB (87% reduction)
  Action: Run gltf-transform pipeline

FINDING 2: 4096px textures on mobile
  Action: Resize to 2048 max, compress to KTX2

FINDING 3: 12 identical tree meshes as separate Mesh objects
  Action: Convert to InstancedMesh (12 draw calls -> 1)

FINDING 4: No resource disposal on component unmount
  Action: Add useEffect cleanup with dispose traversal

Priority Actions:
1. Asset compression pipeline (47MB -> ~6MB)
2. Instanced rendering for trees (12 draw calls -> 1)
3. Texture resize + KTX2 compression (GPU memory -75%)

Verdict: FUNCTIONAL but overweight — optimization required for production.
```

### WebXR setup
```
User: /godmode:three --xr

Three: Setting up WebXR...

Detected: React Three Fiber project
Recommendation: @react-three/xr v6

Setup:
1. Install @react-three/xr
2. Wrap scene in <XR> component
3. Add <Controllers /> and <Hands /> for input
4. Add VRButton for session entry
5. Implement teleport locomotion
6. Test on Quest 3 browser

WebXR features enabled:
- Hand tracking (Quest 3, Vision Pro)
- Controller input (standard gamepad mapping)
- Hit testing (AR placement)
- Teleport locomotion (comfort)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full 3D project audit |
| `--assets` | 3D asset optimization pipeline |
| `--shaders` | Custom shader development guide |
| `--lighting` | Lighting and material setup |
| `--xr` | WebXR (VR/AR) integration |
| `--perf` | 3D rendering performance audit |
| `--r3f` | React Three Fiber architecture setup |
| `--gltf` | GLTF optimization pipeline |
| `--particles` | Particle system implementation |
| `--postprocess` | Post-processing effects setup |

## Anti-Patterns

- **Do NOT skip resource disposal.** Three.js objects hold GPU resources (buffers, textures, programs) that the JavaScript garbage collector cannot free. Every `geometry.dispose()`, `material.dispose()`, `texture.dispose()` must be called explicitly. Skipping this leaks VRAM until the tab crashes.
- **Do NOT use uncompressed assets in production.** A raw GLTF export from Blender contains uncompressed geometry and PNG textures. Run through gltf-transform with Draco/Meshopt + KTX2 before deploying. The difference is typically 5-10x smaller files.
- **Do NOT create new materials per mesh for identical appearances.** 100 meshes with 100 identical-but-separate materials = 100 material switches per frame. Share a single material instance across all meshes with the same appearance.
- **Do NOT use device pixel ratio directly.** `renderer.setPixelRatio(window.devicePixelRatio)` on a 3x display renders 9x the pixels. Cap at 2: `Math.min(window.devicePixelRatio, 2)`. Users cannot perceive the difference; the GPU absolutely can.
- **Do NOT put heavy computation in useFrame without guards.** `useFrame` runs every frame (60-120 times per second). Matrix operations, raycasting, or array allocations in useFrame without early-exit conditions will tank performance.
- **Do NOT use real-time shadows on everything.** Each shadow-casting light requires an additional render pass. Limit shadow casters to key lights, limit shadow receivers to ground/walls, and bake shadows for static objects.
- **Do NOT ignore mobile GPU limits.** Desktop GPUs have 10-50x the power of mobile GPUs. A scene with 1M triangles and 20 post-processing passes that runs at 60 FPS on desktop will run at single-digit FPS on mobile. Set mobile budgets at project start.
