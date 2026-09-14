# PC DLSS work — September 13

## Direct gameplay terrain-motion verification

The opt-in terrain audit now also downloads the RG32 motion texture actually
supplied to DLSS. For each classified ground pixel it independently intersects
the camera ray with the ground in double precision, transforms the point to
the previous camera, and compares previous-minus-current pixel displacement
against the GPU result (0.02 pixel tolerance). Missing motion and mismatches
fail the diagnostic. Samples include frame 1 and every subsequent 16th frame,
not merely an initially stationary frame. This adds no normal rendering stalls.

`tmp/dlss-terrain-motion-sampled` passes 64 evaluated frames per Original/EX at
60 FPS, initial history reset only. All classified pixels in each of five
sampled frames have usable depth and matching motion, including nonzero camera
movement. This verifies the terrain-plane reprojection transport for these
scenes; it does not establish all background artwork/scroll motion or finish
full-scene jitter, SR modes, or neural gameplay integration.

`tmp/dlss-terrain-motion-sampled-240` also passes 96 frames per experience at
240 FPS, queued and serialized. Seven sampled frames in each run have zero
motion mismatches, including moving/interpolated frames; serialized final
images match exactly, only the initial history reset occurs, and SDK shutdown
is clean. The Windows executable includes these default-off diagnostic checks.

## Terrain ownership survives intermediate GPU merges

Fixed scene merge and fused raster shaders dropping terrain bit 27. Ownership
now follows visible background color through these passes and is cleared by
covering models or opaque HUD pixels. Regenerated DXIL, SPIR-V and MSL assets.
New raw-metadata fixtures exercise both fused and separate scene merge paths;
D3D12 and Vulkan background/depth suites pass, including 183997440 background
samples and 5120 temporal-guide samples.

Added opt-in `-AuditTerrain` to the gameplay checker. It downloads the actual
world ownership buffer and the depth texture supplied to DLSS on the second
evaluated frame, reporting classified versus usable terrain depth pixels.
Readback is diagnostic-only; ordinary rendering gains no fence or CPU transfer.
The checker rejects missing/empty depth evidence or evaluation failure.

Correction to earlier sections: matched profile logs and color screenshots
alone did not prove terrain reached DLSS. The intermediate metadata loss above
meant those earlier gameplay runs could not establish that claim. Direct depth
auditing is required in addition to those existing checks. This remains a
diagnostic DLAA path, not completed SR modes or a release-ready DLSS option.

Direct gameplay evidence after the fix:
- `tmp/dlss-terrain-merge-audit`: 32 frames per Original/EX and queued/serialized
  mode, initial reset only, exact serialized output match. All 143669 Original
  and 163287 EX classified ground pixels have usable depth on the audited frame.
- `tmp/dlss-terrain-merge-level1-4`: 8 frames per experience; all 156258/163219
  classified terrain pixels have usable depth.
- `tmp/dlss-terrain-merge-level1-6`: 8 frames per experience; all 166819/166838
  classified terrain pixels have usable depth.

All runs evaluated successfully and shut down cleanly. These depth counts prove
transport and usable depth for the sampled frames, not full background motion
accuracy or quality across every stage. Windows executable rebuilt; generated
scene/raster shader freshness and whitespace checks passed.

## Additional authored terrain profiles

Added 1-4.SCR and F-1.SCR definitions (ground rows 360..511), using their
complete source fingerprints 80d53f12 and 33b82640 with the same uniform
tile-relocation normalization. Source BGS.ASM selects these maps for ground
scenes; their lower tile rows contain the authored ground gradients. Changed
maps remain unknown, and first-word palette/flip bits cheaply reject unrelated
profiles before hashing.

Both assets pass original/relocated and rejection fixtures on D3D12/Vulkan.
The gameplay checker now accepts a validated `-Level` argument.
`tmp/dlss-terrain-level1-4` and `tmp/dlss-terrain-level1-6` each pass all 16
Original/EX evaluations, log matched terrain rows, and shut down without SDK
errors. Original screenshots for both were visually inspected with comms/HUD
present. These runs do not prove all other ground or EX-specific backgrounds.

## Authored ST-P terrain enabled in diagnostic gameplay

Added a source definition for ST-P.SCR's rows 360..511, the ground-gradient
rows after the sky/cloud/mountain artwork. Classification requires the complete
8192-byte tilemap fingerprint (FNV-1a 536ac185), normalized for the loader's
uniform character-index relocation, while retaining palette/priority/flip bits.
Direct VRAM comparison in `tmp/dlss-terrain-vram` found every one of 4096 words
relocated by +192 in both Original and EX. Arbitrary modified maps do not match.
Tunnel/wrong-mode/wrong-layout maps remain excluded.

The PC diagnostic path now assigns this profile to matching GPU BG2 draws,
connecting authored coverage through composition to the camera-plane converter.
`tmp/dlss-gameplay-relocated-terrain` logs rows=360:512 for both experiences and
passes 64 evaluations each, initial reset only, clean shutdown and exact
queued/serialized comparison. `ORIGINAL-on.png` was inspected with HUD intact.
The background checker accepts the authored ST-P.SCR as an optional fixture;
original/relocated matches and modified/tunnel/tile-size rejection pass on
D3D12/Vulkan. Other tilemaps remain unclassified: this does not complete all
backgrounds, full-scene jitter, SR modes or release acceptance.

## PC terrain-plane handoff

The diagnostic PC DLSS host now consumes packed terrain ownership with the
actual camera-space ground plane, current/previous pixel projections and
camera mapping. The plane is sourced independently of whether ray tracing is
enabled; source shadow availability and tunnel exclusion gate it. Changing
ground height, losing the plane or a history reset invalidates terrain motion.

`tmp/dlss-gameplay-terrain-plane-handoff` passes 64 evaluated frames each in
Original/EX, only the initial global reset, clean shutdown, no evaluation errors,
and exact queued/serialized output comparison. Authored terrain row ranges are
still empty by default, so this proves the handoff's regression behavior, not
that gameplay terrain pixels now have complete depth. Per-background source
classification remains necessary; unknown pixels have not been guessed.

## Source-row terrain ownership transport

GpuBackgroundSettings accepts optional authored BG2 terrain source-row ranges.
The GPU marks qualifying visible pixels with bit 27, following scroll/mosaic
sampling and continued ground rows; tunnels are excluded. GpuComposite retains
this background ownership only while visible: native models, CPU foreground,
late overlays and margin replacements clear it. The terrain converter can now
consume that packed ownership directly, avoiding a separate mask readback.

D3D12/Vulkan background checks cover scrolling at 1x/2x/4x, tunnel exclusion,
and an actual background->compositor test with model and opaque-black HUD
occlusion. Existing 183997440 background samples remain unchanged; D3D12's full
composition/effects suite passes. Temporal guide checks pass 5120 cases with
both packed and standalone masks on both backends. PC builds.

Ranges remain empty by default. Authored per-background ranges and their plane
association still need integration/validation before gameplay terrain guides
are enabled. This implements mask transport, not all-stage terrain completion.

## Cartridge coverage evidence

Added `-CaptureBackground` to the gameplay checker to preserve expanded,
unscrolled and complete tilemap images alongside evaluation logs. The run in
`tmp/dlss-terrain-source-layers` passes Original/EX evaluation and shutdown.
Inspected `ORIGINAL-on-bg2-tilemap.png`: Corneria's sky, mountains and ground
occupy one 512x512 BG2 tilemap (map 28672, characters 20480, scroll Y 232).
Terrain classification must follow source sampling coordinates, not a fixed
screen-space horizon or the shared background layer tag.

Important source clarification: WORLD.ASM's `if_ground` branch selects the
ground-dot mode (`dotsflag=1`); it does not emit per-pixel terrain coverage.
That flag alone is not sufficient to enable the planar terrain converter.
No terrain mask has been inferred from the screenshot's colours.

## Explicitly masked GPU terrain guides

Terrain sampling now accepts current-frame raster jitter, reconstructing the
plane at the displaced sample while excluding jitter from motion vectors.
D3D12/Vulkan checks pass 2560 samples including zero/fractional jitter on
sloped planes. Nonfinite jitter is rejected. This is converter support, not
yet a connected full-scene gameplay jitter sequence.

Follow-up validation rejects degenerate plane normals and non-affine camera
history. The GPU suite now passes 1280 guide samples on D3D12 and Vulkan,
including sloped planes, terrain behind either camera, exact coverage value 1
(other values are not terrain), existing model depth and reset behavior.
This strengthens the converter; terrain-mask integration is still outstanding.

GpuTemporalInputs now accepts optional visible-terrain coverage, a camera-space
plane and current/previous projection/camera data. On-device ray/plane
intersection provides depth and reprojection provides motion only for explicitly
covered pixels without valid model depth. Uncovered artwork stays unknown;
resets preserve depth but invalidate motion. This path has no CPU pixel readback.

D3D12/Vulkan checks pass 512 depth/motion cases spanning masked/unmasked pixels,
model ownership, resets, invalid source guides and exposure. Generated DXIL,
SPIR-V and Metal bindings validate (no Metal execution claimed). PC builds.
The terrain API is not yet enabled in gameplay: reliable terrain-only coverage
must still be carried from the cartridge renderer into composition. Full-world
DLSS is therefore still incomplete; a plane alone does not classify artwork.

## Camera axes and terrain ownership follow-up

SDK camera direction vectors are now normalized after inversion of the
Q15-derived view matrix; the exact quantized matrix still drives reprojection.
Unit tests cover quantized axes, up-sign conversion and degenerate/nonfinite
rejection. `tmp/dlss-gameplay-camera-unit-axes` passes 16 Original/EX evaluation
frames with only the initial reset and clean shutdown; PC build passes.

Terrain input investigation: the PC scenery pass rewrites all scenery tags to
PixelLayer::background, and GpuBackground preserves no terrain-only ownership.
The optional shadow receiver plane therefore cannot by itself identify terrain
pixels: sky, planet art and tunnel art share that tag. Full-world temporal depth
needs an explicit terrain coverage source carried through composition, not a
blanket plane intersection applied to all background pixels. No guessed terrain
depth or motion has been enabled.

## Interpolated gameplay camera history

The PC host now forwards the actual interpolated gameplay camera and Q15-derived
view matrix to DLSS. Clip history combines projection changes with current-view
to previous-view mapping, and SDK camera position/basis follow that camera.
Mapping inverts the quantized matrix rather than assuming an exact orthonormal
rotation; translations follow the game's 65536-unit coordinate wrap. Singular
or nonfinite camera transforms fail back to the complete original frame.

Math tests cover rotation/translation, wrap crossing, combined clip mapping and
invalid camera input. `tmp/dlss-gameplay-camera-history` passes 96 frames each
of Original/EX at 240 FPS with exactly one initial reset, no evaluation errors,
clean shutdown and exact queued/serialized comparison. `ORIGINAL-on.png` was
visually inspected: world and restored HUD remain present. This supersedes the
earlier missing-rigid-camera-history limitation for the diagnostic PC gameplay
path. Background/ground per-pixel guides and full-scene jitter are still missing;
camera constants alone do not implement them. Broader scene/cut coverage remains.

## Static-model history continuity

Fixed a real periodic-reset bug: the application gives static models the global
animation counter, but both ModelMotionHistory and GpuModel compared its raw
value. Each simulation tick therefore discarded unchanged geometry history.
Both now compare selected geometry frames (static shapes always match; animated
shapes compare modulo the decoded frame count). Different geometry frames still
invalidate correspondence, as do entity changes, missing frames and scene cuts.

History unit tests cover static tick changes, distinct animated frames and
wrapped frames. D3D12/Vulkan motion checks cover different static counters at
1x/2x/4x, stationary/moving and jittered/un-jittered geometry. Runtime proofs:
`tmp/dlss-gameplay-static-history` has 64 evaluated frames at 60 FPS, and
`tmp/dlss-gameplay-static-history-240` has 96 at 240 FPS, for each experience.
All have exactly one initial reset, clean shutdown, no evaluation errors, and
byte-identical queued/serialized captures. Earlier runs reset every few frames.
The test runner now asserts the evaluation count and optionally requires
continuous history for these stable-scene fixtures. This is not full DLSS
completion: world inputs, host jitter and user-facing modes remain outstanding.

## Projection history

The host now uses a validated, shared perspective/inverse calculation and carries
projection-only clip reprojection across successfully submitted evaluations.
Changed focal length or principal point no longer silently receives identity
clip transforms; reset frames still do. Invalid/nonfinite projection inputs fail
back to the complete original image. This assumes the same camera coordinates:
it does not yet supply the missing rigid camera-motion history.

`starfox_temporal_projection_tests` passes 144 samples spanning aspect ratios,
focal lengths, off-center views and depths, checking pixel projection and both
reprojection directions to 1e-5 normalized-device tolerance. Invalid inputs are
also rejected. `tmp/dlss-gameplay-projection-history` passes Original/EX real
evaluation and exact queued/serialized output comparison, with clean shutdown.
These runtime scenes are regression coverage, not proof of every camera cut.

## Queue-ordered evaluation

Removed the host's per-frame CPU fence wait. The pinned SDL D3D12 backend submits
guide conversion, native evaluation, HUD restoration, effects and presentation
on one command queue; transitions and submission order protect resident texture
reuse. Resize/reconfiguration and shutdown still wait for GPU idle. Failed
output allocation now triggers reconfiguration on the next attempt.

`tools/check_dlss_lifecycle.ps1 -Evaluate -CompareSerialized -OutputDirectory
tmp/dlss-gameplay-queue-ordered` passes Original and EX, with byte-identical final
captures between queue-ordered and explicitly GPU-idle-serialized evaluation,
distinct DLSS-off captures, no SDK evaluation errors, and clean shutdown. This
is synchronization regression evidence, not a measured FPS improvement or
completion of temporal reconstruction quality. PC build and diff checks pass.

## Model raster jitter plumbing

GpuModel/GpuScene now accept an explicit output-pixel raster displacement without
mutating temporal history poses. Planar depth follows the displaced projection;
motion removes the displacement when reconstructing current camera positions.
Nonfinite offsets and jitter on non-subpixel geometry are rejected. The default
zero displacement preserves existing callers.

The geometry-depth check passes on D3D12 and Vulkan with stationary and translated
models, zero/nonzero jitter, 1x/2x/4x scales, and scene/compositor HUD ownership.
The PC target builds. This is renderer plumbing, not completed DLSS jitter:
the host sequence, SDK sign convention, and non-model world jitter remain to be
connected and validated. No menu/release readiness is implied.

## Gameplay world/HUD split (latest)

The diagnostic gameplay path now retains the CPU backdrop at native-layer
insertion, before later HUD writes. It composes a separate world-only GPU input,
excluding two_d-tagged CPU/native/late artwork while retaining subsequent non-HUD
world writes. DLSS evaluates that world input; a new GPU pass restores exact
two_d-tagged pixels from the original final compositor output before normal
effects/presentation. Host overlays already applied afterward remain afterward.
Failure falls back to the original complete frame, not the HUD-free input.

Evidence: D3D12/Vulkan HUD restoration checks cover 128 exact pixels across all
five layer tags, opaque black and output-alias rejection. The compositor suite
adds world-only native/CPU HUD exclusion at multiple scales; all 108 existing
composition fixtures and effects/overlay suites still pass on D3D12.
`tmp/dlss-gameplay-world-separated` passes Original/EX actual evaluation/display
and clean SDK shutdown without SDK errors. Inspected `ORIGINAL-world.png` and
`EX-world.png` contain no gameplay HUD; `ORIGINAL-on.png` restores the HUD over
the evaluated world. These are Corneria captures, not all-scene acceptance.

This currently duplicates composition and snapshots CPU backdrop data only in
the opt-in diagnostic path. Native HUD coverage can hide earlier native geometry
before the scene reaches composition; complete occlusion/disocclusion behavior
still needs broader auditing. World motion, jitter/camera history, SR modes,
capability-gated settings and performance/quality acceptance remain unfinished.
No release pushed; the earlier note that all HUD is still sent to DLSS is
superseded for this newly split diagnostic gameplay path.

## First actual gameplay evaluation and display

`STARFOX_TEST_DLSS_EVALUATE=1`, together with the lifecycle and temporal-input
switches, now runs diagnostic DLAA on actual PC gameplay textures. GpuComposite
color and resident guides flow through GPU guide conversion, the scoped native
SDL command bridge, the C SDK evaluator, and back into the resident effects/
presentation path. No gameplay color/depth/motion CPU readback is used. The host
checks a common model projection, supplies explicit perspective parameters,
resets on history loss/epoch/gaps, and releases the viewport before shutdown.
Renderer changes shut down this experimental session instead of reusing stale
device resources. Normal launches do not activate any of this.

Evidence: `tools/check_dlss_lifecycle.ps1 -Evaluate -OutputDirectory <new-dir>`.
`tmp/dlss-gameplay-sdk-checked` passed 16 real evaluated/displayed frames each in
Original and EX at 800x448, distinct off/on captures, clean shutdown, and no SDK
errors (SDK warning/error logging is now captured). Initial captures in
`tmp/dlss-gameplay-first/ORIGINAL-on.png` and `EX-on.png` were visually inspected.
Warnings about ignored unrequested plugins and the temporarily retained native
swapchain reference during restoration are not treated as SDK errors.

**Not release-ready:** only equal-resolution diagnostic DLAA is connected, not
the game's SR quality selectors. Game geometry is not yet jittered; non-model
world motion/depth and full camera-history matrices remain incomplete. HUD is
still in this diagnostic input and must be separated before shipping. Current
acceptance proves evaluation/display/lifetime, not reconstruction quality or
performance. No DLSS menu choice, NVIDIA-only Quest option, neural runtime
redistribution or release push was added. DLSS5-style gameplay is not proven.

## Native command and real presentation hooks

The SDL D3D12 bridge now scopes native compute work between SDL passes, passing
borrowed native textures/list with explicit read/UAV states and restoring SDL
resource states/descriptor heaps afterward. The caller must bind a new pipeline
before later drawing. Nine RGBA8/R32/RG32 native-command/round-trip checks pass,
including alias and output-index rejection. This is not yet a gameplay DLSS call.

The default-off lifecycle path now upgrades SDL's actual swapchains immediately
after creation, so real SDL presentation reaches Streamline bookkeeping. It
restores the original owned interface before swapchain destruction and before
SDK shutdown. An initial test uncovered a leaked native reference preventing
SDL swapchain recreation and causing cleanup failure: `slUpgradeInterface`
retains a native reference but does not consume the original caller reference.
Fixed that ownership in both the adapter and analytical probe.

`tmp/dlss-game-present-hooks-fixed` proves Original/EX startup, three successive
swapchain upgrade/restore cycles, gameplay, clean SDK shutdown and unchanged
off/on pixel captures. The prior `dlss-game-present-hooks` and GDB log are failed
diagnostics, not acceptance. `check_dlss_lifecycle.ps1` now requires actual
presentation upgrade/restore evidence as well as device binding/shutdown.

Remaining: invoke evaluation with complete gameplay color/temporal textures,
world motion and jitter, preserve HUD separately, expose gated settings, and
verify evaluated gameplay quality/performance. No release pushed.

## GPU temporal texture conversion

`GpuTemporalInputs` now converts resident camera-Z and float4 motion buffers to
the exact DLSS formats: projected R32 depth, RG32 pixel motion, and a 1x1 R32
exposure texture. It records a compute pass without submission/readback. Near/
far are explicit camera inputs. Unknown/nonfinite/out-of-frustum depth maps to
far depth; invalid, reset or mismatched-depth motion maps to the SDK's -FLT_MAX
sentinel, not valid zero motion. Reset accepts a missing motion buffer without
reading it. This does not synthesize missing background/ground correspondence.

The depth checker adds 256 conversion samples covering valid/invalid camera Z,
near/far bounds, nonfinite values, rejected inputs, reset without previous motion,
depth/motion ownership and exposure. D3D12 and Vulkan checks pass. DXIL/SPIR-V
compile and generated Metal bindings validate; no Apple execution claim.
Native SDL/D3D12 texture interop now checks all three required formats (RGBA8,
R32, RG32): nine byte-exact round trips at widths 37/128/259, with all previous
DXR mask/effects checks still passing. No CPU readback was added to production.

This converter is ready for the host's frame handoff, not yet called by gameplay.
Complete world inputs, jitter and evaluated-gameplay integration remain required.

## SDK lifecycle connected to PC (latest)

The native adapter now provides trusted initialization, actual-device LUID
capability checks/binding, viewport release and shutdown. Official Streamline
secondary signatures and NGX Authenticode are verified before secure absolute-
path loading. Initialization is single-instance, downloads are disabled, and
the bound device is retained through SDK shutdown. The probe uses this lifecycle
and completed another 128 evaluated frames in `tmp/dlss-native-lifecycle-evaluation`.

PC `DlssHost` uses that same C ABI behind `STARFOX_TEST_DLSS_LIFECYCLE`, requiring
explicit absolute `STARFOX_DLSS_ADAPTER` and `STARFOX_DLSS_BINARIES` paths. Default
launches load nothing. Initialization precedes SDL. The first actual-game smoke
test exposed a shutdown access violation when SDL destroyed its renderer first;
fixed by waiting for GPU idle and shutting down SDK before Window destruction.
`tools/check_dlss_lifecycle.ps1` now passes Original and EX startup, actual GPU
binding, 16 gameplay presentations, and clean shutdown. Captures with lifecycle
off/on are identical (`tmp/dlss-game-lifecycle-fixed`). Earlier failed smoke logs
are diagnostic only. This is lifecycle integration, not gameplay evaluation.

Remaining: resident guide textures, complete world motion/depth and jitter,
evaluation/presentation wiring, HUD separation, capability-gated menu settings,
and actual evaluated-gameplay quality/performance acceptance. No release pushed.

## Reusable native evaluator (latest)

`starfox_dlss_native.dll` now separates real DLSS configuration/evaluation from
the analytical fixture. `include/starfox/render/dlss_native.h` is a versioned
plain-C boundary usable by the MinGW game and MSVC SDK adapter: no SDK/STL types,
exceptions or ownership transfer cross it. The caller supplies actual D3D12
textures, states, matrices, jitter, frame identity and reset. The adapter checks
ABI size, finite camera inputs, resource formats/extents/device ownership,
aliasing and expected states before tagging/evaluating. Errors are bounded
strings and failure codes; malformed input is rejected before evaluation.

Evidence: `tmp/dlss-native-abi-evaluation` completed 128 real GPU-evaluated frames
across four modes and all 16 saved output images match the pre-refactor fixture
byte-for-byte. Aliased resource and ABI-size rejection checks run before each
mode. `tools/check_dlss_native_abi.cpp`, compiled with the game's MinGW compiler,
loads the MSVC DLL and passes cross-compiler frame-size, failure and bounded-error
checks. Configuration now also passes through the C interface; the follow-up
fixture is `tmp/dlss-native-config-evaluation`.

This adapter records evaluation only. Trusted SDK startup before DXGI, adapter
capability checks, device binding, queue synchronization, presentation hooks,
viewport release and SDK shutdown remain responsibilities of the integrating
host. The existing probe owns those today; the game does not yet call the DLL.
No NVIDIA binaries are copied into the game or release by this change.

## Native texture handoff verified (latest)

The pinned SDL D3D12 backend now exposes an optional versioned texture bridge.
It copies matching single-mip, single-sample 2D textures in either direction
between SDL and native D3D12 resources without CPU mapping. It validates device
ownership, dimensions, format and aliasing before recording commands, restores
native COMMON/SDL default states, and tracks SDL resource lifetimes. External
resources remain caller-owned through GPU completion; separate-queue evaluation
must use the existing fence bridges. Existing older buffer bridge ABIs remain
unchanged. This does not itself initialize or evaluate DLSS.

`starfox_sdl_d3d12_interop_check` passes exact RGBA round trips at widths 37,
128 and 259 (height 23), rejects mismatched/null inputs, and still passes all
12 existing animated/resized DXR buffer/effects comparisons. Diagnostic
readback is confined to the checker. The new source compiles with the current
MinGW PC toolchain; official NVIDIA SDK code remains in the separate MSVC probe.

Still required before release: native SDK lifecycle/evaluation integration,
complete temporal world inputs/jitter, HUD separation, capability-gated UI,
and evaluated gameplay acceptance. Do not label the texture bridge as finished
DLSS or a measured performance improvement.

## Gameplay history and final composition connected (latest)

`STARFOX_TEST_TEMPORAL_INPUTS=1` now connects validated presentation history to
the PC mono GPU scene. `ModelMotionHistory::prepare` rejects duplicate current
identities as well as previous duplicates. Only a successful GPU presentation
and successful SDL present commit the new poses. Scene/camera cuts, save-state
loads, renderer recreation, context/stereo changes and failed/native-fallback
presentations invalidate history. The production menu does not expose this
test switch as DLSS; no NVIDIA evaluation is yet called by gameplay.

The first live comparison caught a depth-only request incorrectly publishing
lighting metadata on native shadows. Fixed by separating geometry-plane
preparation from effects metadata publication. Enabling temporal inputs now
leaves captured game pixels byte-identical to the disabled path.

`GpuCompositeOutput` now carries resident camera depth and float4 motion through
native viewport offsets, source/destination scaling, clipping and foreground
coverage. Opaque black/same-color HUD writes, post-late CPU writes, late GPU
overlays and solid margins invalidate underlying guides. Mosaic remains unknown
rather than publishing a false pinhole correspondence. Data stays GPU-resident.

Evidence:
- `tmp/temporal-gameplay-240-fixed`: Original/EX 240Hz, initial reset and later
  resident depth/motion, identical enabled/disabled captures.
- `tmp/temporal-gameplay-state`: D3D12 240Hz Original/EX, saved frame 4, loaded
  frame 10, asserted no previous pose on presentation 11, identical captures.
- `tmp/temporal-gameplay-60-vulkan`: Vulkan 60Hz Original/EX, same input/pixel checks.
- D3D12 and Vulkan model-depth checker: previous plane/motion tests plus final
  composite offset, differing render scales and explicit CPU coverage checks.
- Full existing D3D12 compositor checker passes, including 108 base fixtures and
  its overlay/effect coverage suites. Stereo/history unit test passes.

Remaining: complete world/non-model temporal inputs, jittered game rendering,
native NVIDIA texture and evaluation handoff, HUD exclusion from the neural
pass, capability-gated settings, and actual evaluated gameplay acceptance.
The new test switch is input-generation evidence, not a finished DLSS option.

## Actual DLSS and neural evaluation verified (evening update)

The optional second argument of `starfox_streamline_probe` now runs an actual
D3D12 evaluation fixture, not just capability queries. It supplies analytical
moving foreground/background color, perspective depth, previous-minus-current
motion, subpixel jitter, explicit exposure, and two history resets per mode.
Quality, Balanced, Performance and DLAA each completed 32 frames on the RTX
5070 Ti Laptop: 128 evaluated, fence-completed frames with changing output and
foreground-area checks. Output is 1280x720; input dimensions were respectively
853x480, 742x418, 640x360 and 1280x720.

The initial evaluation exposed a missing frame-tagging preference and then a
missing manual-integration presentation hook. Both were fixed. The clean run
upgrades its own hidden swapchain, presents once per frame, and has no SDK
error messages. Proof: `tmp/dlss-evaluation-present/evaluation.txt`, PPM images
and `tmp/dlss-evaluation-present.log`. The earlier `first` and `second` runs are
diagnostics, not clean acceptance results.

The same evaluator was copied into `tmp/renodx-dlss-evaluation`, with the
previously authorized author add-on and signed NR runtime. ReShade.log now
explicitly reports **inline feature 18 evaluation succeeded**, including count
60, rather than merely reporting a loaded DLL. Its first evaluation was skipped
because host-state tracking was incomplete; subsequent evaluations succeeded.
GPU-read-back output differs from plain DLSS, and the final Quality image was
visually inspected. This verifies the neural path on the analytical fixture;
it is NOT evidence of neural gameplay, visual quality across levels, or FPS.
No neural binaries were added to the normal game or release package.

Reproduce plain DLSS (new output directory required):

```powershell
build/streamline-probe-msvc/starfox_streamline_probe.exe tmp/streamline-sdk-2.14.1/sdk tmp/dlss-evaluation-new
```

## Per-pixel model motion integration

`GpuProjection::enqueue_motion_surface` now reconstructs a visible camera-space
point from planar depth and reprojects it through rigid-object previous pose.
It returns pixel-space XY, camera Z and explicit validity. It handles projection
changes and current jitter; reset, unknown/nonfinite depth and previous-near
clipping invalidate motion instead of fabricating valid zero vectors. All 728
analytical samples pass on D3D12 and Vulkan.

`GpuModel::enqueue` accepts an optional preceding pose and chains this pass
directly after its resident raster depth. Packed current/previous transforms
produce the mapping without CPU per-vertex projection. Changed coordinates,
singular/mismatched byte/word transforms and native word-wrapped paths reject
correspondence. Destruction, folded faces and screen-space deformation retain
unknown motion. `GpuScene` carries motion according to visible color ownership;
opaque HUD writes invalidate it, even when black. Motion-bearing draws bypass
the fused raster merge so no prior object's motion is silently discarded.
Stereo copies transform both current and previous poses into the same eye.

Model translation and opaque HUD ownership tests pass at 1x/2x/4x on D3D12 and
Vulkan alongside the existing 366,183 planar-depth samples. Normal gameplay
still does not request temporal data: history/scene resets, non-model world
inputs, jittered rendering and native texture/evaluation handoff remain to be
connected before a working DLSS option can ship. Earlier sections below record
the progression and should not be mistaken for the latest evaluation status.

Final checks for this pass: Windows executable rebuilt; six targeted runtime,
stereo, core and raster checks passed (27.55 seconds). Linux software Vulkan
also passed both the model-depth/motion and full projection checkers. DXIL,
SPIR-V and generated Metal source pass freshness/binding checks; Apple GPU
execution and Android rebuild are not included in this pass. No release was
published and no new PC/Quest handoff archive was made.

## Planar model depth integration

`GpuModel::enqueue(..., geometry_depth=true)` now produces a separate float
camera-Z buffer. GPU surface preparation computes planes from actual transformed
vertices; source face IDs survive BSP/span ordering in the existing command ABI.
Rasterization evaluates the plane at each covered pixel centre, after texture
transparency, using the model's projection. Native rounded vanishing points and
fractional/high-resolution projection are distinguished. Existing mean-depth
effects metadata is unchanged. Unknown depth is zero; folded/nonplanar faces,
lines/sprites, colour-warp, wave and wobble paths do not fabricate valid depth.

`GpuModelDraw::geometry_depth` carries this opt-in through mixed scenes and
stereo draw copies. Fused raster composition and separate scene merge preserve
depth according to visible colour ownership (not effects surface ownership).
An opaque black/HUD overlay invalidates its pixels' depth; untouched pixels
retain the background depth. No per-frame readback is used in production.

`starfox_gpu_depth_check` passes on D3D12 and Vulkan: 366,183 analytical sloped
plane samples at native/fractional 1x/2x/4x, including fractional vanishing
points; exact unchanged colour/effects output; folded-face invalidation; mixed
scene painter ownership; byte-identical fused/separate depth composition.
Additional existing checks pass: 192 Original real-model mixed-batch images
on D3D12, 12 EX Arwing and 12 EX BOXXIE images on Vulkan, and mixed raster
binning comparisons on both backends. An initial EX first-16-header sample
failed the nonempty-fixture check and is not counted as passing evidence.

This is not a complete DLSS input set: per-pixel motion, ground/background and
other nonplanar geometry depth, jitter/history integration, GPU texture handoff
and actual evaluation remain. The normal game's draw records do not yet opt
into this buffer. DXIL/SPIR-V compile and execute; Metal source is generated
and binding-validated, not Apple-compiled or hardware-tested.

After the final shader change, all Windows targets rebuilt successfully and
both backend depth checks passed again. Eight targeted CTest checks passed
(11.49 s): packed faces/projection, raster commands, core, stereo output,
Original/EX runtime smoke, and isolated effects. This is not a fresh full
55-test run or headset acceptance.

```powershell
cmake --build build/current --target starfox_gpu_depth_check
$env:SDL_GPU_DRIVER='direct3d12' # repeat with vulkan
build/current/starfox_gpu_depth_check.exe
```

## Authorized isolated add-on test

User explicitly approved loading the unsigned author V4.7 add-on in isolation.
`tmp/renodx-isolated-d3d12` contains a copy of the Windows executable/assets,
the author add-on/NR DLL, official SDK SR DLL, and ReShade64.dll extracted from
the official ReShade 6.8.0 Addon installer and named dxgi.dll. No installer was
run and the normal game directory was not modified. No Vulkan/global layer was
installed. Both the setup-menu run and a 180-frame Original Corneria run exited
0 on D3D12. ReShade.log confirms V4.7 registration and the signed NR runtime's
reference hash match, but supplies no evidence of neural frame evaluation.
Native capture `corneria-capture.bmp` was inspected; it occurs before ReShade
and is NOT photographic proof of neural output. The game still has no native
DLSS evaluation path, so loading successfully does not make realism functional.

## Verified capability probe

User approved the official SDK license. The isolated Windows/MSVC target in
`tools/streamline_probe` now initializes the approved SDK and checks actual DXGI
adapter LUIDs. NVIDIA's secondary signatures are validated for Streamline DLLs;
NGX's different signing scheme is checked through standard Authenticode. DLL
search is restricted, OTA/downloaded plugins are disabled, and no game files
are replaced. This is not renderer integration or a working menu option.

Built and executed against official v2.14.1: `slInit` and DLSS requirements
return `eOk`; the primary RTX 5070 Ti Laptop adapter returns `eOk`. Intel and
the other exposed adapters return `eErrorAdapterNotSupported`, including a
second adapter bearing the NVIDIA name. This demonstrates why capability must
be checked per adapter, not inferred from its name. No frame was evaluated.

Device follow-up: the probe now creates a D3D12 device on the supported adapter
and resolves DLSS's optimal-settings API after `slSetD3DDevice`. A locally
generated custom-engine project GUID was required; without it NGX unloaded the
feature despite the earlier support result. With that identity the device and
all four queries pass: 1920x1080 output requests 1280x720 Quality, 1114x626
Balanced, 960x540 Performance, and 1920x1080 DLAA. Device lifetime extends past
Streamline shutdown. This is still not a rendered/evaluated DLSS frame.

Reproduce from a VS x64 developer shell (paths can be absolute):

```powershell
cmake -S tools/streamline_probe -B build/streamline-probe-msvc -G Ninja -DCMAKE_CXX_COMPILER=cl -DSTREAMLINE_SDK="<extracted official SDK>"
cmake --build build/streamline-probe-msvc
build/streamline-probe-msvc/starfox_streamline_probe.exe "<extracted official SDK>"
```

After the user explicitly requested joining, the RenoDX wiki's
`https://discord.com/invite/renodx` invite unlocked the server. Download channel:
https://discord.com/channels/1408098019194310818/1545049227321810974

Downloaded the channel's forwarded V4.7 `renodx-dlss5.addon64` and companion
`DLSS310.8.0-Streamline2.13.zip` into `tmp/renodx-author-downloads`; extracted only
`nvngx_dlssnr.dll`. Subsequently loaded only in the authorized isolated test above.
The add-on is unsigned; the neural DLL has valid NVIDIA Authenticode. This
establishes the download source and DLL signature, not add-on safety, bridge
compatibility, or redistribution rights. The archive contains DLLs but no
license files. The channel also offers a separate ShortFuse `renodx-dlss.addon64`
variant; its posted instructions say the two add-ons cannot be used together.

SHA-256 evidence:
- V4.7 add-on: `D5ADF82EB44B065F4C590AC91FE824BAB07AFEA0EB9F994BDE936710C8593952`
- Companion ZIP: `3FDB7CB25250259332550F419DBAC516A2EBA778D8592DA75CB2FE8ABFC781D8`
- Neural DLL: `E16BCF15E16E13F527491CDF7845B2FE6521A738D8F7C9C721866A8496E1FC8E`

## User-provided experimental bridge

https://github.com/NIGos/dlss5-bridge provides a possible unofficial ReShade
route; absence from Streamline's public API does not rule this out. Inspected
README and MIT license. The bridge itself does not perform neural rendering:
it requires a separate compatible neural add-on and nvngx_dlssnr.dll (README
points to RenoDX's Discord distribution), plus ReShade and the SR runtime.
Those neural components have now been obtained as recorded above; the bridge's
MIT license does not establish redistribution rights for them.

Native DLSS inputs are preferred. The optical-flow substitute requires usable
depth and approximate motion and documents soft text/smearing. Vulkan mirror
also documents synchronization stalls; stereo/multiple-view compatibility is
not established for this game. Any eventual support must be experimental,
default off, and preserve HUD outside the neural pass. No bridge or third-party
neural DLL has been added to the normal game installation. The authorized
isolated test is documented above. The official Streamline v2.14.1
SDK is extracted in tmp and used by the isolated capability probe above,
not bundled or integrated into the game.

Requested: DLSS Super Resolution and an AI-realism option. Neither is
implemented or exposed as a working menu choice yet. Both must default off
and be capability-gated; Quest must not display NVIDIA-only features.

Verified local adapter: NVIDIA GeForce RTX 5070 Ti Laptop GPU, driver 595.79.
Public NVIDIA-RTX/Streamline release: v2.14.1. Its public include directory
exposes DLSS SR, Ray Reconstruction and Frame Generation; no DLSS 5 neural
rendering header/API was found. NVIDIA's September 1 DLSS 5 research page
describes RTX 50-series appearance generation, but is not an integration SDK.
Do not substitute Ray Reconstruction or a color-grading preset and label it
DLSS 5. That portion needs an available official integration interface.

Super Resolution integration prerequisites (official ProgrammingGuideDLSS):
render-resolution color, depth, motion vectors, output-resolution color,
camera matrices/jitter, history-reset handling and feature capability checks.
GpuSceneDraw now carries optional object identity (slot, pool generation,
shape, strategy and type), populated by the PC object's actual draw path and
preserved across stereo eye copies. Unidentified helper/shadow draws remain
explicitly unidentified. The stereo regression passes, including recycled-slot
and changed-shape inequality. Previous presentation poses, scene/reset epochs,
and motion-vector surfaces are not connected to the renderer yet.

`ModelMotionHistory` now implements the previous-pose store for successful
presentation submissions, with explicit serial/epoch/dimension checks. Tests
cover recycled entities, topology animation/explosion changes, skipped frames,
duplicate identities, disappearance, projection changes and reset. It is not
enabled in normal rendering: the future caller must supply scene/load-state
epochs, reject ambiguous current identities, and commit only submitted frames.
This is CPU pose metadata, not CPU-generated motion-vector pixels.

GPU vertex motion is now implemented by `GpuProjection::enqueue_motion` and
`motion_portable.hlsl`: paired unjittered projected vertices produce
previous-minus-current render-pixel XY, linear camera Z, and validity. The
pass records into a caller-owned command with no submission/readback. GPU
checks pass on D3D12 and Vulkan for movement direction/scale, stationary valid
vertices, history reset, behind-camera points, NaN, overflow, and alias rejection.
DXIL/SPIR-V compile and generated Metal source/bindings validate; Metal execution has
not been tested. This is not yet wired into the normal model draw path, and
per-pixel interpolation, clipping correspondence, surface composition and DLSS
evaluation are still required. Do not expose a working DLSS menu choice yet.

Portability follow-up corrected the motion pipeline's Metal entry point to
`main0`, matching SPIRV-Cross output, and capped dispatches to the portable
65535-workgroup limit. Generated MSL is not evidence of compilation by Apple's
Metal compiler or of execution on a Mac.
Motion-vector generation and disocclusion/history correctness therefore need
real renderer work before a quality selector is useful. Do not fake zero
motion vectors or upscale the HUD as though it were world geometry.

Sources:
- https://github.com/NVIDIA-RTX/Streamline/releases/tag/v2.14.1
- https://github.com/NVIDIA-RTX/Streamline/blob/v2.14.1/docs/ProgrammingGuideDLSS.md
- https://research.nvidia.com/labs/adlr/DLSS5/
