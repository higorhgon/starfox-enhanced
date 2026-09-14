# GPU migration checkpoint

## Main briefing background enabled on GPU (September 13)

Removed the whole-scene briefing exclusion from early background recording.
The recorder already checks framebuffer identity: isolated BG2 portraits and
text still use their separate CPU targets, while main BG1/OBJ passes now use
the ordered resident scene. This is a runtime conversion of the main layer,
not completion of isolated overlay decoding.

The background checker now accepts scripted presses and presentation frame
counts to reach actual planet zoom/briefing phases. In
`tmp/background-briefing-main`, Original/EX PLANETSELECT with Start at frame 1
and capture at frame 240 match CPU backgrounds, forced GPU failure and CPU
models byte-for-byte at 16:9. Original planet/portraits and EX planet captures
were inspected. `tmp/background-briefing-main-effects` exercises frame 360 at
32:9/4x with effects; Original/EX comparisons pass and Original's title/dialogue opening
and portraits were visually inspected. Windows rebuilt; whitespace checks pass.

Isolated overlays, remaining late layers and sprite bitplane decoding remain;
no full migration, non-Windows verification or release claim is made here.

## EX introductory-logo margin repair on GPU (September 13)

EX's introductory logo no longer excludes the early background GPU path.
The compositor samples its early native top-left background colour, replaces
only palette-zero outer logical cells before models/CPU foreground, and
preserves nonzero stars/artwork. It uses logical top-left sampling at every
render scale, not individual subpixel tests. This differs deliberately from
the later dominant-colour solid margin fill. CPU fallback performs the same
repair on the replayed early layer before merging intervening CPU writes.

108 additional repair fixtures cover scales, clipping, mosaic, early sprites,
models and later foreground, passing with the compositor suite on D3D12,
Windows Vulkan and Linux software Vulkan. Actual EX TITLEMAP tick 30 asserts
the repair trace and matches CPU BG, forced failure and CPU model captures at
32:9/4x; the output was visually inspected. Vulkan effects and full SBS title
comparisons pass for Original/EX. Proof: `tmp/background-logo-30`,
`tmp/background-logo-effects`, `tmp/background-logo-stereo`.

Windows/Linux PC and Android builds pass. Six targeted regressions pass
(24.64 seconds); Original/EX Game Over GPU/CPU/mono-stereo failure captures
remain identical (`tmp/background-logo-gameover-regression`). Shader freshness
and scoped whitespace checks pass. No package/Quest installation was made.

Remaining background migration is now isolated briefing/planet layers and
late restored title/menu/native bitmap layers; sprite bitplane decoding also
remains CPU-side. This checkpoint does not close the full goal.

## GPU frontend edge-colour reduction (September 13)

The compositor now reduces the two native canvas edge histograms on GPU,
sampling one top-left stored pixel per logical row and retaining the first
palette index on ties. It fills solid widescreen margins before late GPU
stars/particles, clears overwritten model metadata and preserves fade flags.
Margin origin/width are validated; non-margin frames skip the reduction pass.
Generated D3D12/Vulkan/Metal bindings include the tiny resident result buffer.

Wide Controls, Continue and Game Over now use resident background scenes;
their previous CPU edge-read restriction is removed. Full CPU fallback fills
the reconstructed margins before late dust. The explicit CPU-late-dust path
resolves the omitted background and margins before drawing stars, rather
than allowing the GPU fill to erase them later. An initial wide Game Over
comparison exposed this ordering bug; the final rerun passes.

108 edge-reduction cases plus late-overlay ordering and invalid-range checks
pass with the compositor suite on D3D12, Windows Vulkan and Linux software
Vulkan. Original/EX Controls and Continue match CPU backgrounds, forced
failure and CPU models at 32:9/4x with effects; Controls SBS also matches.
Original/EX Game Over at 32:9/4x is byte-identical across GPU, CPU late dust,
mono failure and stereo failure. Proof directories:
`tmp/background-margin-controls`, `tmp/background-margin-continue`,
`tmp/background-margin-stereo`, `tmp/background-margin-gameover-final`.

Windows/Linux PC and Android builds pass; six targeted regressions pass
(26.18 seconds). Shader freshness and scoped whitespace checks pass. A final
local-variable rename only clarifies that margin reduction is no longer CPU.

Still incomplete: EX introductory-logo margin repair, isolated briefing
layers, restored late title/menu/native bitmap layers, and sprite bitplane
decoding. No whole-migration completion, release or Quest update is implied.

## Ordered cartridge-layer runtime integration (September 13)

The game loop now records complete early tile/OBJ priority sequences into a
resident background scene, rather than accepting only a single gameplay BG2
pass. `RecordingBackgroundRenderer` flushes pending sprite raster chunks
before each BG1/BG2/BG3 draw using one immutable PPU snapshot. Recording ends
before subsequent model/foreground composition. World tags reproduce the
CPU's post-background retagging; front-end artwork retains 2D tags. Fallback
replays the whole sequence, including explicit black sprite writes and the
correct tag for untouched backdrop pixels. CPU background cache reuse is
disabled only while that frame's background is resident.

Final captures are byte-identical against CPU backgrounds, forced GPU failure
and CPU models for Original/EX TITLEMAP, PLANETSELECT and 4:3 CONTMAP. Vulkan
32:9/4x title/gameplay effects and full SBS title checks also pass; final
effects checks cover asteroid and planet selection. The Original planet map
capture was visually inspected. Proof: `tmp/background-ordered-title`,
`tmp/background-ordered-controls`, `tmp/background-ordered-planets`,
`tmp/background-ordered-effects`, `tmp/background-ordered-stereo`,
`tmp/background-ordered-final`. Game Over's existing mono/stereo fallback
captures remain identical (`tmp/background-ordered-gameover`).

Windows/Linux PC and Android rebuild successfully. Remaining CPU dependencies
are explicit: wide Controls/Game Over/Continue edge-colour reduction, EX
intro-logo margin repair, isolated briefing layers and late restored title/
menu/EX bitmap passes. Sprite bitplane decoding still runs on CPU to produce
the ordered raster commands; its rasterization and merge run on GPU. These
are remaining migration work, not reasons to mark the full goal complete.

## Mode 2 gameplay now uses resident BG2 (September 13)

The normal PC/SDL game loop now defers Mode 2 gameplay BG2 into the GPU
background decoder. It snapshots raw PPU state plus interpolated scrolls and
unique-region rules, retains early CPU-write coverage at model insertion,
and supplies the final-resolution resident layer to composition. It skips
the former CPU BG2 decode/cache path for these frames. Both stereo eyes use
the same convergence-plane background. Submission/composition failure restores
the CPU background before model/foreground replay; failure of a stereo eye
declines stereo as a unit and rebuilds mono. Indexed diagnostics and CPU
rendering retain the original path. `STARFOX_DISABLE_GPU_BACKGROUND` is a
comparison hook; `STARFOX_TEST_FAIL_BACKGROUND_GPU` exercises recovery.

`tools/check_background_gpu.ps1` verifies actual resident tracing and compares
final presentation hashes. Original/EX LEVEL1_1 and LEVEL1_2 match CPU BG2,
forced background failure and CPU models at Vulkan 32:9/4x, and with model/
world effects, bloom, HDR and chromatic aberration at 16:9/2x. Original/EX
Corneria also match at half and full SBS. D3D12 mono Corneria passes; its
capture was visually inspected (`tmp/background-runtime-gpu-proof`). Other
proof directories: `tmp/background-runtime-wide`, `tmp/background-runtime-effects`,
`tmp/background-runtime-half`, `tmp/background-runtime-sbs`.

DXR Corneria proof (`tmp/background-runtime-rays/b0d9753f8a684e07886131f2c319408c`)
retains byte-exact CPU/GPU presentation and resident/readback equivalence;
the removed Enhanced Shadows override remains inert. Windows/Linux PC and
regular Android builds pass; six targeted regressions pass (24.28 seconds).
No new Quest install, package or FPS improvement claim. Remaining background
migration: Mode 1/3 and non-gameplay ordered cartridge layers, late title/menu
restoration and special presentation passes. The full goal is still active.

## Resident background composition ordering (September 13)

`GpuCompositeBackground` supplies a final-resolution GPU background plus a
separate mask for CPU writes made before native model insertion. The compute
compositor merges background, early CPU sprites, native models, later CPU
foreground and late GPU overlays in that order. Early sprite coverage does
not incorrectly occlude models; palette-zero and same-colour writes remain
explicit. Input dimensions, mask size, device and output aliasing are checked.
No background readback is needed. DXIL, SPIR-V and Metal bindings regenerated.

108 new underlay/order/recovery fixtures pass on D3D12, Windows Vulkan and
Linux/WSL software Vulkan, alongside the existing effects/transition suite.
Windows PC rebuilt. Original/EX Game Over captures remain byte-identical for
GPU, CPU and mono/stereo forced fallback (`tmp/background-underlay-gameover-regression`).
Shader freshness and scoped whitespace checks pass. This is the compositor
side of integration, not a claim that the game loop has stopped CPU background
decoding. That loop must retain early-write coverage and restore full CPU
backgrounds when resident submission fails before enabling this path.

## BG2 GPU decoding and HDMA continuation (September 13)

The ordered background component now accepts BG2 as well as BG1/BG3.
BG2 uploads raw VRAM, palette, scanline registers and unique-art regions;
GPU preparation fits the Mode 2 horizon using software-double arithmetic.
A GPU column pass preserves floor-wrap history, mosaic, tile priorities,
transparent coverage, tunnel wall fills, open-water edge continuation and
non-repeating planet/title regions. No CPU tile decoding or readback is used.
CPU replay and stereo records include all BG2 settings.

The expanded checker covers 432 cases / 183,997,440 pixel-and-coverage samples,
including 144 BG2 fixtures and mixed BG1/BG2/BG3 ordered replay. Windows Vulkan
exposed a negative mosaic-coordinate discrepancy; explicit unsigned floor
division fixes it and is shared by all background shaders. Generated Metal
source is available but has not been executed on Apple hardware.

Final component checks pass on D3D12, Windows Vulkan and Linux/WSL Vulkan.
Windows PC and affected test targets rebuilt; six targeted raster/core/stereo/
runtime/EX-intro/effects regressions pass (24.88 seconds). Both generated
background shader freshness checks pass. No fresh Android/Quest build or
headset installation was performed for this component-only batch.

This remains a component migration: normal gameplay's background/presentation
passes are not yet routed into these batches. No in-game FPS improvement or
complete background migration is claimed, and the existing handoff ZIP has
not been refreshed for this component work.

## Native BG1/BG3 GPU decoding and ordered batching (September 13)

New `GpuBackground` uploads the raw 64 KiB VRAM and CGRAM snapshot; tilemap
addressing, 2/4/8-bpp bitplane decoding, palette selection, flips, 16x16
characters, mosaic, wrapping, clipping and priority tests execute on GPU.
It returns indexed pixels/tags/explicit coverage without CPU tile expansion
or readback. Disabled layers clear output. Borrowed-command ownership requires
the caller to cancel on failure and consume each result before reuse/release.

`GpuBackgroundDraw` joins ordered scene batches with a shared immutable PPU
snapshot, interleaved legacy raster work, CPU replay and stereo copies at the
convergence plane. This avoids embedding a 66 KiB PPU object in every variant.
The mixed fixture retains its snapshot while live VRAM changes, places an
explicit black write between priority passes, and compares GPU output to replay.

`starfox_gpu_background_check` passes 288 cases / 66,908,160 packed
pixel-and-coverage samples on D3D12, Windows Vulkan and Linux/WSL Vulkan,
covering 1x/2x/3x/4x, all map sizes and priority modes, negative scrolling and
origins, VRAM wrap, insets, CGRAM-black transparency, disabled layers, release/
reuse and rejected dimensions/layer/origin inputs. Generated DXIL/SPIR-V execute;
Metal bindings are validated, not tested on Apple hardware. Six Windows
regressions pass (24.25 s), and Original/EX late-star normal/fallback captures
still match (`tmp/background-component-gameover-regression`).

**Not routed into normal gameplay yet.** The remaining work is ordered
background/foreground presentation integration plus BG2's HDMA and authored
extension rules. This is tested decoding/batching infrastructure, not a claim
that all background pixels have migrated or that gameplay FPS improved.

## Late world layer / Game Over stars (September 13)

Game Over's widescreen margin stars now use GPU dust projection, span generation
and rasterization. A same-device final-coordinate overlay joins GPU composition
after CPU foreground writes, before the existing effects/UI passes. Its explicit
coverage preserves black writes, untouched pixels and the central artwork;
covered pixels invalidate underlying model normals. Invalid dimensions/aliasing
decline without exposing stale output. The regular CPU path and complete
presentation fallback retain the original margin-only dust draw.

SBS supplies each eye's offset to the late star projection. Original full and
EX half SBS captures execute the late GPU pass; the Original image was visually
inspected. Normal mono and injected GPU failure captures are byte-identical to
CPU margin rendering for Original/EX at 16:9 2x and Windows Vulkan 32:9 4x.
See `tmp/game-over-gpu-proof`, `tmp/game-over-gpu-vulkan-wide`,
`tmp/game-over-gpu-sbs` and `tmp/game-over-gpu-sbs-ex`.

The expanded compositor checker passes 108 late-layer colour/tag/coverage,
normal-ownership, resize, stale-output and invalid-input cases on D3D12,
Windows Vulkan and Linux/WSL lavapipe, alongside its existing effects/overlay
checks. Linux requires the explicit `STARFOX_TEST_SOFTWARE_GPU=1` diagnostic
override; the first hardware-only attempts correctly declined this software
adapter and are not counted as passes. Normal hardware policy is unchanged.
Generated DXIL/SPIR-V execute; Metal bindings are validated, not Apple-tested.
Six targeted Windows regressions pass (27.52 s). This is not a fresh full suite
or a claimed FPS increase. The earlier handoff ZIP predates this late-layer work.

Final end-to-end verifier also requires actual margin ink and confirms the
injected fallback log, not merely equal captures. Both experiences pass normal,
CPU, forced mono-failure and forced SBS-failure comparisons at 16:9 2x and
Vulkan 32:9 4x (`tmp/game-over-gpu-complete-30`,
`tmp/game-over-gpu-complete-wide`). Stars are sparse/moving; a different fixture
at tick 60 has no outer star on its final frame and is not counted as visual
margin proof. Regular Android rebuild succeeds (21 s); no headset install or
replacement package was made.

## Controls model layer (September 13)

The Original/EX Controls player and its native shadow now join the deferred
GPU model batch after demonstration effects and before controller artwork.
The shared flight-panel clip and +16 Y placement are unchanged. The small
deferred list retains allocation between frames. Software rendering and full
scene replay remain available; Controls no longer forces CPU caster geometry.

Eighteen CPU/GPU final-presentation pairs are byte-identical: Original and EX
at ticks 60/300/600, at 16:9 2x, D3D12 32:9 4x and Vulkan 4:3 1x. The verifier
asserts both model recording and actual GPU residency. EX tick-300 artwork was
visually inspected. Evidence: `tmp/controls-gpu-proof`,
`tmp/controls-gpu-d3d12-4x`, `tmp/controls-gpu-vulkan`.

Original/EX Controls ray captures confirm GPU caster selection, equality to
CPU-geometry DXR presentation, equality to diagnostic readback, and unchanged
native output when DXR is unavailable (`tmp/controls-ray-proof` and
`tmp/controls-ray-ex-proof`). The Windows executable rebuilds and seven targeted
regressions pass (29.51 s). These are parity checks, not an FPS improvement or
fresh full-suite/headset acceptance. No package or release was published.

## Caster modes and stereo-only shadow passes (September 13)

Wave/wobble and colour-warp affect raster/material output, not the legacy
caster mesh. They now export the untouched GPU camera stream. Axis collapse
retains its pre-collapse camera stream and source topology. Exploding axes use
a separate GPU fragment-transform stream so their visible collapsed geometry
is unchanged. No normal caster-mode exclusions remain; explicit billboard
caster requests still decline because billboards were never polygon casters.

Windows D3D12/Vulkan checks pass 18 native/fractional effect/axis variants,
including colour-warp plus exploding axis collapse, against exact expected
caster positions. The extended Linux/WSL Vulkan run also passes after rebuilding
the checker and shared renderer. Seven targeted Windows regressions pass
(28.13 s); no full-suite or physical-headset acceptance is implied.

Normal resident SBS now renders only its two eye shadow masks. CPU casters
are built lazily on an actual eye failure, not unconditionally for an unused
mono pass. A presentation failure rebuilds the mono batch and its matching
shadow mask before fallback; a left-eye or old-frame mask is never substituted.

Proof (12 gameplay frames, both eyes resident, no CPU caster-fallback trace):

- Original full SBS: `tmp/sbs-casters-full/presentation.bmp`
- EX half SBS: `tmp/sbs-casters-half-ex/presentation.bmp`
- Windows Vulkan EX full SBS: `tmp/sbs-casters-vulkan-ex/presentation.bmp`
- Injected fallback: `tmp/sbs-casters-forced-fallback/presentation.bmp`
- Vulkan EX injected fallback: `tmp/sbs-casters-vulkan-fallback/presentation.bmp`

Original full and EX half SBS are byte-identical to separately rendered
diagnostic DXR reference captures (`tmp/sbs-casters-reference-full` and
`tmp/sbs-casters-reference-half-ex`). Original stereo/fallback images were
visually inspected. The fallback verifier skips host startup black frames so
its mono capture counter measures gameplay, not the loading screen.

## Live SDL caster geometry to DXR (September 13)

GpuScene now aggregates optional caster triangles directly into a resident
buffer. Immutable topology uploads are cached (128 entries / 16 MiB); cancelled
borrowed uploads are never promoted to the persistent cache. Models without
polygon casters do not invalidate the set. Known unsupported caster poses skip
the entire expansion path rather than spending work on a partial scene.

PC shadow submission now follows the deferred model batch, including Continue
and title models. Supported mono scenes no longer run CPU caster transforms.
The D3D12 and Windows Vulkan bridges transfer geometry to DXR shared storage;
an independent incoming fence/timeline orders the trace without a CPU copy wait.
Both stereo eye outputs are exposed and connected. Unsupported/mixed scenes
retain complete CPU caster reconstruction. At this checkpoint stereo still
constructed a CPU scene for its mono/fallback path; that is removed above.

Verified on D3D12 and Windows Vulkan: multi-model aggregation, resize/reuse,
native/continuous/compensated points, owned submissions, both stereo eyes,
cancelled topology uploads, target bounds/alias rejection, and exact DXR masks
against CPU-submitted reference geometry. Linux Vulkan aggregation/expansion
also passes. All Windows targets rebuild; seven targeted regressions pass
(27.79 s). Generated shader freshness/Metal bindings pass, not Metal hardware.

Fresh live captures require the GPU-caster backend and match diagnostic DXR
presentation byte-for-byte:

- Training: `tmp/shadow-gpu-final-training/38488ad53b7b4b56b3608d0d9bdb4972`
- Corneria pillars: `tmp/shadow-gpu-final-pillars/50cc1cfa85624ad68eacae887b96a3f5`
- EX Corneria, Windows Vulkan: `tmp/shadow-gpu-final-vulkan-ex/426bcab5772c47a88cb299bbac4a9c6d`
- Original title: `tmp/shadow-gpu-final-title/2f6d7b08aa9e442ab73c85926553b27e`

Training/pillar images were visually inspected; pillar ground-pixel assertions
pass. The first title attempt used a nonexistent symbol; a second sampled the
initial black fade. The successful fixture uses TITLEMAP, 160 preroll ticks.

Benchmark: `tmp/gpu-caster-benchmark-direct-cached`, two reversed-order pairs,
240 frames each. GPU-caster median 2.849–2.851 ms versus CPU-caster 2.720–2.729 ms;
p95 3.206–3.251 ms versus 3.259–3.384 ms. Final captures match. The first blocking
handoff was ~3.44 ms; removing that wait and extra copies improved it, but this
small scene still has a ~4–5% median migration cost. Do not claim an FPS win.
The benchmark now explicitly removes disable variables instead of leaving an
empty-but-present variable that accidentally kept the CPU baseline selected.

At this checkpoint the remaining caster work was specialized modes and stereo
fallback preparation; both are addressed above. Non-recorded model-layer
fallbacks, broader hardware acceptance and further performance profiling still
need review. Line/billboard shadow coverage is unchanged from the source caster
behavior, not a newly implemented shadow feature.
The previously delivered ZIP predates these PC changes; no release or Quest
installation was performed in this pass.

## Portable resident shadow-caster producer (September 13)

Added optional `GpuModelRaySource` output and `GpuRayGeometry`. The model
renderer exposes its native/continuous GPU camera records and compensated
residuals, plus CPU topology indices only. Triangle expansion consumes those
buffers on the same SDL command without vertex readback or CPU transforms.
The output is float4 triangle-list geometry suitable for the DXR handoff.
It is independent of view-facing tests and preserves negative/offscreen points.
Invalid indices/point markers degenerate the complete triangle; invalid modes,
transforms and input/output aliasing reject before encoding work.

D3D12 and Windows Vulkan checks pass 2,925 native/fractional/residual vertices,
resize/reuse, invalidation, release/reinitialization, and actual GpuModel-to-ray
expansion chains. DXIL/SPIR-V generation and Metal binding/freshness checks pass;
this is not Apple hardware evidence. Seven targeted Windows regressions pass
(20.36 s); the current Windows targets rebuilt.

At this earlier producer-only checkpoint, it was **not active in game shadow submission**. GpuScene aggregation and
SDL-to-DXR shared geometry/fence routing were still pending (superseded above). Axis/colour-warp/
wave/wobble and sprite/line coverage need their specialized geometry/material
paths; do not silently discard them or claim CPU caster preparation removed.
The ordinary camera/topology export is opt-in, so the current game retains its
verified CPU caster fallback. No headset install or release occurred this pass.

Final producer rerun passes on Windows D3D12, Windows Vulkan and Linux/WSL
Vulkan after failure-output clearing. Both Windows game and checker rebuild;
Linux checker rebuilds. The earlier full 54-test Linux result predates this
producer/API addition and is not claimed as its full-suite verification.

## Current shared-depth cross-platform verification (September 13)

Rebuilt every target in the Ubuntu/WSL tree against this workspace (81 build
steps). Its Vulkan depth checker passes all 366,183 analytical plane samples,
fractional-centre cases, folded-face invalidation and mixed-scene ownership.
The full projection checker also passes, including native/continuous models,
text, particles, dust, grids, axes and the new vertex-motion direction/reset/
invalid-input cases. This is Linux/WSL backend evidence, not a Steam Deck,
hardware-FPS claim, or completed DLSS evaluation.

The current Windows VR development tree also rebuilt successfully; all 15 VR
tests pass (28.32 s). Physical Quest/Index acceptance remains separate. Native
VR geometry uses its own Vulkan source pipeline, not the SDL planar-depth
buffer introduced for the PC temporal-rendering work.

## Orbital palette work moved to the GPU vertex stage (September 13)

The eight invariant planet-surface palette probes now execute per sphere
vertex, using the same tile sampler and flat color varyings, instead of eight
full tile decodes per covered surface fragment. No CPU palette cache or new
readback is introduced. The tile sampler returns transparent coverage for
rejected samples; the non-orbital fragment wrapper retains discard behavior.
This also preserves orbital continuation over transparent atlas cells.

Fresh EX 5-1 boss and native page-2 Vulkan runs produce **222 byte-identical
BMPs** against the immediately preceding build (111 each, including both eye
images and synthetic depth/coverage cases). Output directories:
`tmp/vr-palette-vertex-current` and `tmp/vr-palette-vertex-menu`; references:
`tmp/vr-gameplay-clockwise-current` and `tmp/vr-menu-page2-unchanged-current`.
All 15 VR tests pass (24.26 s), shader source stamps pass, and the Quest APK
build succeeds (13 s). The APK is not installed. This proves fixture pixel
equivalence and removal of repeated fragment work, not measured Quest FPS or
acceptance of the still-disputed horizon orientation.

## Current VR warp dispatch verification (September 13)

The diagnostic's three "dispatch wiring pending" pipeline-creation messages
were stale and have been removed. `VulkanSourceScene::record_compute` calls
the owned models; `VulkanSourceModel::record` runs warp bindings after BSP
and before clipping/spans. Fresh `tmp/vr-current-warp-verification` execution
passes exact PRNG, repeated material/texture, invalid/empty recovery and
resident producer/material/expansion/clip/span checks. This establishes that
dispatch is connected, not universal model parity or physical Quest timing.
The run also passes the EX 5-1 tick-2200 thin-horizon assertion.
Historical "unwired" notes below are superseded for this VR path.

## Current Linux build and D3D12 geometry checks (September 13)

Linux Vulkan stereo also passes exact output packing and the retained-eye
near/zero/far disparity fixtures. Full Linux CTest completed: **49/49 pass**
in 197.09 seconds; the final EX simulation-data test passed in 124.03 seconds.

Rebuilt the current workspace successfully with Ubuntu/WSL GCC/Ninja (150
incremental tasks, not the old binary implied by the build-directory name).
The fresh Linux Vulkan effects matrix passes including bloom, styles, AA,
deferred captures and filter scales. This is WSL validation, not a Steam Deck,
Android or Metal result; its timings must not be used as headset performance.

The clipping and stereo diagnostics now accept DXIL, removing the same test
device-format restriction found in the effects checker. Fresh D3D12 runs pass
all three output packing modes, retained stereo outputs and near/zero/far
disparity. Clipping passes 25,362 exact polygons, 31,418,112 solid-span pixels,
48,435,200 fractional-span pixels at 1x/2x/4x, near-plane cases and metadata
retention. Fractional XYUV maximum error is 0.000976553. These are synthetic
geometry/pixel checks and do not establish stereo comfort on a headset.

## Effects backend verification (September 13)

All 25 portable geometry/shadow shader artifacts pass source-stamp, Metal
binding and DXIL-presence checks; effects and ScaleFX generated artifacts also
pass their checks. These validate generated inputs, not physical Metal behavior.
The effects diagnostic previously requested only SPIR-V/MSL and therefore
rejected `SDL_GPU_DRIVER=direct3d12` before running. It now accepts DXIL too.
Fresh Vulkan and D3D12 runs both pass style/intensity, tone/chromatic/smoothing,
all 16 split-bloom combinations, shadow offsets, batched AA/bloom, deferred
readback and 72 filter-pattern/scale comparisons. Exact branches remain exact;
floating-point branches stay within one channel unit. This is isolated effect
verification, not sustained gameplay or device acceptance. PORTABLE-GPU.md was
corrected to remove obsolete D3D11-default and mandatory-shadow-readback claims.

## All numbered-stage input sweep (September 13)

All 19 Original and 40 EX numbered entries pass a fresh 1,500-tick
`--ray-audit --preflight-invulnerable` run. Each process returned zero, each
summary reported zero rejected compute inputs, and no compute preparation
fallback reason was reported. This samples the opening 75 simulation seconds
per entry, with God Mode; it does not establish complete routes or GPU rendering.
EX 5-5, 6-4, 7-4 and 7-5 include procedural packets. A focused 5-5 rerun
identifies flags 1028 (packed source glyphs), handled by the graphics shader's
1024-bit branch, not failed compute models.

Additional actual Vulkan runtime check: EX LEVEL7_2 tick 300, 24 frames,
240-Hz presentation, 2x, hardware shadows and resident geometry/raster pass
exact native-raster and final-presentation comparison. The image was inspected:
outdoor gameplay, ship and pillars are visible. Backend logs confirm resident
DXR shadows and raster/composition/effects/presentation. Evidence:
`tmp/gpu-current-ex-clock-early-dxr` (historical directory name; this is not a
clock-boss capture). The earlier tick-1500 capture shows a stage card and must
not be cited as model coverage. Neither short check proves sustained performance.

## Cross-cartridge source coverage audit (September 13)

Fresh 1,500-tick `--ray-audit` preflights cover INTROMAP, LEVEL2_6,
LEVEL3_3, LEVEL3_7, LEVEL_BLACKHOLE and LEVEL_SPECIAL in both cartridges.
All twelve processes exit successfully with zero rejected compute models and
no reported compute preparation fallback. Accepted object/frame counts:

| Entry | Original | EX |
| --- | ---: | ---: |
| Intro | 5682 | 4642 |
| Colony | 8639 | 10245 |
| 3-3 | 11098 | 10653 |
| 3-7 | 11838 | 16152 |
| Black Hole | 3780 | 10108 |
| Dimension | 2938 | 4404 |

The audit also reports ordinary sprite packets (flags 0x28000005) and intro
packed source-font glyph packets (0x404). These are separate graphics-shader paths,
not proof of CPU rasterization or rejected compute geometry. This is bounded
source-input/coverage evidence only: no GPU dispatch, visual correctness,
hardware ray-tracing support on Quest, or sustained frame-rate claim follows.

## Unsupported-DXR contract (September 13)

VR now uses one `StartupMenu::ray_tracing_enabled()` predicate for ray scene
preparation and dispatch. New menu tests restore an ON preference without
hardware support and verify effective rendering stays off and the option is
absent; supported/disabled combinations are checked too. Preference persistence
is retained. The runtime target builds and input tests pass. This consolidates
existing availability checks rather than adding ray tracing to unsupported
headsets, and does not establish physical headset acceptance.

Removed unused-parameter warnings from the non-DXR resident stub without
changing behavior. New independent `starfox_dxr_stub_tests` compiles that path
even on Windows DXR hosts, without linking the hardware-enabled core. It checks
unavailable/render failure, caller fallback-data preservation, empty resident
outputs, absent shared handles and cleared readback output. Standalone GCC
`-Wall -Wextra -Werror` compilation and execution pass. This verifies the stub
contract, not platform graphics performance or the entire fallback renderer.

## Background payload regression validation (September 13)

The face-planet policy is stored separately from the existing star-atlas wrap
flag. Word 7 accepts only priority 0–2 plus bit 256; tunnel word 14 encodes wall
palette index + 1 (zero disables, maximum 256). GPU payload validation rejects
all other priority bits and out-of-range wall indices. Six new malformed-value
tests verify rejection leaves the two live packets and their retained uploads
unchanged. Rebuilt `starfox_vr_scene_check` passes on Intel Vulkan, including
native stereo/depth checks (`tmp/vr-background-control-validation`). This is
renderer validation, not headset acceptance.

## Vulkan resident runtime integration (September 13)

SdlDxrShadows now supports Vulkan as well as D3D12. Vulkan imports the matching
adapter's resource/fence, retains them across frames, invalidates on resource
identity/byte-size changes, and copies into tracked SDL storage after a GPU
timeline wait. Renderer creation requests the required optional features and
retries ordinary GPU creation if unsupported. A queued-wait failure path waits
before destroying its semaphore. Explicit readback remains for diagnostics or
fallback; the successful hardware Vulkan gameplay path no longer downloads its
shadow masks. Ray tracing remains default off.

Owner reuse/resize/release checks match all 18 raw-import fixtures. Live Original
and EX LEVEL1_1 tick 1000, 48 frames at 240 Hz / 2x / bloom 2 match reference
captures exactly, with logs proving resident hardware shadows, model geometry,
raster, composition, effects and presentation. Evidence:
`tmp/vulkan-resident-live-{original,ex}`. EX image visually inspected. Original
render median/p95/p99 is 3670/3920/4049 us; EX 3872/4858/5420 us (short renderer
profiles, not sustained FPS claims).

Full SBS 24-frame/240-Hz check passes dimensions/submission and logs both shadow
masks resident (`tmp/vulkan-resident-sbs-verified`). The checker initially rejected
the new backend status string; it now accepts both verified hardware names.
D3D12 interop regression still passes. Full scene/effect/adapter, stereo visual,
cross-platform and headset acceptance remain outstanding; this does not prove
the entire goal complete.

## SDL Vulkan external shadow copy proof (September 13)

Version-2 bridge adds a submit-lock-protected timeline wait and external-buffer
copy into tracked/cycled SDL storage. It acquires ownership from EXTERNAL,
copies with transfer access, releases ownership back to EXTERNAL, and restores
SDL destination default usage. The caller retains imported resources through
copy completion; raw queue handles remain private. Copy bounds/alignment and
null arguments are checked.

The extended `starfox_sdl_vulkan_interop_check` passes 18 real animated/resized
DXR masks across three SDL device recreations (133x79 and 400x224): imported
D3D12 memory/fence -> Vulkan -> SDL buffer is byte-exact against DXR readback.
Producer synchronization is queued on GPU before the copy; diagnostic readback
occurs afterwards. Invalid copy ranges/null source/semaphore reject. This is
transfer proof, not yet runtime routing: a retained Vulkan shadow owner and
renderer creation options must still be integrated into gameplay.

## SDL Vulkan import prerequisites (September 13)

Fixed the pinned SDL backend's custom device-extension list: it validated the
requested names but omitted them from `VkDeviceCreateInfo`. The guarded CMake
patch now appends them. A private, device-owned property exposes borrowed
Vulkan instance/device/physical-device handles and proc loaders, with no raw
queue access. This is built only in the desktop DXR-enabled SDL configuration.

`starfox_sdl_vulkan_interop_check` passes three device recreations with Win32
external-memory/external-semaphore extensions enabled, valid adapter LUID, and
a Vulkan 1.2 timeline semaphore whose initial counter reads 17. A deliberately
nonexistent extension correctly rejects. The ordinary Vulkan game path remains
unchanged: 24-frame Original LEVEL1_1 at 240 Hz / 2x / bloom 2 passes exact
capture parity (`tmp/vulkan-extension-regression`).

This establishes import prerequisites, **not** completed resident Vulkan DXR:
the imported-buffer copy/queue dependency and runtime owner still need wiring.

## Asynchronous SDL DXR validation (September 13)

The version-2 private D3D12 bridge queues the producer's shared fence on SDL's
GPU queue. The shadow owner no longer CPU-waits immediately after producing and
copying each mask; it retains the source until the next reuse/destruction.
The diagnostic now consumes the mask through effects **before** readback, so a
diagnostic CPU wait cannot conceal a missing queue dependency. Five fresh runs
pass 60 animated/resized exact mask/effects comparisons and 40 unread resize,
replacement and pending-release submissions. Invalid output recovery is tested.

Current 120-frame, 24-warmup, 240 Hz, 2x, bloom-2 LEVEL1_1 captures match the
reference exactly for Original and EX with resident hardware shadows and model
geometry. Evidence: `tmp/d3d12-async-240hz-{original,ex}`. Original render median /
p95 / p99 is 2740 / 8184 / 12571 us; EX is 3312 / 6451 / 500423 us. The matching
Original Vulkan sample (`tmp/vulkan-async-comparison-original`) is 3896 / 4269 /
4935 us. These are short renderer profiles, not sustained gameplay FPS or a
controlled before/after benchmark. Large D3D12 outliers remain; Vulkan stays the
default and its DXR CPU transfer path still needs migration.

Fresh complete `build/vr-dev` build succeeds; all 15 registered VR tests pass
(14.47 s), including both cartridge input checks. This does not substitute for
headset visual/performance acceptance.

## D3D12 model pipeline and live parity (September 13)

All portable shader-generator families now emit DXIL. Projection/visibility,
continuous transforms, software-binary64 helpers, text/particles/dust/grids,
axis reduction, BSP, clipping/spans, billboards/surfaces, color warp and scene
merge select it on D3D12. DXIL compilation overrides SF_NOINLINE only: its
validator rejects non-inlined struct-return functions. The integer arithmetic
is unchanged; SPIR-V retains the non-inlining annotation. Regenerated dependent
clip shaders after the shared header guard change.

Explicit D3D12 projection diagnostic passes 393987 exact native points/faces,
131329 continuous points, binary64 cancellation, text/particles/dust/grid and
axis fixtures. BSP passes 128 synthetic trees, four failures and ordered final
pixels. Both diagnostics also pass Vulkan. Combined mixed-model D3D12 checks
pass 24 models / 288 images per cartridge, matching software pixels and surface
coverage with bounded float normal/depth differences.

Enabled native pipeline eligibility for explicit SDL D3D12. Live Original/EX
LEVEL1_1 at tick 1000, 12 frames, 60Hz, 1x, bloom off passes exact CPU/native
capture comparison with resident model geometry, raster/composition/effects and
hardware DXR. Verified evidence is `tmp/d3d12-native-verified-{original,ex}`;
EX GPU BMP inspected. Earlier `d3d12-native-full-*` runs actually used Vulkan:
the test's DefaultPipeline mode cleared its driver override. Fixed that behavior
and required resident DXR for explicit D3D12 ray-tracing tests before accepting
the new runs. Those earlier runs are not D3D12 evidence.

Vulkan remains the default pending broader D3D12 gameplay/high-FPS coverage.
Its native DXR import remains unfinished, as do full goal/headset acceptance.

## D3D12 raster/composition shaders (September 13)

Added offline DXIL and backend selection for native scanline rasterization,
raster bins, frame composition and portable compute-BVH shadows. Standalone
Windows device creation keeps Vulkan as its default (explicit SDL driver
overrides still work), avoiding accidental changes to other model producers.

Explicit D3D12 raster diagnostic passes 168 exact pixel/tag/surface cases and
32 unread submissions with resizing/bin changes. Composition passes 108 base
cases plus shutter/circle/fade/color-math/window/overlay/touch/split variants;
the same full composition suite passes Vulkan. D3D12 compute shadows pass
all behavioral, packed-row, stereo and resident-blend checks, retaining the
known two 4x CPU edge differences (max delta 20). Shader checks and Windows
runtime build pass. Timings are component measurements, not in-game FPS.

Full model/BSP/projection scene producers still need DXIL; native D3D12 game
pipeline enablement remains gated until those are ready. The Vulkan DXR import
and full goal acceptance remain open.

## ScaleFX D3D12 support (September 13)

Offline ScaleFX generation now emits DXIL for all five filter passes and the
texture-preparation pass. GpuScaleFx selects DXIL on SDL D3D12; SPIR-V and Metal
remain available. Freshness checking also requires all six DXIL arrays.
`starfox_scalefx_check` passes sixty cases on both explicit D3D12 and Vulkan:
CPU/GPU pixels, buffer/texture inputs, resize/reuse and masked effects composition
at 1x/2x/3x/4x. This is port-reference comparison, not new upstream GLSL proof.

Live Original LEVEL1_1 tick 1000, twelve frames, 2x ScaleFX plus hardware DXR,
explicit SDL D3D12: succeeds with resident shadows/direct GPU presentation.
Capture `tmp/sdl-dxr-scalefx-live.bmp` was inspected; log alongside it records
the active GPU paths. Windows game builds. Other native D3D12 shader families
and the default Vulkan DXR import remain incomplete.

## Live desktop D3D12 resident routing (September 13)

Window now owns mono and two stereo SdlDxrShadows instances, selects their
outputs after successful hardware submission, includes them in explicit CPU
fallback lookup, and releases them before renderer/device destruction or
replacement. Unsupported backends decline before attempting native import.
Reference/download diagnostic modes deliberately retain their original path.

Live Original LEVEL1_1, 1000 preroll ticks, twelve presented frames, 1x, bloom
off: explicit SDL D3D12 runs pass mono/Half SBS/Full SBS. Logs under
`tmp/sdl-dxr-live-{0,1,2}.log` confirm GPU-resident hardware DXR and direct SDL
GPU presentation; stereo logs confirm both resident eyes. Matching BMPs were
captured; mono was visually inspected. These are sampled live evidence, not
full-game performance or all-effects parity. Default Vulkan regression also
passes exact native raster capture parity at this checkpoint (8 frames, 60Hz),
under `tmp/sdl-dxr-vulkan-regression`.

Vulkan remains the Windows default: full native model/filter compute coverage
on SDL D3D12 is incomplete. Default SDL Vulkan DXR still downloads masks until
its native import bridge is implemented. Do not call all GPU migration complete.

## Owned SDL DXR masks (September 13)

Added SdlDxrShadows: borrowed SDL device, adapter-matched DXR producer, cached
shared import, cycled destination storage buffer, explicit fallback readback and
release/reinitialization. Producer and copy completion are currently waited;
there is no mask readback during render. SDL tracks destination consumer use.

Repeated hardware tests exposed native COM wrapper address reuse on resize.
The cached import now invalidates on byte-size changes as well as resource
pointer changes. Five fresh runs (60 animated/resized masks and final blends)
pass exactly. A subsequent test also passes release/reinitialization, invalid
camera output invalidation and next-frame recovery. Windows runtime builds.
The game loop is not wired to this owner yet; SDL Vulkan import remains open.

## Packed resident DXR effects (September 13)

SDL effects now accept four-byte-row-aligned packed resident masks, in addition
to the existing uint32-per-pixel buffers. Stride validation rejects incompatible
inputs. Added offline DXIL variants of the effects shader and SDL D3D12 pipeline
selection; Vulkan/Metal variants are regenerated from the same source.

The native SDL/DXR diagnostic now compares final effects output, not only copied
masks: twelve animated/resized masks with layer-tag exclusions and positive /
negative vertical offsets match the uploaded-mask path exactly. Invalid strides
are rejected. The existing Vulkan portable shadow benchmark/regression passes,
including resident blending; its 4x CPU comparison still has the previously
known two differing edge pixels (maximum delta 20). No frame-FPS claim.

The component connection works; application ownership, mono/stereo routing and
fallback integration are still pending. Desktop runtime readback remains active.

## SDL D3D12 shared-output bridge (September 13)

The pinned SDL backend now exposes a private, versioned native device/copy ABI
through device properties. Its checked copy records COMMON/COPY_SOURCE/COMMON
source barriers and uses SDL destination cycling/tracking. Hardware diagnostic
`starfox_sdl_d3d12_interop_check` passes twelve animated/resized DXR-to-SDL masks
exactly, including row padding and null/empty/oversized rejection. Readback is
used only for diagnostic comparison in that tool. The Windows game builds.

This replaces the earlier lack of a native SDL D3D12 entry point, but is not
yet connected to desktop presentation. Packed-byte mask handling, mono/stereo
consumer lifetime, fallback and SDL Vulkan remain open. Existing desktop mask
readback is still active; no complete migration or performance win is claimed.

## Live PC VR consumer synchronization audit (September 13)

Inspected the production eye callback: it returns pending while geometry is
being produced, submits the imported DXR timeline value at the fragment stage,
acquires/releases external buffer ownership outside the render pass, and only
retires the ray frame after the eye submission's fence completes. Extended the
stereo command regression to exercise that timeline wait while the eye remains
pending: repeated polling neither resubmits nor records another ownership
release. The rebuilt regression passes. This is synchronization evidence, not
physical-headset visual acceptance or a desktop SDL interop implementation.

Both build/current and build/vr-dev full builds succeeded after the deferred
DXR changes. Fresh VR CTest passes 15/15 (15.35s), including Original/EX input
and reticle checks. Fresh desktop CTest passes 54/54 (342.18s), including
Original/EX save states, transitions, endings and the EX simulation audit.
Current hardware DXR/Vulkan interop and portable resident-shadow checks also
pass. The static 4x CPU comparisons report one differing DXR pixel and two
compute pixels (maximum delta 20), within existing tolerances, not bit-exact
parity. Animated DXR masks and resident blending comparisons pass exactly.

## Deferred trace on cartridge scenes (September 13)

Corrected the hardware cartridge fixture to select EX behavior explicitly for
EX ROMs (rather than leaving the constructor's Original experience default).
Fresh Original and EX LEVEL1_1 tick-400 runs pass on RTX 5070 Ti Laptop:
507/104 ray triangles, 15/522 shadowed pixels, 15/323 pixels changed by the
ground receiver. Two complete GPU geometry/material/trace/import runs agree
in each case with deferred VulkanDxrFrame completion enabled. These fixtures
verify a sampled pipeline, not all-level shadow appearance or headset FPS.

Inspected bundled SDL 3.4 GPU headers/backend: renderer wrappers accept
SDL_GPUTexture pointers; SDL_GetGPUDeviceProperties exposes identity strings,
not native devices/buffers, and the public GPU API has no external-buffer import.
The existing native Vulkan import cannot simply be cast to SDL_GPUBuffer.
Desktop integration therefore still needs an explicit native interop bridge
or presenter work; its current readback fallback is not full migration.

## PC VR deferred DXR completion (September 13)

VulkanDxrFrame now opts into deferred trace completion: its Vulkan consumer
waits on the already-exported D3D12 timeline fence instead of making the CPU
wait immediately after trace submission. Default resident/download callers
remain synchronous. Producer upload/allocator reuse, geometry resizing and
diagnostic downloads explicitly wait before touching producer-owned resources;
external consumers must still complete/release their use before producer reuse.
Deferred output without an external release is rejected.

Fresh hardware DXR tests pass deferred download equality, immediate repeated
submission/reuse, invalid-option recovery and resize checks. Rebuilt actual
D3D12-to-Vulkan integration passes combined producer/trace/import/draw,
changing geometry, alpha and resource-lifetime tests on RTX 5070 Ti Laptop.
No headset presentation or FPS improvement is established by these checks.
The desktop SDL shadow-mask readback remains a separate unfinished connection.

## PC VR trace/release submission combined (September 12)

VulkanDxrFrame now requests the DXR output's UAV-to-COMMON release in the
trace command list. Exporting the ready fence no longer submits another
command list or waits for a second completion. Existing synchronous/default
resident callers keep their previous UAV contract. No resource lifetime or
cross-device ownership requirement was relaxed.

Windows desktop and VR scene targets rebuilt. Hardware DXR checks pass exact
released-mask comparisons and assert that fence export retains the trace's
ready value. Rebuilt starfox_vulkan_external_check --dxr passes actual shared
D3D12 resource/fence import, combined producer/trace/draw, changing geometry,
alpha coverage, resizing and premature-reuse rejection on RTX 5070 Ti Laptop.
This removes a real PC VR synchronization submission, not the desktop SDL
readback gap. No headset presentation or game-FPS improvement is claimed.

## Animated DXR migration baseline (September 12)

Added a 32-frame changing-geometry benchmark with independent download and
resident producers (so the second path cannot reuse the first path's BLAS).
Every frame's resident mask is downloaded outside its timed region and compared
byte-for-byte with the ordinary output. Current RTX 5070 Ti Laptop run passes
all 32 comparisons: 2x median 0.5601ms download path / 0.4715ms resident path.
These are CPU-observed synchronous dispatch timings, not overall game FPS or
GPU timestamp measurements. Static 2x was 0.3049ms, demonstrating why a static
fixture understates changing-geometry costs. Existing geometry, receiver,
packed-row, stereo and shared-resource checks also pass.

Production desktop still calls DxrShadows::render and uploads the CPU mask;
native resident DXR output is not yet connected to the SDL presenter. At the
time of this baseline, both producers waited for completion (PC VR now opts
into deferred completion as documented above). This measurement
does not establish completion of either migration gap. Refit work must account
for changing topology/inactive triangles; matching vertex counts alone is not
a safe condition for replacing full acceleration-structure rebuilds.

## Updated Quest installation and successful launch (September 12)

Fresh APK build passed in 21 seconds; install-r and cold launch succeeded on
Quest 3 2G0YC1ZF8R059K, preserving saves/inputs. Activity manager reports the actual
QuestActivity (607ms activity launch), unlike the earlier controller dialog.
New process 24531 logs at 19:52:55..19:53:00 show 72..73/72 FPS, Stale=0 and app
times roughly 0.5..0.8ms during startup. Runtime load telemetry reports 7.88s.
This is startup telemetry, not gameplay or headset visual acceptance. Includes
orbital classification/range/cap/horizon/interpolation and latest ray/cache/wait
changes; standalone Quest has no Windows DXR. No release published.

## EX forward tunnel sample and capture parser (September 12)

LEVEL4_4:220@from-entry@front passes; inspected left-eye image shows gameplay
inside the central rectangular opening and black outside. Corrected diagnostic
@from-entry alone to default forward instead of failing as unknown direction.
Fresh implicit/explicit forward BMPs match SHA256 exactly. Evidence under
tmp/vr-ex-tunnel-front-current and tmp/vr-ex-tunnel-default-front. One stationary
sample is not full tunnel/head-translation or source camera alignment acceptance.

## EX tunnel containment samples (September 12)

Actual LEVEL4_4 from-entry rear captures at ticks 220 and 350 pass with zero lit
pixels in both eyes; inspected left images show solid black. This samples the
background change, not a proven exit to open space. Extended the strict zero-lit
assertion to left/right views of black tunnel surrounds (rather than treating
their expected black output as failure). Fresh tick-220 left capture also passes.
Evidence tmp/vr-ex-tunnel-transition-rear, vr-ex-tunnel-exit-rear and
vr-ex-tunnel-transition-left. Front-opening alignment, full transition animation,
other border colours and physical head translation still need acceptance.

## Correctly targeted EX orbital captures (September 12)

EX LEVEL5_1:60@from-entry@down reaches entry background 9 before checkpoint
warmup; current capture passes and was inspected in tmp/vr-ex-entry-exact-down.
LEVEL5_1:2300@down after checkpoint reaches thin background 315; inspected
tmp/vr-ex-thin-current-down. Both lower views contain surface rather than black
or stars. Large texels/projection distortion remain visible, particularly the
thin atlas. The earlier :60 sample without @from-entry is outdoor background
309, not entry evidence. These tests do not establish acceptable final visuals.

## Additional downward background captures (September 12)

Fresh Original LEVEL3_6:400@down GPU capture passes; inspected output and authored
atlas in tmp/vr-orbital-route3-down. Planet imagery covers the full sampled view,
though projection distortion remains. EX LEVEL5_1:400@down also passes and was
inspected, but source background 309 is the outdoor ground, not BG_5_1I/E orbital
entry; it must not count as orbital validation. Its repeating ground pattern is
visible. EX orbital entry needs a correctly targeted time/background fixture.

## Orbital scroll interpolation (September 12)

Shared orbital_horizon_motion now drives completed-tick placement and live
interpolated background transforms without mesh rebuilding. Live interpolation
resets across flow/background/camera discontinuities; separate planet placement
is retained. Fresh runtime build and packet tests pass five fractional positions
and alpha clamping against the source projected displacement. Physical motion,
scroll-wrap edge cases and all orbital variant acceptance remain unverified.

## Orbital source horizon angular placement (September 12)

Orbital sphere placement now derives pitch from authored surface row, selected
source vertical scroll and 112/256 source projection center/focal length, rather
than placing every horizon at eye level. Original Sector X tick-400 forward
capture inspected in tmp/vr-sectorx-horizon-aligned: horizon returns below center.
Fresh tests verify entry scroll 232 yields 80/256 projected displacement and
scroll 312 yields centered horizon; packet and scene suites pass. Dynamic scroll,
other orbital variants and headset transition acceptance remain outstanding.

## Equal-density orbital bottom projection (September 12)

Cartesian bottom cap now uses depth/128 texels per world unit on both axes;
previous X=4 caused 6.4x..34x directional stretching relative to Z. Added direct
thin-cap UV tests. Fresh packet tests and Original Sector X tick-400 downward,
forward and rear GPU captures pass; inspected all three left-eye images under
tmp/vr-sectorx-isotropic*. Bottom shows surface without prior long vertical
smearing or black hole. Rear contains no repeated small planet in this view.
Surface is still magnified and cap/horizon transition needs refinement; forward
composition/horizon height requires source comparison. No full visual signoff.

## Sector X surface atlas range corrected (September 12)

Inspected full authored-bg2.bmp: planetary surface begins near row 424, not the
generic 384-row LSB band. Original BG_2_2 now selects the existing 424..464 entry
surface mapping and isolated-small-planet handling. Fresh downward tick-400 GPU
capture in tmp/vr-sectorx-surface-band passes and visually fills the entire view
with surface, with no previous black region. Texture stretching remains visible;
this is not full 360/headset acceptance. Added explicit classification assertion
for the sampled stage/tick; that assertion postdates this capture build.

## Original Sector X orbital classification (September 12)

Forward tick-400 capture confirms a planet horizon but BG_2_2 was classified as
generic space-band geometry. Added Original BG_2_2 to orbital selection (EX
explicitly excluded pending its atlas verification). The downward capture now
contains planetary imagery instead of an entirely black image; inspected
tmp/vr-orbit-bottom-fixed/live-scene-left.bmp. Visible stretching and a black
region remain, so the surface range/projection is not accepted as complete.
No headset installation; continue mapping work before handoff.

## Orbital downward capture failure (September 12)

Fresh actual-cartridge capture `--live-stage=LEVEL2_2:400@down` (Original) fails
the nonblank-image assertion. Inspected tmp/vr-orbit-bottom-check/live-scene-left.bmp:
entirely black. Source background=135, Mode 2, vertical scroll=232, camera Y=-57,
ground=0. This is a concrete unresolved downward background case, not accepted
as a passing 360 view. Need distinguish stage classification/source atlas content
from projection before changing mapping. The nonblank assertion remains intact.

## Stereo ray cache regression coverage (September 12)

Extracted the live cache into StereoRayPlan and directly tested second-eye storage
reuse, clearing previous materials on invalid new inputs, retaining failure for
the second eye, and recovery after invalidation. Fresh runtime build and full
Vulkan scene suite pass in tmp/vr-stereo-ray-cache. Cache lifetime still relies
on the source owner invalidating before replacing packets, after consumers finish;
physical stereo presentation and performance remain unverified.

## Share ray planning/material assembly between eyes (September 12)

Live ray topology planning and material assembly now run once per source-packet
update, retaining the immutable result for both eyes. Failure eligibility is
also shared; every new packet assignment invalidates it. Eye geometry transforms,
cameras, output masks and fences remain independent. Fresh runtime build and
host application tests pass; existing hardware suite rerun passes but does not
execute this live cache, so stereo integration/performance acceptance remains.

## Cross-platform checkpoint after wait/resource changes (September 12)

Fresh Quest ARM64 APK build passes in 23 seconds with frame_wait and DXR geometry
resizing/cache changes. Non-Windows timer fallback compiles; DXR remains unavailable
on standalone Quest. Freshly linked host application, input and camera tests pass.
APK not reinstalled in this checkpoint; the previously installed build remains
behind Meta's controller-required prompt. Build emits existing unused DXR-stub
parameter and Gradle deprecation warnings. No physical rendering acceptance or
release implied.

## Bounded high-resolution Windows frame wait (September 12)

Live VR non-submitted iterations now use a private high-resolution waitable timer
on Windows, with a 1ms relative deadline and bounded wait; unsupported systems
and non-Windows retain sleep_for. No busy loop or global timer-resolution change.
The identical hardware fixture now uses this production helper: ten warm samples
median 1.99ms/max 2.6362ms versus prior coarse-sleep median 14.6709ms. Sequential
diagnostic measurements, not a controlled game-FPS comparison; reference masks
and full hardware suite pass. Quest fallback build and headset acceptance remain.

## DXR readiness timing and scheduler delay (September 12)

Extended hardware fixture to 13 changing frames, measuring ten warm begin-to-ready
intervals before readback/draw. RTX 5070 Ti Laptop, two triangles, 133x79:
1ms sleep polling measured median 14.6709ms/max 17.1444ms. Replacing diagnostic
sleep with yield polling measured 0.4875ms/0.6074ms; all reference checks pass.
These are sequential samples, not a controlled GPU speedup benchmark. Evidence
points to Windows sleep granularity dominating the first result. Live application
also sleeps 1ms on non-submitted iterations and needs a bounded/event-driven wait
review; do not blindly replace it with an unbounded busy loop. Not game FPS.

## Retain unchanged DXR coverage uploads (September 12)

DXR material coverage upload now compares full serialized bytes and retains the
upload buffer when unchanged. UV scroll, alpha/texture data and topology headers
remain part of comparison; no object-identity cache can hide recycled content.
Fresh full hardware suite passes opaque/transparent/cutout changes, signed
texture scroll, geometry resizing and imported output/composition. Serialization
and comparison still run on CPU; this does not complete GPU material migration
or establish a measured frame-time gain.

## Cache DXR allocation queries by geometry layout (September 12)

BLAS/TLAS buffers already retain sufficient capacity. Removed repeated prebuild
size queries for animated external geometry: bottom-level requirements are reused
only for the same triangle count and vertex stride; the fixed one-instance top
level reuses its requirements. AS contents still rebuild for every external frame,
so animation/recycled objects are not frozen. Fresh full DXR hardware suite passes,
including growth/shrink, moving geometry, alpha and imported composites. No
frame-time improvement claimed without a controlled benchmark.

## Retain DXR context across geometry resizing (September 12)

Live frame-size changes now resize shared geometry while retaining the D3D12
device, ray pipeline and output import, instead of recreating the entire frame
bridge. Resize is idle-only; borrowed geometry descriptors are discarded first.
Fresh hardware checks grow then shrink geometry across three exact-reference
frames, rejecting invalid counts and resize during production. Full --dxr suite
passes, including imported shadow composition. No measured FPS claim; this
removes context reconstruction but geometry/AS allocation and synchronization
still require further optimization. Not headset-installed.

## Legacy-only live ray scenes enabled (September 12)

Live ordered source-scene selection now includes ray-enabled frames with legacy
triangles but no compute models. Previously the application bypassed ray tracing
for those frames despite the mixed renderer supporting them. Fresh Vulkan scene
regression initializes a legacy-only source scene and verifies a nonempty legacy
ray plan/material set with zero compute bytes. Full scene suite passes in
tmp/vr-legacy-only-rays; runtime builds. This verifies planning and existing
renderer regressions, not yet live stereo ray output for that particular route.
Postdates the latest Quest installation (which cannot use Windows DXR anyway).

## Fresh Quest build and installation (September 12)

Latest ARM64 Quest APK rebuilt successfully in 26 seconds and installed with
adb install -r on authorized Quest 3 serial 2G0YC1ZF8R059K. Inputs and saves
retained. Launch again opened Meta's LaunchCheckControllerRequiredDialogActivity,
not the game activity, so this is not successful runtime/visual verification.
The user must wake/connect controllers and resolve that headset prompt before
physical acceptance. Standalone Quest still does not expose Windows DXR.

## Optional-ray failure boundary (September 12)

An invalid/degenerate source ground transform no longer throws out of the live
model update: it invalidates ray eligibility for that frame, retaining normal
rendering/native shadows. Explicit --ray-tracing now overrides a saved OFF
preference after restoration; hardware capability still gates actual use and
the default remains OFF. Fresh host application tests and camera-transform
tests pass; live transition/fallback and persisted CLI precedence still need
runtime coverage. This is robustness work, not completed special-geometry support.

## Dense EX scene source inventory (September 12)

Diagnostic now reports source object identities/poses beside each ray snapshot.
EX 2-3 tick 900 has camera Y=-19 and ground Y=0: the receiver is very close to
camera height. Authored BRO_2/BRO_3 objects sit behind the camera at source Z=-85,
BRO_4/BRO_5 at Z=923, and BRO_6 at Z=1931; the near left surface is CLISLA_S at
(-160,-57,26). Thus behind-camera authored geometry and a near foreground surface
are present, not simply a blank scene with an unexplained full-screen mask.
These identities are verified against assets/symbols/starfox-ex.txt. Their exact
shadow contribution remains unproven; do not exclude behind-camera casters merely
to reduce coverage, since real shadows can legitimately come from them.

## Inspectable ray-mask artifacts (September 12)

Cartridge DXR diagnostic now writes unmodified 24-bit BMP views of ground-enabled
and model-only masks under tmp/cartridge-ray-masks. Fresh EX 2-3 tick 900 build/run
passes; both images inspected. Ground-enabled coverage fills most of the region
below a near-horizontal horizon, while model-only coverage is localized to the
ship and a large left-edge surface. This is an isolated mask visualization, not
a composited game capture or proof of a bad shadow. Caster placement and visible
ground matching still need inspection before changing lighting behavior.

## Dense-mask isolation (September 12)

Cartridge diagnostic now adds a third trace with only the analytic receiver
disabled, keeping geometry/materials/light identical. EX 2-3 tick 900 changes
26,236 pixels; model-only shadow coverage is 7,756 versus 33,992 with ground.
EX 3-5 changes 21,760 pixels; model-only coverage is 8,564 versus 30,324.
Thus most dense coverage comes from the analytic receiver, not model surface
self-shadowing. This does not yet prove an error: ground-visible compositing
and caster placement require images. EX 1-3 (no enabled ground) retains all
3,147 shadowed pixels exactly; diagnostic enforces that invariant. Builds and
all three hardware runs pass. Do not suppress ground to hide this unresolved
visual question; inspect the composited scene next.

## Broader cartridge ray coverage (September 12)

Fresh 1200-tick ray-input audits of LEVEL1_2, LEVEL1_3, LEVEL1_4, LEVEL2_3,
LEVEL3_3 and LEVEL3_5 pass with zero rejected compute/procedural inputs in both
Original and EX. These are stationary-input opening samples, not full levels
or boss-destruction coverage. All twelve corresponding tick-900 GPU geometry /
material / DXR / Vulkan-import fixtures pass repeatability and mask bounds.
EX padded triangle / shadowed-pixel counts respectively:
32/147, 292/3147, 64/2340, 157/33992, 132/680, 187/30324.
EX 2-3 and 3-5 have broad mask coverage that needs visual inspection; a passing
repeatability test does not establish correct lighting. Original 2-3 and 3-5
samples contain only eight padded triangles and no shadow coverage, so those
snapshots are weak scene evidence. Next coverage should target active scene
frames and destruction/special geometry, plus inspect full composite images.
No installation or release; full migration remains incomplete.

## Ray preparation duplicate work removed (September 12)

Indexed legacy ray textures are decoded once per batch/offset/dimensions instead
of once per triangle. Shared faces reuse the same coverage offset; fresh scene
tests verify one decoded payload and retained transparent palette entries.
Live mixed-ray recording skips its redundant full-buffer clear because the
external producer already clears padding and inserts its transfer barrier.
Standalone recording still clears by default. Fresh Vulkan scene suite passes
in tmp/vr-ray-packing-reuse; Original tick 400 and EX tick 450 cartridge DXR
checks pass with unchanged shadowed-pixel counts (15/529). No FPS improvement
claim: frame-time benchmarking and remaining synchronization work are open.

## Source-ground receiver validation (September 12)

Live rays now share a source-space ground/light transform with the cartridge
diagnostic. The receiver normal is derived from the two Q15 tangent axes rather
than assuming a perfectly orthogonal quantized rotation; signed camera-height
wrapping matches native poses, and the gameplay depth offset no longer applies
to cinematic ground. Fresh camera tests cover nonorthogonal Q15, height wrapping,
disabled ground and invalid inputs. The hardware diagnostic now uses actual
source ground/light, not a fixed test plane, and checks flattened native shadow
origins against that plane. Original 1-1 tick 400 passes 13 ground poses (15
shadowed pixels); EX tick 450 passes 19 (529 pixels). Both repeat the complete
GPU path identically. This verifies sampled plane alignment, not full-scene
shadow appearance, headset camera behavior or performance. No installation.

## Actual cartridge geometry through DXR (September 12)

`starfox_vulkan_external_check --game ROM SYMBOLS LEVEL TICKS` now runs actual
cartridge simulation with APU handshakes, GPU-enabled model assembly, mixed ray
geometry/materials, DXR and imported Vulkan output on the matching RTX adapter.
Each fixture repeats the complete path and checks identical, bounded masks.
Original 1-1 at ticks 400/900 passes (507/151 padded triangles; 522/406 shadowed
pixels); EX at ticks 400/450 passes (104/180 triangles; 459/857 shadowed pixels).
This is stronger than input classification, but uses a fixed diagnostic receiver
plane and does not prove headset visuals, source-ground alignment, every frame,
or independent geometric correctness for these full snapshots. No installation
or release.

## Whole-object sprite ray support (September 12)

The ray expander now implements whole-object sprite depth sizing, truncation,
240-pixel cap and depth>=128 cutoff from scene.hlsl. Indexed RGBA-palette/packed
byte textures are expanded into alpha coverage when assembling mixed materials.
Hardware tests cover ordinary size, capped size, near rejection and zero-size
rejection; scene tests cover palette transparency and truncated payload rejection.
Fresh DXR sharing/draw tests and `tmp/vr-whole-sprite-rays` pass. Both 1200-tick
1-1 input audits now show zero geometry rejections: Original 11241 compute +516
legacy samples, EX 12546+476. Audits classify input eligibility, not rendered
shadow correctness or exhaustive material validity. Textured warp, axis and
exploded solid geometry elsewhere, full-scene visuals and performance remain.
No installation or release.

## Eye-facing ray geometry (September 12)

Legacy ordinary billboard quads now expand on GPU using the visible renderer's
eye-space offset and model-axis lengths. ABI offsets are statically checked;
the hardware expansion diagnostic adds independently calculated billboard
positions under a rotated, nonuniform transform and passes, alongside DXR
sharing/draw tests. A 1200-tick Original 1-1 audit now admits 52 additional
legacy samples (464 remain rejected); EX remains 476 rejected. Extended audit
logging identifies remaining examples as flags 671088645 (0x28000005), mode 0:
the separate procedural whole-object sprite path, not ordinary billboard mode.
That path still needs geometry/material support. No live/headset verification
or release in this pass.

## Real-cartridge ray-input audit (September 12)

Added `--preflight ROM SYMBOLS LEVEL FRAMES --ray-audit`, using compute-enabled
world assembly and the same material planning policy as live rays. It reports
source identities that still reject. Original 1-1 light flashes (FLASH_STRAT)
and EX default reticles (XHAIR2) caused whole-scene fallback despite not being
physical surfaces. A source-identity policy now excludes those, grid and dust
from ray input only; ordinary rendering is unchanged. Both 120-tick 1-1 audits
then report zero rejected inputs (1554 Original/1507 EX accepted compute samples).
Longer 1200-tick audits retain 516 Original and 476 EX procedural-legacy samples,
with 11241/12546 compute samples accepted. These are object/frame counts, not
GPU-rendered proof; later procedural coverage remains incomplete. No install
or release. Other levels and alpha samples remain to be audited.

## Quest compile and colour-only warp ray eligibility (September 12)

Quest debug APK builds successfully with the frame/menu integration (24 seconds;
not installed). Subsequently, compute ray planning now admits colour-warp models
whose warp texture payload is empty, using the already tested original-geometry
candidate path. Dynamic textured warp and axis models still reject. Fresh scene
tests check colour-only admission, textured rejection, topology generation guards
and the existing GPU warp candidate expansion (`tmp/vr-colour-only-ray-coverage`).
This is not proof of all real-game warp material semantics or headset rendering;
the new eligibility change has a Windows build/test but postdates that APK build.

## VR ray-tracing menu and preferences (September 12)

VR Options now contains a 3D Options submenu with RAY TRACING, default OFF.
The control is unavailable unless the active adapter supports the shared-memory
path and a DXR device can actually initialize; standalone Quest is not advertised
as DXR-capable. The menu drives the application's ray path. Preferences remain
16 bytes, version 2, with transactional version-1 migration defaulting rays OFF.
Existing translations cover the new labels. Fresh input tests pass navigation,
press-only toggling, unavailable-device behavior, preference roundtrip, legacy
migration and corrupt-record rejection. Application host/device tests also pass.
This does not establish complete model coverage, live visual correctness or
acceptable VR frame time. No installation or release.

## Initial live application DXR wiring (September 12)

The Windows VR application now accepts opt-in `--ray-tracing` (default off),
gated by matching-adapter external-memory support. Ordinary mixed scenes build
per-eye GPU ray geometry/materials, trace via `VulkanDxrFrame`, and draw the
imported mask before HUD/sprites with timeline ownership handoff. Native shadow
draws are suppressed only for a ready replacement. Unsupported model/material
plans retain normal rendering. Grid/dust visualization is excluded from caster
geometry; the source shadow-height plane and light are transformed with the
interpolated source view and tracked eye. Ground alignment still needs live
visual verification. This is initial integration, not feature completion:
menu selection, special-model coverage, legacy-only scenes, full live testing
and performance remain open. Scene regression tests pass on Intel Graphics
(`tmp/vr-live-ray-wiring`); the test does not execute this live XR branch.
Quest is connected but no installation or release was performed; DXR requires
a supported Windows GPU, not standalone Quest hardware.

## Combined frame shadow draw (September 12)

The frame component now exposes its draw timeline wait, render-pass preparation,
external ownership acquire/release and shadow draw. The hardware diagnostic
executes these methods on a DXR result produced from Vulkan-generated geometry.
The offscreen RGB result agrees with the independent mask/composite reference
within one quantization level and preserves destination alpha exactly. Fresh
`starfox_vulkan_external_check --dxr` passes this end-to-end component test and
all prior sharing/coverage checks. This is offscreen drawing, not live XR
presentation; application integration and special-model coverage remain open.
No headset installation or release.

## Combined DXR frame component (September 12)

`VulkanDxrFrame` now coordinates shared geometry production, completion polling,
DXR tracing and Vulkan output import. Repeated equal-sized frames retain the
output import. A producing/ready frame cannot be overwritten; the caller must
finish output consumption and explicitly retire it. Fresh hardware tests run
three changing two-model frames through this component and compare the imported
output to CPU references exactly, including rejection of premature begin/retire.
The component performs no geometry or mask readback; diagnostic verification
does. DXR tracing itself still waits synchronously, and application draw wiring,
special-model coverage and frame-time testing remain unfinished. No headset
installation or release.

## Geometry-first DXR initialization (September 12)

Shared geometry preparation now returns adapter identity and an initial fence
value. Fence export works before a shadow output exists, eliminating the dummy
shadow render previously required to bootstrap Vulkan geometry imports. The
hardware diagnostic now starts its geometry path with a fresh DXR owner,
asserts that no shadow output/handle exists, imports the geometry and traces
GPU-produced models successfully. Fresh `starfox_vulkan_external_check --dxr`
also passes resident producer, alpha and 32-frame output-sharing tests. This
removes a live-integration prerequisite, but is not application presentation.
No headset installation or release.

## Reusable shared geometry producer (September 12)

`VulkanRayProducer` owns the Vulkan import and separate command submission for
a D3D12 shared triangle buffer. It waits on the producer timeline, acquires
external ownership, clears alignment padding, dispatches caller geometry work,
and releases ownership before its completion fence is reported. There is no
geometry staging/readback in this component. Fresh RTX 5070 Ti hardware tests
exercise three changing two-model frames through it into DXR; resulting masks
match CPU geometry references exactly. Mask readback remains diagnostic only.
Existing alpha and 32-frame output-sharing checks also pass. Live application
integration, special geometry/materials and frame-time validation remain open.
No headset installation or release.

## Separate geometry-producer submission (September 12)

`VulkanEyeCommands::submit_work` now permits a separately fenced producer
submission without a render pass or XR image. Eye rendering delegates to the
same submission/error/timeline path. This allows geometry work to finish before
an external DXR consumer, unlike the application's current combined compute
and eye-draw command buffer. Fresh scene tests verify three changing GPU buffer
fills, rejection while pending, fence reuse, and all existing eye renders
(`tmp/vr-ray-producer-submission`, Intel Graphics). The application has not yet
been switched to split submission; no claim of live DXR rendering or improved
headset performance. No installation or release.

## Mixed compute/legacy material coverage (September 12)

Mixed ray plans now assemble ordinary legacy triangle RGBA texture coverage
alongside native indexed compute materials. Records follow shared-geometry
triangle offsets, including alignment gaps, and texture offsets are relocated
into a common payload. Invalid extents, inconsistent per-triangle materials,
nonfinite UVs and procedural vertex modes reject transactionally. Fresh
`starfox_vr_scene_check tmp/vr-mixed-material-coverage` passes mixed layout,
legacy transparent texel relocation and inconsistent-material rejection plus
the existing Vulkan scene suite on Intel Graphics. This is material assembly
proof, not a live-game DXR presentation test. Warped/procedural coverage and
application integration still remain; no release or headset installation.

## Native source material coverage conversion (September 12)

`source_ray_coverage` converts indexed face textures to DXR coverage, preserving
source index-zero holes independently of palette colour, original corner UVs,
and signed texture scroll. The hardware diagnostic feeds this conversion into
DXR and matches the independently clipped geometry reference exactly. Invalid
texture ranges reject transactionally. Compute ray plans can now assemble
per-model material records at the same triangle offsets as the shared GPU
geometry, including padding and relocated texture offsets. Warped/axis material
extraction and legacy coverage remain unfinished; live application tracing is
still not enabled. No installation or release.

## DXR texture-alpha candidate coverage (September 12)

Resident DXR accepts optional per-triangle UVs and RGBA8 coverage textures.
Both receiver and shadow queries reject zero-alpha candidate hits; omitted
coverage retains forced-opaque tracing. Input ranges, texture dimensions and
finite UVs are validated before dispatch. On the RTX 5070 Ti Laptop GPU,
`starfox_vulkan_external_check --dxr` passes opaque equivalence, entirely
transparent geometry, cutout equivalence to an independently clipped CPU
geometry reference, invalid-range rejection and subsequent recovery. The
existing 32-frame shared-buffer/timeline/composite checks also pass. Coverage
metadata currently uploads per call; game-material extraction and live
presentation are not connected, and this is not a completed in-game feature.

The source scene also now supports explicit original-shadow draw suppression
only when a caller declares replacement shadows ready. The synthetic Vulkan
scene test (`tmp/vr-shadow-draw-switchover`) checks both legacy and compute
draws. Default rendering still preserves originals; the application has not
enabled replacement yet. No headset installation or release in this pass.

## Native shadow-pass exclusion from ray candidates (September 12)

Named the source's existing 0x10000 shadow pass and excluded that exact pass
from compute and legacy ray planning. Flattened native shadow visuals are not
physical casters/receivers and must not enter acceleration structures. Fresh
scene tests add both kinds of native shadow input and verify the planned ray
size/model counts remain unchanged (`tmp/vr-ray-native-shadow-exclusion`).
Normal visual rendering remains unchanged: this does not yet suppress the
original shadow draw when a successful live replacement is available. That
switch-over, material coverage and DXR presentation are still unfinished.

## Indexed ray lookup and Quest compilation (September 12)

Compute and legacy ray lookups now use retained key indexes instead of scanning
every scene item for every model. Compatible updates retain indexes; rebuilt
collections rebuild them alongside the item order. Fresh Intel scene tests
pass, including reordering, missing/removed keys and mixed refresh
(`tmp/vr-indexed-ray-lookups`). This removes average quadratic lookup work from
full-scene refresh; no in-game FPS improvement is claimed. Before this indexing
edit, the accumulated ray-resource/shader changes also passed a fresh Quest
ARM64 APK build in 18 seconds. That APK was not installed; the index edit is
host-tested only. Material coverage and live DXR presentation remain open.

## Cached legacy ray eligibility (September 12)

Legacy ray lookup no longer rescans every SceneVertex on each call. Position
eligibility is computed when immutable packet geometry is created and reused
with that geometry; changed vertex data creates a new eligibility result.
Fresh Intel scene tests cover plain -> billboard -> plain under the same key,
ensuring neither acceptance nor rejection remains stale. Full suite passes
(`tmp/vr-ray-eligibility-cache`). This removes per-lookup O(vertices) work, not
a measured FPS improvement. The DXR shader still forces opaque queries; alpha
coverage must be added before textured candidates can be considered complete.

## Retained mixed-scene refresh (September 12)

The mixed ray assembler now refreshes compatible compute and legacy inputs
without reallocating buffers/descriptors. Changed legacy layouts or borrowed
buffer ranges reject; any failed refresh disables recording until recovery.
Fresh Intel tests reject a changed offset, recover and repeat a valid refresh,
then verify every compute/legacy vertex moves by the expected 64 native units
for a translated eye while padding remains unchanged zero. Full scene suite
passes (`tmp/vr-mixed-ray-refresh`). Live DXR presentation and complete material/
procedural coverage remain unfinished. No installation or release.

## Unified ordinary mixed ray buffer (September 12)

VulkanMixedRayScene now packs ordinary compute and legacy triangle candidates
into one output buffer with whole-triangle/aligned offsets and one GPU clear.
The compute recorder can omit its redundant clear when composed in this pass.
Fresh Intel diagnostics dispatch both paths from one scene, compare legacy
coordinates to the independently rendered retained fixture, verify all models'
vertex markers and zero alignment gaps, and check total AS vertex count.
The fixture contains two legacy packets, both retained. Full scene suite passes
(`tmp/vr-mixed-ray-assembly`). This is ordinary triangle assembly, not complete
material/procedural coverage or live DXR presentation; no release/install.

## Mixed scene ray input routing (September 12)

VulkanSourceScene exposes its legacy packet buffers alongside compute arenas,
with the same update generation. The GPU legacy expansion fixture now consumes
a buffer retrieved from a combined scene, not a separately managed packet
collection. Fresh Intel tests verify matching generations, no overlap between
compute/legacy lookup paths, correct expanded legacy positions, and rejection
of a removed legacy key after update (`tmp/vr-mixed-ray-inputs`). Full scene
suite passes. Combining these inputs into one complete live ray pass, material
coverage and DXR presentation remain unfinished. No release or installation.

## Retained legacy ray geometry (September 12)

VulkanLegacyRayGeometry wraps a borrowed scene triangle buffer with immutable
corner/topology descriptors and a transform uniform. Compatible model/eye
updates reuse those resources; no vertex readback/reupload is performed. The
transform accounts for legacy positions already using XR coordinates, unlike
native compute points. A fresh Intel GPU fixture consumes the actual keyed
packet buffer, applies a changed/repeated model transform, and compares every
output coordinate to an independent model calculation within .001 native unit.
Full scene checks pass (`tmp/vr-retained-legacy-rays`). Alpha/procedural coverage,
complete scene batching and live DXR drawing remain open; no installation.

## Borrowed legacy graphics vertex buffers (September 12)

VulkanSceneBuffer now supports storage reads as well as vertex fetches.
VulkanDrawPackets exposes keyed triangle buffer ranges/counts/model placement
without another upload. Procedurally positioned vertices reject; ordinary
textured geometry remains a candidate requiring separate alpha coverage.
The hardware expansion fixture now reads a real VulkanSceneBuffer directly,
not a copied source-storage surrogate. NVIDIA DXR regressions pass; fresh
Intel full scene tests verify unkeyed/missing lookup rejection, vertex extent,
placement and buffer identity across reordered packets
(`tmp/vr-legacy-ray-buffer`). Legacy scene batching, procedural coverage and
live DXR rendering are still unfinished. No installation or release.

## Interleaved legacy vertex expansion (September 12)

Ray expansion can now read position-first interleaved GPU vertices directly,
using an explicit stride mode. Ordinary projection/residual modes retain their
existing layout. The shader bounds-checks byte loads and degenerates invalid
strides; retained geometry initialization validates stride and buffer extent.
Fresh NVIDIA tests verify SceneVertex-stride position extraction with unrelated
fields populated, invalid-stride rejection, existing residual/double modes,
and the full DXR shared-buffer regression. SceneVertex fixture input is uploaded
to diagnostic storage; borrowing the actual legacy graphics buffers, material
coverage and procedural vertex reconstruction remain to be connected. Embedded
SPIR-V was regenerated. No live-game parity or installation is claimed.

## Batched shared geometry hardware proof (September 12)

The NVIDIA DXR/Vulkan diagnostic now uses two retained VulkanRayGeometry
instances writing distinct aligned subranges of one shared D3D12 allocation.
GPU clearing leaves the intermediate whole-triangle padding zero. DXR consumes
the complete allocation as one triangle list: both changing frames match CPU
masks exactly, and diagnostic byte readback verifies every padding byte. The
four-size/32-frame output import regression also passes. Transfer visibility
includes both expansion writes and padding clears. These are synthetic model
inputs, not a live cartridge render; full caster coverage and application
orchestration remain unfinished. No release or installation performed.

## Retained multi-model ray refresh (September 12)

Batched compute rays now refresh compatible scene generations without buffer
allocation or descriptor reconstruction. Exact topology, offsets, counts and
borrowed buffer ranges are checked before transform updates. Failure disables
recording, preventing partially updated or recycled geometry from being traced.
Fresh Intel GPU tests reject changed topology, recover through compatible
refresh, repeat an unchanged refresh, then render a translated eye: every model
moves by the expected 64 native units and all padding remains zero. Full Vulkan
scene diagnostics pass (`tmp/vr-ray-scene-refresh`). Live DXR integration and
complete material/legacy caster coverage remain open.

## Multi-model resident ray assembly (September 12)

VulkanComputeRayScene now assembles ordinary compute models into one borrowed
GPU output allocation. Each subrange respects descriptor alignment and whole
triangle boundaries; a GPU clear leaves alignment padding as degenerate
triangles, not stale casters. Expansion uses scene-keyed resident inputs and
per-eye placement transforms. Recording rejects changed source generations
before issuing commands. Legacy geometry and warp/axis coverage are explicitly
outside this component, so it is not yet a complete gameplay ray scene.

Fresh Intel Vulkan diagnostics dispatch source compute and batched expansion,
verify identical models produce exact output at distinct aligned offsets,
check zero padding and finite vertex output, and reject stale generations.
Full scene suite passes (`tmp/vr-multi-model-rays-verified`). Shared DXR buffer
orchestration, complete material coverage and live application drawing remain
unfinished; no installation/release performed.

## Per-model ray placement transform (September 12)

Added shadow_model_transform to compose the graphics native-point basis,
model-unit scale, model placement and tracked eye into the affine rows consumed
by ray expansion. It supports nonuniform model scale and rejects invalid eye,
placement, units and nonfinite results. Fresh camera tests compare against
independent world/eye projection across 12 moving poses, three unit scales,
rotated/scaled placement and three points per case. Shadow pixel coordinates
agree within .001 pixel. This prevents a future caller from treating native
camera points as already-placed XR geometry; live shadow orchestration remains
unfinished and this is not physical headset acceptance.

## Scene-owned resident ray inputs (September 12)

VulkanSourceScene now exposes resident model point/residual/corner ranges by
full object/pass key together with placement, units and an update generation.
Consumers must reacquire after every initialize attempt or close, including
failed updates that may touch retained producers. Missing keys and unsupported
model modes reject; the API neither downloads vertices nor claims GPU work is
complete. Fresh full Vulkan scene tests verify buffer reuse across updates,
changed generations, correct units and missing-key rejection on Intel Graphics
(`tmp/vr-scene-ray-sources`). The live scene can now supply expansion inputs,
but ray resource orchestration and shadow drawing are not yet connected.

## Cross-platform ray shader build guard (September 12)

OpenXR configuration now checks the embedded ray-expansion SPIR-V against its
HLSL and transitive includes. Changes to the source, generated header, helper
includes or checker trigger reconfiguration; stale output fails configuration
instead of shipping an old shader. DXC is not needed for this verification.
Windows configuration passed, and a fresh Quest ARM64 debug build succeeded
in 34 seconds with package payload validation. No installation was performed.
This verifies compilation/package compatibility, not headset acceptance or
hardware ray tracing on Quest. Live ray integration is still incomplete.

## Retained ray geometry component (September 12)

VulkanRayGeometry owns immutable topology, a 64-byte transform uniform, and
retained expansion descriptors, borrowing the source arena, output range and
pipeline. Output can be a range within a shared geometry allocation. Recording
does not allocate or download vertices. Repeated transforms skip upload;
nonfinite transforms reject without replacing the active settings. Callers
must synchronize source writes and finish GPU use before updating or closing.
The ordinary and warp-candidate model fixtures now exercise this component,
including a changed transform, repeated updates, invalid-update preservation,
and rejection of implicit reinitialization. Fresh full Intel Vulkan scene
checks pass (`tmp/vr-retained-ray-geometry`). This supplies reusable renderer
infrastructure; application wiring and resolved caster materials remain open.

## Warp source ray candidates (September 12)

VulkanSourceModel can explicitly expose the original resident point/residual/
corner ranges for warp models. These precede view-dependent draw expansion,
so shadow geometry does not inherit camera visibility culling. Default access
still rejects warp; opt-in returns geometry candidates, not resolved opaque
casters. Axis line models remain rejected. The owned warp fixture now dispatches
ray expansion from those ranges and compares every expanded coordinate against
the resident projection data. Fresh full Vulkan scene diagnostics pass on Intel
Graphics (`tmp/vr-warp-ray-candidates`). Material suppression/transparency and
live ray scene integration remain required before enabling this for gameplay.

## Compute-expanded geometry consumed by DXR (September 12)

The Windows hardware diagnostic now runs the production ray-expansion compute
shader directly into a shared D3D12 geometry allocation imported into Vulkan.
DXR builds acceleration structures from that allocation without repacking or
uploading the expanded vertices on the CPU. Two affine translations produce
different masks and both match the CPU ray reference exactly on the NVIDIA
RTX 5070 Ti Laptop GPU. External ownership is released before tracing; the
buffer is reused across updates. The existing four-size, 32-frame output
import/composite regression also passes.

This is a synthetic triangle fixture: input points/topology are uploaded once,
and output readbacks are diagnostic verification only. It proves the compute
to DXR bridge, not live cartridge caster coverage or asynchronous scheduling.
Application wiring, warp/axis geometry, and removal of the live desktop mask
readback remain unfinished. No headset installation or release was performed.

## DXR resident vertex-input path (September 12)

DxrShadows render_resident accepts an optional same-device triangle-list
resource with explicit stride/count. It bypasses CPU vertex packing/upload,
builds acceleration structures from the resource GPU address, and transitions
COMMON to AS-readable state and back. External writes/ownership release must
finish before the call. This path always rebuilds rather than trusting cached
CPU geometry. Device, range, count and stride checks are present. Windows build,
invalid empty-input rejection and existing bridge regressions pass. Subsequent
shared-allocation and valid compute-generated input proof is recorded above;
this initial checkpoint alone tested only CPU geometry and invalid input.

## Expansion from actual model arenas (September 12)

The full Vulkan scene diagnostic now feeds VulkanSourceModel's resident point,
residual and corner ranges directly into ray expansion after model compute.
Only immutable topology/settings and output storage are separately allocated.
Expanded triangles match generated model coordinates exactly across the owned
model fixtures. Source/result readbacks occur solely for verification and are
never uploaded as expansion inputs. Full stereo diagnostic passes on Intel
(tmp/vr-resident-ray-expansion). These are synthetic source-model fixtures,
not all-cartridge coverage. Warp/axis handling, shared geometry export, DXR
acceleration-structure consumption and live application wiring remain open.

## Borrowed resident model inputs (September 12)

VulkanSourceModel exposes validated point/residual/corner descriptor ranges
from its existing arena without readback or copying. The caller must synchronize
compute writes and retain the model until consumption finishes. Axis/warp modes
explicitly reject this ordinary-topology accessor. Fresh full Vulkan scene
diagnostics pass and verify that ordinary model ranges reference the actual
arena and exact layout offsets (tmp/vr-ray-source-ranges). Expansion dispatch
from these live ranges, dynamic topology and cross-API export remain open.

## Renderer-owned ray expansion bindings (September 12)

VulkanRayBindings now owns the six-buffer descriptor binding for the expansion
stage, validates minimum ranges and device alignment/range limits, and borrows
the source/output buffers and pipeline. The hardware dispatch fixture now uses
this component instead of diagnostic descriptor setup. Truncated output is
rejected; all four coordinate/invalid-index/tail fixtures and DXR bridge checks
pass. Actual source arenas, GPU geometry export and live scene wiring remain.

## Triangle expansion hardware dispatch (September 12)

The NVIDIA diagnostic now dispatches ray_expand with 65 triangles (crossing
the 64-lane boundary), checking exact affine-transformed float4 positions for
ordinary points, residual tails and valid raw-binary64 coordinates. Separate
invalid-corner and invalid-point cases must write degenerate triangles. A
sentinel triangle beyond the dispatched count must remain untouched. All four
fixtures pass, as do existing DXR import/draw/composite checks. Inputs here are
diagnostic uploads; binding the actual model arenas and exporting expanded
geometry into DXR remain outstanding.

## GPU ray triangle expansion stage (September 12)

Added ray_expand compute shader and VulkanSpanPipeline stage. It fetches
unculled source corners and resident transformed points, supports residual/raw
binary64 point encodings, applies an affine transform and emits float4 vertices
with 16-byte stride for acceleration-structure input. Invalid references produce
degenerate triangles instead of stale output. Offline generation and actual
NVIDIA pipeline creation pass; the existing DXR bridge checks remain green.
Dispatch/output parity, allocation/binding integration and geometry export to
DXR remain unverified. Pipeline creation is not a geometry-correctness claim.

## Unculled GPU caster topology preparation (September 12)

Added immutable polygon-fan topology preparation using source corner indices
and face IDs. This preserves transformed-point and UV/material provenance for
GPU expansion without relying on camera-visible BSP output. Lines/sprites do
not create surface triangles. Tests verify fan order, ignored visibility state,
empty input and transactional rejection of invalid point/corner/polygon ranges.
The new test is registered with CTest. No GPU positions are read back or
recomputed by this helper. GPU triangle expansion/export, dynamic warp topology
and textured transparency still need integration/verification before claiming
complete live caster coverage.

## Quest cross-build and live caster gap (September 12)

Fresh Quest ARM64 development APK build passes after the shared-device,
submission, shadow-projection and fragment-pipeline changes (Gradle 21 seconds).
No headset installation or rendering acceptance. Android builds the unsupported
DXR stub; this does not enable hardware DXR on Quest. Existing unused-parameter
warnings in that stub remain nonfatal.

Live SourceModelPackets places GPU-computed models in compute_models with empty
ordinary packet placeholders. A caster collector reading ordinary triangle
packets alone would silently omit them. Full compute-generated geometry export
or an explicitly verified matching source-geometry path is required before
enabling the live ray-traced pass. The pass remains disconnected rather than
claiming the incomplete caster subset meets the goal.

## Shared shadow-space transform (September 12)

ShadowView now converts world points/triangles, receiver planes and light
directions into the same eye-relative shadow basis. Points include translation
and native-unit scaling; normals/lights use rotation only. Non-rigid or invalid
view matrices and invalid scales are rejected. Fresh tests cover 12 translated/
rotated eye poses: transformed ground points remain on the receiver plane,
light/normal angles remain invariant, and projected points agree with the eye
matrix below a millipixel. No physical headset claim. Live geometry extraction
and application integration remain outstanding.

## Asymmetric XR shadow-camera mapping (September 12)

Added shadow_camera(EyeCamera, width, height), deriving independent focal lengths
and principal point from the Vulkan projection. It preserves asymmetric left/
right eye frusta, explicitly documents the +Y-down/+Z-forward shadow basis, and
rejects invalid dimensions and unsupported projection forms. Fresh camera tests
round-trip sampled pixel rays through independently evaluated projection
matrices for both asymmetric eyes at 133x79 and 1024x1200. Sub-millipixel checks
pass. This proves projection mapping, not world-geometry extraction, receiver
alignment or live headset shadow integration, which remain outstanding.

## Independent eye focal lengths (September 12)

Shadow Camera now supports an independent vertical focal length, defaulting to
the existing horizontal focal length when omitted. CPU, DXR and portable shader
paths use it; nonpositive/nonfinite vertical values are rejected. Regenerated
portable shader artifacts. The hardware fixture at fx=100/fy=60 matches every
CPU coverage pixel exactly and differs from the legacy square-focal reference,
so the new parameter demonstrably affects rendering. All existing imported
draw/composite and 32-frame copy checks pass. Portable runtime execution and
mapping the actual XR eye matrices into these parameters remain to verify.

## Eye submission timeline synchronization (September 12)

VulkanEyeCommands and VulkanStereoDraw now accept an optional timeline wait
and an after-render callback outside the render pass. The wait carries the
producer semaphore/value/stage into VkQueueSubmit; invalid empty waits are
rejected before recording. The after-render hook supports external ownership
release after shadow sampling. Injected driver tests verify the exact semaphore,
value and fragment-stage wait, callback placement, invalid-wait rejection and
unchanged no-wait submission. Producer selection, scene conversion and actual
application callbacks still need wiring; this is submission infrastructure.

## Live Vulkan device sharing capabilities (September 12)

Windows VulkanDevice startup now checks the runtime-selected headset adapter
for the two Win32 sharing extensions, timeline semaphore extension/feature,
and valid LUID. When all are present it enables them at logical-device creation
and exposes the selected LUID and capability. Unsupported configurations retain
ordinary startup without sharing; close clears both values. Injected bootstrap
tests pass for supported sharing, missing timeline, missing extension, cleanup
and all existing failure cases. This enables the device prerequisite only:
live DXR producer creation and shadow-pass submissions remain to be connected.

## Proportional shadow compositing (September 12)

Added SceneBlend::shadow: destination RGB is multiplied by one minus source
alpha; destination alpha is retained and source RGB contributes nothing.
VulkanExternalShadow now defaults to this mode, with coverage times vertex
alpha controlling strength. This replaces the new component's provisional
subtractive default, not the existing game's presentation path.

Real imported DXR masks composite over a (64,128,192) background at 50% strength
in two hardware fixture sizes. Every channel matches the independent equation
within one 8-bit quantization step, alpha remains 255, and zero-coverage pixels
retain the background. Two opaque-coverage sizes and all 32 buffer-update
checks also pass. Live-game wiring, stereo alignment and performance remain.

## Retained imported-shadow draw pass (September 12)

VulkanExternalShadow now prepares and owns its fullscreen geometry and graphics
pipeline. Repeated identical prepare calls reuse resources; conflicting settings
are rejected until close. Dimensions are checked against imported byte size and
colors must be finite/in-range. record_draw only records existing resources,
without allocations or uploads. Cleanup retires draw resources before descriptors.
The hardware fragment fixture uses this production component, checks oversized
dimensions and conflicting reconfiguration, and still matches all pixels at
four sizes. The fixture uses opaque green coverage visualization; live shadow
compositing, frame synchronization and scene integration remain outstanding.

## Actual imported DXR fragment draws (September 12)

The hardware diagnostic now draws a full-frame quad through VulkanScenePipeline
using VulkanExternalShadow's imported buffer descriptor and packed-R8 fragment
mode. Submission waits on the shared timeline at FRAGMENT_SHADER, acquires
external ownership for shader reads, and releases it after drawing. Only the
rendered RGBA target is read back for verification; no CPU mask upload supplies
these draws. All active alpha values match native DXR coverage exactly and RGB
matches the expected green/transparent visualization at 133x79, 257x131, 67x43
and 133x79. The 32 changing-frame buffer-copy checks still pass.

This closes the imported-buffer fragment-read proof gap. It is an offscreen
diagnostic, not live-game integration, asynchronous frame ownership, stereo
shadow projection acceptance or a performance claim. First pipeline creation
was 237 ms on this run; reusable pipeline lifetime is essential in-game.

## Imported scene descriptors and padded-mask verification (September 12)

VulkanExternalShadow now owns a scene-compatible storage descriptor referencing
the imported buffer without uploading a mask. Close destroys descriptors before
the imported allocation. Hardware checks verify descriptor creation, invalid
byte-length rejection, rejection of replacement while open, and idempotent
cleanup. Existing cross-API copy tests still pass.

The shader fixture now includes width 3 with nonzero padding in a four-byte
row. All eight stereo BMPs in tmp/vr-shadow-padded-gpu match
tmp/vr-shadow-padded-reference exactly. This closes the row-padding gap in the
previous fixture. Actual imported-buffer fragment draws and live presentation
remain unverified and unconnected; descriptor creation alone is not that proof.

## Packed shadow fragment decoding (September 12)

The scene fragment shader can now sample R8 shadow coverage directly from its
storage buffer, using DXR's four-byte row alignment. Zero coverage discards;
other coverage modulates vertex alpha. Packet validation bounds-checks the
packed payload. Regenerated scene SPIR-V and both full Vulkan fixture runs pass.
All eight billboard BMPs in tmp/vr-shadow-mask-gpu match the independently
expanded RGBA reference in tmp/vr-shadow-mask-reference exactly, including
partial coverage, capped size and subpixel disappearance.

This fixture uses uploaded packed bytes, not an imported DXR buffer. It proves
the fragment decoding separately from the previously verified shared-buffer
import/copy. Connecting those two paths to live draws remains required. The
four-pixel-wide fixture also does not independently exercise row padding.

## Renderer-owned external shadow import (September 12)

Added VulkanExternalShadow to vr_core: owns imported buffer/allocation/timeline
semaphore, checks the producer LUID against the consumer physical device, cleans
partial failures, and rejects implicit replacement. NT handles remain caller
owned. Non-Windows initialization returns unsupported. The hardware diagnostic
now exercises this component at all four sizes, with exact pixel comparisons,
wrong-adapter rejection followed by successful initialization, and repeated
close. The existing 32-frame low-level interop checks also still pass.

Caller must complete GPU use and release external ownership before closing or
producer reuse. This component does not submit work, manage frame leases, or
connect shadow sampling to game presentation yet. No installation this pass.

## Explicit DXR producer adapter (September 12)

DxrShadows now accepts an optional Windows adapter LUID. Explicit selection
never falls back to another GPU; the default retains high-performance adapter
selection. The hardware bridge check verifies that selecting the actual adapter
produces identical pixels and a nonexistent adapter refuses initialization and
exports no resource. All 32 shared-buffer update/resize comparisons still pass.
This is a prerequisite for consumer-driven selection; game presentation has
not yet been switched to the shared-buffer path.

## Persistent import and resize verification (September 12)

The Vulkan/DXR bridge fixture now keeps each memory import and shared timeline
semaphore alive across eight producer updates. Each subsequent projection
differs from the first reference, so stale initial pixels cannot pass. The
consumer completes and releases external ownership before each producer write.
Four allocation cycles (133x79, 257x131, 67x43, 133x79) pass exact comparison
across all 32 frames on NVIDIA. Imports are destroyed before resizing.

This verifies serialized reuse and resize/reimport, not asynchronous overlap,
direct presentation, or removal of the game's CPU readback. Those remain open.

## Synchronized Vulkan read of DXR output (September 12)

The real DXR bridge diagnostic now submits a Vulkan GPU copy after waiting on
the imported D3D12 timeline fence. It acquires the shared buffer from EXTERNAL
ownership and releases it after the copy, then waits for consumer completion
before destroying the import or reusing the producer. On the NVIDIA adapter,
all 10,507 active pixels match native DXR readback exactly. The reference
contains 33 shadowed pixels; an empty or entirely shadowed reference fails.
Padding is accounted for with the producer row stride.

This supersedes the no-GPU-access status below. It proves a synchronized
cross-API buffer read, not presentation integration: the diagnostic reads back
the Vulkan staging copy for comparison, and the game still uses its existing
presentation path. Multiframe/resize consumer lifetime and asynchronous frame
ownership remain required before enabling direct consumption in the game.

## DXR external-read state handoff (September 12)

Exporting the ready fence now transitions the resident output from UAV to
COMMON, signals completion and updates ready_value. Consumers must read that
value after export. Repeated exports do not repeat the transition. Later DXR
renders reacquire UAV; readback transitions from the tracked state and restores
it. Consumers must finish/release external ownership before producer reuse.
Seven hardware resize/readback cycles, repeated exports, invalidation and
recovery pass in starfox_dxr_check. Updated Vulkan import/fence probe also
passes. No Vulkan copy/graphics access has been submitted yet; asynchronous
producer/consumer ownership still requires integration, not assumed safety.

## Shared DXR completion fence (September 12)

Producer fence is now shareable. ResidentOutput carries its ready_value and
export_ready_fence_handle returns a caller-owned NT handle only while output
is valid. The Vulkan bridge fixture enables timeline semaphores, imports the
D3D12 fence and observes a counter at least equal to the nonzero ready_value.
Real NVIDIA import test passes with explicit semaphore/handle cleanup. This
proves completion-fence interoperability, not an asynchronous queue wait:
render_resident still CPU-waits before returning. Buffer ownership/state
transfer and an actual synchronized GPU read remain required.
Contract: https://docs.vulkan.org/refpages/latest/refpages/source/VkD3D12FenceSubmitInfoKHR.html

## Real DXR resource import/bind (September 12)

starfox_vulkan_external_check --dxr now renders a real133x79 DXR scene,
exports its NT handle, selects the identical Vulkan LUID, creates an external
storage/transfer-source buffer, intersects handle/buffer memory-type masks,
imports a dedicated allocation and binds it. This succeeds on NVIDIA.
Buffer/memory are destroyed and the caller-owned NT handle is closed; no
GPU operation accesses the imported resource yet. Synchronization, resource
state/ownership transfer and pixel verification remain before consumption.
Game presentation still uses its existing path; no readback-elimination claim.
build/vr-dev now has STARFOX_DXC configured to the workspace compiler so this
diagnostic exercises real DXR, not its unsupported-platform stub.

Import ownership/allocation contract:
https://docs.vulkan.org/refpages/latest/refpages/source/VkImportMemoryWin32HandleInfoKHR.html
https://docs.vulkan.org/refpages/latest/refpages/source/VkMemoryAllocateInfo.html

## Matched Vulkan consumer creation (September 12)

The external-buffer diagnostic now creates a compute-capable Vulkan device
on the explicitly requested producer LUID, enabling Windows external-memory
and external-semaphore extensions. NVIDIA device creation succeeds and both
memory-handle-properties and semaphore-import entry points resolve. Device
is destroyed before the instance. This strengthens capability evidence but
does not import a resource, bind memory, execute a copy, or eliminate readback.
Those remain the next bridge steps; no change to game adapter selection.

## Producer adapter identity (September 12)

ResidentOutput now includes the producer's eight-byte Windows adapter LUID,
cleared with output invalidation. Hardware DXR regression passes and reports
176c010000000000 in this boot. Passing that value to the Vulkan external
buffer probe selects only NVIDIA, which supports D3D12 resource import.
An all-zero nonexistent identity rejects with exit7 rather than selecting
Intel. The probe accepts only16 lowercase hex digits. MinGW's SDL DirectX
header uses an explicit return-storage pointer for GetAdapterLuid; implementation
handles that ABI separately from MSVC. This is identity/capability evidence,
not imported GPU memory or presentation integration.

## Vulkan external-buffer capability probe (September 12)

New Windows-only starfox_vulkan_external_check enumerates physical devices,
reports LUIDs and queries D3D12_RESOURCE external-buffer import for storage/
transfer-source usage. Current Intel and NVIDIA adapters both report import
support; Intel requires dedicated allocation, NVIDIA does not. LUIDs differ
(Intel9665010000000000, NVIDIA176c010000000000 in this boot). Existing host
VR captures select Intel whereas DXR uses NVIDIA. Consumer selection must
match producer LUID; generic import capability cannot establish cross-adapter
sharing. This diagnostic performs no memory import or rendering. Next step
is matched-adapter import/bind and synchronized consumption, not removal of
the working fallback. Readback migration remains incomplete.

## DXR shared-output export foundation (September 12)

DXR output buffers now use D3D12_HEAP_FLAG_SHARED. export_resident_handle
returns a caller-owned NT handle only for valid, completed resident output;
caller closes it and must consume before the next render reuses the buffer.
No asynchronous frame-ownership or cross-queue synchronization is implied.
Seven size variants export/open/release successfully on the producer D3D12
device and validate buffer dimensions; empty-output export returns null.
Full real-RTX regression still passes. This proves exportability, not a second
device import, SDL/Vulkan consumption, or elimination of presentation readback.
Those remain required work.

API contract: https://learn.microsoft.com/en-us/windows/win32/direct3d12/shared-heaps
and https://learn.microsoft.com/en-us/windows/win32/api/d3d12/nf-d3d12-id3d12device-createsharedhandle

## DXR unchanged-geometry query reuse (September 12)

Cache BLAS/TLAS prebuild-size results only after a successful build. Exact
unchanged vertex bytes reuse those results along with acceleration structures;
changed geometry still queries/rebuilds as before. Real RTX5070Ti DXR checks
pass at1x/2x/4x, including geometry/light/camera/receiver changes,51 partial
workgroup cases and resident-output resize/invalidation/recovery. Reference
differences remain0/0/1 pixels. Current fixture medians0.1583/0.2892/0.8709ms
include dispatch/readback and are not a controlled before/after FPS comparison.
The separate-device presentation readback bridge is still unfinished; this
optimization does not resolve it. No release or headset installation.

## Whole-object sprite palette lookup (September 12)

Little-endian preparation now copies source bytes in bulk; other byte orders
retain explicit packing. Full256-entry palettes need no per-texel bounds scan;
short palettes retain validation. Existing byte-value, padding, short-palette
and rejection tests pass. Eight tmp/vr-indexed-bulk eye captures match the
independent CPU reference. Host128-update 256x256 microbenchmark changed from
71.6813 to27.8297 us/update, same66,560-byte payload. Sequential samples,
not controlled whole-game FPS or Quest timing. New copy change not deployed.

Palette boundary coverage: all256 bases and255 nonzero indices (65,280
lookup entries) match the original uint8 wrapping arithmetic. Short valid
palettes succeed; a used out-of-range entry rejects without altering output.
Override zero remains opaque for nonzero source texels while source zero
stays transparent. Packet suite passes. The first added fixture accidentally
inherited a near-clipped z=127 and indexed its empty output; corrected test
pose to512 before interpreting the result. No production defect inferred.

Cross-platform verification after byte packing: Quest ARM64 development APK
build succeeds in11 seconds. Refreshed VR CTest suite passes14/14 in11.75
seconds, including both cartridge input/state cases. This supersedes pending
Quest-compilation notes below, but not pending physical-device acceptance.
No installation performed; current orbital background work remains unfinished.

Packed-index follow-up: four source bytes now occupy one GPU word. Palette
lookup remains in the fragment shader; upload validation rounds the index
word count up. Index payload is one quarter of the initial indexed version
(palette stays1KiB). Packet tests check every byte value twice across512
indices and partial-word zero padding. All eight sprite eye captures in
tmp/vr-indexed-packed match the independent CPU reference exactly; the four
invalid-upload/reuse checks also pass. No measured FPS claim or deployment.

Malformed-upload device checks now pass in tmp/vr-indexed-rejection:
truncated palette, missing final index, overflowing start offset, and texture
mask beyond255 all reject. Resubmitting the retained valid packet requires
zero uploads after each rejection; subsequent stereo rendering succeeds.
Fixture runs for both eyes. This verifies transactional resource retention,
not just CPU packet construction. Quest build/acceptance remains pending.

Expanded device proof: the sprite fixture now has a4x2 texture with zero,
green, red and blue indices, plus a forced-green override in the capped-size
case. The reference packs colours directly from the source texture/palette,
not from the new lookup table. All eight billboard eye BMPs match exactly in
tmp/vr-indexed-rich-{gpu,reference}, including clipped-away minimum size and
fractional-depth cases; both complete Vulkan suites pass. This supersedes
the one-opaque-texel limitation below. Malformed-upload fixture and Quest
compilation/physical verification still remain.

Sprites now upload source indices plus a256-entry RGBA lookup table; the
fragment shader performs palette lookup. Index zero stays transparent, and
palette overrides retain the old CPU behavior. Texture payload validation
includes the lookup-table extent. CPU input validation and table packing
remain, and this adds1KiB per sprite payload; no performance gain is claimed.

The --sprite-reference diagnostic expands indices on CPU and clears the new
shader flag, independently retaining prior sizing. Both Vulkan suites pass;
all106 emitted BMPs match between tmp/vr-indexed-sprite-gpu and
tmp/vr-indexed-sprite-reference (most are shared unrelated fixtures; the
sprite-sizing cases are the relevant subset). Current device fixture uses
one opaque texel; richer transparency/override/device rejection fixtures
remain to be added. Packet tests cover index-zero retention and override
flags. This change is not yet Quest-built or installed.

## Current cross-platform build check (September 12)

Quest ARM64 development APK compiles successfully in17 seconds with native
shadow compute assembly, shared model palette preparation, bulk VRAM packing
and current background changes. Full build/vr-dev build also succeeds.
All14 VR CTest cases pass in13.13 seconds, including both cartridge input/state
suites. This verifies compilation and the existing automated coverage only;
no Quest frame-time improvement or visual acceptance is claimed. The APK was
not installed, since orbital surface continuation remains visually unfinished.

## Native VR shadow model compute path (September 12)

Further actual-compute comparisons pass: EX LEVEL5_2 city at180 ticks and
EX LEVEL1_1 departure at120 ticks from entry. Both eyes match the CPU-shadow
reference exactly in each case. City migrates3 shadows (6 to9 compute models);
departure migrates4 (11 to15). Evidence: tmp/vr-shadow-city-{cpu,gpu} and
tmp/vr-shadow-departure-{cpu,gpu}. This extends sampled shapes/camera coverage
but is still not exhaustive or headset proof.

Remaining whole-object sprite bypass is not a software rasterizer: draw_packet
already uploads corner signs/source size and its vertex shader does native
size truncation/capping. CPU palette expansion of those texture texels remains;
do not remove the bypass merely to count the sprite as a compute model.

Added @cpu-shadows to --live-compute-stage diagnostics; it disables only
shadow compute assembly and leaves normal model computation unchanged.
Runtime default remains enabled. EX Corneria held-Up and Original Corneria
held-Down at120 ticks each compare exactly in both eyes against that reference:
tmp/vr-shadow-ex-up-{cpu,gpu}, tmp/vr-shadow-original-down-{cpu,gpu}.
Both pairs report12 reference versus15 migrated compute models, confirming
three actual shadow migrations rather than a no-op comparison. All four
Vulkan runs pass. No headset or whole-game FPS verification is implied.

Removed the blanket shadow exclusion from SourceModels compute assembly.
Shadow LOD and the existing flattened/forced-colour pose are retained; models
unsupported by preparation still use the existing fallback. This migrates
native shadow geometry, not hardware ray tracing or enhanced shadow rays.

Actual compute-stage Corneria captures: tmp/vr-shadow-resident-baseline has
12 resident models; tmp/vr-shadow-resident-trial has15, including all three
shadow passes. Both eye BMPs match byte-for-byte and Vulkan checks pass.
The earlier tmp/vr-shadow-compute-before/after captures used the noncompute
diagnostic path and do not establish this migration's correctness. Broader
Original/EX poses and physical Quest validation remain; not installed yet.

## Shared VR model palette preparation (September 12)

SourceModels now packs the scene's 256 RGBA colours once, lazily on the first
compute model, instead of repeating channel shifts for every model. Each
prepared model still owns its palette array; no resource-lifetime or palette
invalidation contract changed. Assemblies with no compute models skip packing.
Packet tests and stereo Vulkan checks pass. Both EX LEVEL5_1 front eye images
in tmp/vr-shared-palette-proof match tmp/vr-orbital-cap-front byte-for-byte.
This removes repeated CPU preparation, not GPU work or per-model copies;
no measured whole-game FPS claim. Not installed on Quest yet.

## VRAM upload preparation (September 12)

Background and OAM sprite payloads now use shared pack_vram: one bulk64KiB
copy on little-endian hosts, explicit byte-to-word packing on other byte orders.
This changes data preparation, not tile decoding or GPU algorithms. Tests cover
all65536 byte positions across five patterns and guard both destination ends.
Fresh packet and Vulkan scene checks pass; both Corneria eye BMPs match the
pre-change baseline exactly (tmp/vr-bulk-vram-proof versus vr-ground-upload-reuse).

Existing host preparation samples dropped from~33.3 to2.34 us for landscape
packets and~34.9 to2.70 us for star spheres. These are sequential microbenchmark
runs, not controlled whole-game or Quest FPS results. Ground payload preparation
measured43.65 us including packet copies. Immutable GPU upload contracts remain
unchanged; full payloads still transfer when changed. No unsafe in-place mutation
of resources retained by a working scene was introduced.

EX LEVEL5_2 stereo captures also match the prior GPU-ground baseline exactly
(tmp/vr-bulk-vram-ex-proof). Quest ARM64 APK compilation passes in12 seconds.
This packing optimization has not yet been installed or timed on the headset.

## VR landscape receiver GPU deformation (September 12)

Upload proof: five receiver heights from-.001 to-8 reuse the landscape vertex
buffer; only the tile payload is re-uploaded. Repeated identical heights upload
neither buffer. Five malformed payload cases still reject transactionally.
Evidence: tmp/vr-ground-upload-reuse.log (real Vulkan fixture). The changed
value is one float, but the uploader currently transfers the complete tile
payload, not a four-byte subrange; no four-byte transfer claim is intended.

Host preparation microbenchmark (median of seven64-update batches, varied
heights, packet copy included): CPU-deformed657.956 us/update versus GPU-payload
54.4766 us/update. Both paths preserve vertex count; existing stereo comparisons
establish sampled visual parity. Excludes GPU shader execution and presentation;
not measured Quest timing or whole-game FPS. Packet tests pass after benchmark
addition. No production behavior change in this follow-up verification pass.

VR gameplay now flattens lower landscape triangles in the vertex shader.
Triangle classification is cached on immutable source geometry; changing
receiver height appends one float to the background payload instead of copying
and reshaping12,288 CPU vertices. The one-entry shared-geometry cache is
mutex-protected; custom/nonshared geometry rebuilds safely. The CPU builder
remains the reference via place_landscape_ground's default third argument.

Host GPU/reference stereo captures match byte-for-byte in four sampled cases:
Original Corneria forward and rear at both held vertical extremes, plus EX
LEVEL5_2 city forward (tmp/vr-ground-*). All eight eye images match. Packet
tests verify unchanged source vertices, per-triangle floor flags, immutable
reuse across height changes and independently stored height values. Five
malformed payload cases reject transactionally with zero replacement uploads.
Fresh packet/scene builds pass and shaders regenerate. No whole-game FPS gain
or headset acceptance is claimed; Quest build/deployment is recorded separately.

Quest ARM64 build succeeds (17 seconds). Authorized Quest3 was connected with
no running game process; install-r succeeded, retaining saves/settings. This
installs the GPU landscape receiver path. No automatic launch or headset
verification was performed.

## Full desktop regression refresh (September 12)

Full build/current rebuild succeeds. CTest passes54/54 in296.61 seconds,
including Original/EX ending, level-clear, transition, geometry pacing,
state/audio continuation, input, stereo, filters and embedded runtime checks.
This precedes the subsequent diagnostic-only scheduled revival hook; the
production model residual correction is included. Hardware acceptance and
the remaining migration/background requirements are not implied by this suite.

## Interpolated matrix coverage fix (September 12)

Follow-up regression: 32 Original models in five-layer mixed composition pass
384 images. Sixteen-model Original axis, destruction and alternate suites pass
288,1440 and768 images respectively, with exact coverage/palette ownership.
These include reuse/cancellation checks in mixed composition; not exhaustive
ROM/effect-combination coverage. The current Quest APK compiles successfully,
but its SDL GpuModel backend is disabled in favor of the separate OpenXR Vulkan
path; do not claim this desktop residual fix changes Quest model projection.

Preserve projection residuals for every continuous model in GpuModel, including
ordinary matrix-interpolated models. Previously only selected Euler, backface
and destruction cases retained them; distant model vertices could round to the
wrong side of a pixel boundary before clipping. Geometry remains GPU-resident.

Added opt-in STARFOX_TRACE_FINAL_MODEL_POSES (only final bounded test frame)
and --live-wingman diagnostic fixture using the captured ZACO_A pose. Despite
the fixture's name this is the source ZACO_A craft, not confirmed teammate art.
The fixture reproduced the 4x coverage failure at pixel474576 before the fix;
afterwards all three scales pass with exact coverage/palette ownership.
The new fixture's initial undersized diagnostic readback buffer was corrected
before accepting its results; that error was not a production buffer issue.

Strict full-scene captures at Original frame196/4x and EX frame205/2x now match.
Both previously failing 240-frame sequences also match every frame with default
bloom restored: tmp/gpu-wipe-sequence-residual-fixed (Original4x) and
tmp/gpu-wipe-ex-sequence-residual-fixed (EX2x). 32-model suites for each cartridge
pass another384 images each, exact coverage/palettes; these are bounded samples,
not a full-ROM/effect sweep. Maximum normal error remains5.96e-8. No FPS gain
claimed. Desktop rebuilt; no release or Quest deployment for this correction.

## Extended wipe sequence investigation (September 12)

Isolation update: added Scales and mutually exclusive RasterOnly/Geometry
diagnostic switches. Capturing exactly frame196 with all available effect
overrides disabled still fails with GPU geometry, but passes byte-exactly
with CPU geometry + resident GPU raster/composition. Evidence:
tmp/gpu-wipe-frame196-no-effects versus tmp/gpu-wipe-frame196-raster-only.
The no-effects mismatch is 11 pixels at x975..979/y296..313, on the small
wingman above the red building; actual palette colors differ, not just one
channel rounding. This narrows the cause to geometry/coverage. Do not alter
the wipe or compensate by disabling GPU geometry in production. Next capture
that model's interpolated pose and compare continuous projection/raster edges.
Also, the harness's label "native raster capture" describes window.save_bmp
output, not an independent raw indexed scene download; treat it as presentation
evidence until a raw intermediate capture is added.

New 240-frame/240 FPS strict default-pipeline comparisons expose a gap that
the previous final-frame checks missed. Original matches every frame at 1x/2x,
but diverges at 4x frame196; EX matches 1x but diverges at 2x frame205.
Evidence: tmp/gpu-wipe-full-sequence-240 and tmp/gpu-wipe-ex-full-sequence-240.
Original frame196 differs at 274 pixels inside x931..1025/y265..349 (1600x896);
the first eight inspected values differ by one red-channel unit. This is not
evidence that every difference has that magnitude. Native final captures match.
Inspected Original frames60/120/180 show a widening horizontal opening.

Added a bounded Bloom parameter to check_gpu_native.ps1 (default remains2).
Bloom0 reproduces the exact first failing frame in both ROMs. Original also
fails at frame196 with STARFOX_TEST_RTX_LIGHTING=0 plus Bloom0. Neither bloom
nor Enhanced Lighting explains the discrepancy. Corresponding evidence is in
tmp/gpu-wipe[-ex]-no-bloom-sequence-240 and tmp/gpu-wipe-no-lighting-sequence-240.
The earlier 48-frame/100-tick attempt was correctly rejected as uniformly black,
not counted as proof. Next isolate composition/remaining effects and capture
intermediate frames; do not relax exact parity or claim this sequence passes.

## Latest integration boundary (2026-09-11)

Added opt-in mono final-presentation sequence capture and bounded harness
comparison (1..240 frames). EX LEVEL1_3 at 240 FPS now matches CPU output on
every one of 48 frames at each of 1x/2x/4x: 144 exact frame pairs, with strict
no-CPU-composition gates. Evidence: `tmp/gpu-ex-tunnel-sequence`.
This is 0.2 seconds of simulated presentation per scale, not a whole-level
flicker guarantee. Per-frame readback/storage deliberately distorts performance;
these run timings must not be used as FPS benchmarks. SBS sequence capture is
not implemented by this mono test hook.

Post-readback compatibility changes: EX bomb sequence strict resident checks
and exact final captures pass at 1x/2x/4x (`tmp/gpu-default-ex-bomb-strict`).
Added ScrambleWipe to the same harness, invoking the existing native animation
test hook and requiring its GPU horizontal-wipe marker. Original injected
wipe at 240 FPS passes all three scales (`tmp/gpu-default-wipe-strict`). These
are path gates/final captures, not all-frame transition smoothness proof.
Quest ARM64 debug APK rebuilt successfully in 16 seconds; not installed.

Compatibility transition composition now downloads the completed GPU scene
instead of unconditionally rerendering all recorded models on CPU. Software
replay remains the download-failure fallback. Added GpuScene readback tests
against independent buffer downloads: 16 real models/192 images, exact pixels,
tags, write coverage, surface ownership/palette and normal/depth unpacking.
Strict migration checks reject both successful scene readback and CPU replay:
the compatibility path still composes on CPU and is not called fully migrated.
The eight-model trial contained no visible pixels and was correctly rejected;
only the passing 16-model fixture is counted as evidence.

Transition/overlay CPU scene replay now emits an explicit GPU diagnostic marker;
strict native-geometry capture checks reject it unless AllowFallback is set.
This closes a verification blind spot: successful geometry submission alone
does not prove resident final composition. The default-path save-slot overlay
capture passes strict checks and exact CPU/GPU final-image comparisons at
1x/2x/4x (`tmp/gpu-default-slot-strict`). Other transition paths still need
coverage and any remaining CPU replay must be migrated, not merely hidden.

Default native geometry coverage now also includes Original LEVEL1_2 asteroid
entry and EX LEVEL1_3 tunnel entry at 1x/2x/4x with exact final image parity.
EX tunnel 240 FPS/120-frame runs likewise pass all three scales; inspected the
actual tunnel capture under `tmp/gpu-default-ex-240`. This compares final
captured frames, not every intermediate frame or a full playthrough. Capture
filenames now include level and effective FPS to prevent multi-level proof
overwrites; cadence is explicit rather than inherited from saved settings.

Mono native GPU geometry is now the normal GPU-renderer path, not diagnostic
opt-in. The disable-only `STARFOX_DISABLE_GPU_GEOMETRY` flag preserves hybrid
comparison; SBS continues to require independent GPU geometry. The capture
harness explicitly removes the old opt-in for DefaultPipeline tests. Original
and EX Corneria pass exact native and final-presentation comparisons at 1x/2x/4x
in `tmp/gpu-default-original` and `tmp/gpu-default-ex`; inspected EX 2x final.
This does not prove every stage or non-Windows hardware. Small-scale scene
timings remain slower than hybrid; default migration is not an FPS gain claim.

DXR skips vertex/instance upload and BLAS/TLAS rebuild when actual packed GPU
vertex bytes are unchanged (no pointer/hash identity assumptions). Camera,
receiver and light constants still update. Twelve alternating stable/changed
geometry fixtures compare the reused backend against independent fresh DXR
devices byte-for-byte. The repeated-scene microbenchmark improved from roughly
0.258/0.442/1.088 ms to 0.121/0.342/1.022 ms at 1x/2x/4x in successive local
runs; this is not a controlled whole-game FPS claim.

DXR now exposes a completed, borrowed native D3D12 shadow buffer without copying
or allocating readback storage during resident rendering. Explicit diagnostic
downloads pass exact comparison with the existing download path across seven
packed-row sizes, repeated reads, invalidation and recovery on RTX 5070 Ti.
The buffer is not an SDL/Vulkan handle: cross-device presentation interop remains
unfinished, and the game still uses the existing download path. This is a
verified backend separation, not completed GPU-resident presentation.

Independent stereo receiver tests now pass for hardware DXR and Vulkan compute:
both eyes match CPU masks at receiver depths 384/512/768, projected shadow centres
are occupied, and the receiver patch has zero disparity at convergence 512.
Existing changing-geometry/receiver/empty-scene and 51 packed-row tests pass.
The older broad 4x stress fixture retains tolerated edge differences (DXR 1 of
1,433,600 pixels, compute 2; maximum delta 20); not universal bit-exact ray parity.
Portable resident mask lifetime/blending tests also pass. These fixtures prove
the eye transform, not completed GPU-resident stereo integration.

SBS now traces separate receiver masks per eye, translating casters/ground by
the eye origin and applying the same 512-unit off-axis convergence as geometry.
Presentation selects the corresponding mask, rejecting missing eye masks rather
than silently using mono. Original full-SBS DXR capture gate/build pass; inspected
`tmp/sbs-eye-ray-masks/presentation.bmp`. Independent shadow disparity tests
remain pending. Caster copies and mask readback are still CPU-side; this is not
the completed GPU-resident shadow migration or a performance improvement claim.

Ray tracing no longer forces native-GPU models through CPU rasterization just
to collect casters. Standalone caster collection shares transforms/triangulation
but skips projection and raster work; triangle vertices/order match combined
collection in the unit fixture. Actual DXR plus native-GPU geometry capture gate
passes at 1x/2x/4x, with exact native and final presentation parity against the
combined CPU-geometry path. Inspected 2x capture in `tmp/gpu-ray-caster-split`.
Caster transforms still execute on CPU; stereo ray masks remain a separate
unfinished integration requirement. Prior full CTest run completed 54/54 in
120.77 seconds before this caster extraction; targeted tests/build pass after it.

Full desktop rebuild passes after tile-list and explicit mask-size integration.
Dedicated Vulkan raster diagnostic passes 168 flat/texture/line/wave/wobble/
clip/sprite cases with exact pixels/tags/surfaces, malformed mask rejection,
32 changing unread submissions, resized buffers, queue/capture/release checks.
Full desktop CTest refresh is running on session 35319; continue that exact
handle until terminal. No full-suite pass is claimed from the targeted check.

Tile lists are now enabled within the existing native GPU raster path. EX
64-model wobble-batch finished successfully: 9216 images, exact coverage/palettes,
normal error <=1.19209e-7, depth <=.00012207, mixed layers/cancellation/reuse pass.
Default-path projection diagnostics and a fresh EX full-SBS connected-grid
capture pass; image inspected at `tmp/sbs-ex-tiles-default/presentation.bmp`.
Wave and >64 MiB candidate-list draws retain scan rasterization. Diagnostic
`STARFOX_TEST_DISABLE_TILED_SPANS` restores scanning for A/B comparisons.
This does not enable native geometry by default in ordinary mono gameplay.

Tile-list validation expansion: Original and EX each pass 64 alternate-effect
models / 3072 images, exact coverage/palettes and bounded surface error. Original
16-model mixed-batch test passes 192 images plus black writes, independent
surface ownership, cancellation/recovery and ping-pong reuse. Portable raster
and bin freshness checks pass after replacing the unsupported Metal dynamic
buffer-size binding with an explicit mask-size uniform. EX 64-model
`--wobble-batch` is still running on exec session 95965; resume that handle,
do not restart it merely because it has not printed output yet.

Experimental tile lists (`STARFOX_TEST_TILED_SPANS`) now compact source-ordered
row spans by 64-pixel tile before rasterization. Wave draws retain the existing
scan path; lists above 64 MiB fall back. GPU projection/pixel fixtures pass with
the switch enabled. First 600-frame Corneria pair: tiled median 3044 us versus
scan 4101 us, matching final captures. This is still diagnostic-only pending
broader effects/model coverage. `-CompareTiles` labels tiled as serial and scan
as queued for compatibility with the existing benchmark pair filenames.

Direct mono promotion benchmark is now available via
`tools/benchmark_scene_queue.ps1 -CompareGeometry`. Original Corneria at 2x,
240 presentation FPS, effects/rays off, 600 frames with 60 warmup: CPU geometry
median 670 us versus GPU geometry 4077 us on the first repeat; GPU repeat 4223 us.
Final presentation hashes match in completed pairs. This measures host render
timing, not hardware GPU timestamps. Presentation/submission dominates the
GPU path (~3.3–3.5 ms average); do not promote it as a performance improvement.
Raw evidence is in `tmp/geometry-promotion-repeat` and the shorter baseline in
`tmp/geometry-promotion-baseline`. Reduce ordered pipeline overhead next.

Current `starfox_pc.cpp` enables ordered native model/grid/dust/particle/projected
text GPU scenes for SBS or `STARFOX_TEST_GPU_GEOMETRY`, not ordinary mono by
default. Particle and projected-text shader/scene parity now pass. Original
ending full/half SBS captures exercise projected text without fallback.

Quest ARM64 debug APK rebuilt successfully in 18 seconds after these changes.
Its configuration still excludes `STARFOX_SDL_GPU_EFFECTS`; this is compilation
evidence for shared code, not execution evidence for these new compute paths.
Quest's separate VR backend and desktop mono promotion remain migration work.
No headset installation or release was performed. Older chronological notes
below do not override these current integration boundaries.

## Current validation gate (2026-09-11)

Native model rendering remains diagnostic-only, not the default gameplay path.
The latest completed desktop regression run passes 54/54 tests. Targeted
TOTEM_2 backface, TREE destruction and LBLACKFACE checks pass, but broad model
scans previously exposed MBLACKFACE coverage and BEEANIM palette discrepancies.
Both are now resolved, including the later SHIP_0_C viewport-clipping case:
full backface catalogs pass 111,744 images across Original and EX with exact
coverage/palettes and zero deferred models. Maximum normal error is
1.19209e-7; depth error .000244141. This validates that mode, not all modes.
PIPE_5 is now resolved using lossless camera transport and exact line clipping.
Full axis catalogs pass: Original 2,697 models / 48,546 images; EX 3,511 models /
63,198 images. Coverage/palettes match exactly, zero normal/depth error, and
no deferred models in either axis scan. Other rendering modes remain separate
gates; the rebuilt desktop regression refresh passes all 54 tests. The full
VR build also passes, with 13/13 VR CTests passing (not headset validation).
See ACTIVE-DELIVERY-CHECKLIST.md for exact fixtures and subsequent results.
These results do not establish whole-catalog parity, performance readiness,
or completion of the separate VR/device validation requirements.

## Wave spans: implemented in diagnostic GPU path

Source inspection confirms wave mode changes the destination Y per pixel by
the 32-entry signed sine table (range -3..3), after source 16-bit phase wrapping.
It applies only to untextured fills with no cel/wireframe override. GpuModel's
direct-row path now performs inverse wave lookup while retaining painter order
and surface ownership. Full frame-zero sweeps pass for both games; animated
geometry has an independently reproduced clipping precision defect below.

The raster shader now contains an opt-in neighboring-row lookup and source
signed-16-bit wave phase calculation. Material/span encoding and GpuModel's
row-span flag are wired; both portable headers are regenerated. The diagnostic
GPU model pipeline now accepts wave mode. Packing tests pass, including signed
offset and animation wrapping. The first 64 Original models pass 768 wave
images (935,295 nonzero pixels), coverage/palette exact; normal error <=
5.96046e-8 and depth error <=0.00012207. Ordinary rendering also passes the same
64-model/768-image sweep. Full sweeps terminated at Original FACE_0 and EX
FACE_0_1, view 5 / scale 2, pixel 501: visible pixels still match but surface
ownership differs (CPU depth 410.666656, GPU 325.333344). Investigate metadata
ownership at clipped/waved edges before promoting this diagnostic path. No
full wave parity or default GPU migration completion is claimed yet.

Face isolation (`--wave-faces`) narrows the failure to FACE_0 face 19
(normal -120,0,40), view 5 / scale 2. Its comparison image contains 85 missing
GPU edge pixels, starting at (53,0); earlier whole-model faces obscured the
visible difference while metadata still exposed it. All 55 isolated faces
pass without wave (660 images). Inspected paired capture:
`tmp/wave-face-proof/model-47523-face-19-layer-0-mode-0-view-5-scale-2.bmp`.
The initial inference that this isolated wave lookup was premature: the
non-wave test used animation frame zero, while wave view 5 selects frame 15.
The new matched `--wave-control` keeps frame 15 and disables only wave; it
reproduces the same normal/depth ownership mismatch (pixel 52 rather than the
waved pixel 501). Thus animated geometry parity is independently defective.
`--wave-static` separates full wave raster testing on frame zero from that
animation defect. Both frame-zero sweeps have completed. Neither selector replaces
the required animated-wave comparisons.

Original frame-zero wave sweep completed: 2,697 models / 32,364 images /
81,820,385 nonzero pixels pass, coverage/palette exact; maximum normal error
1.19209e-7 and depth error 0.000244141. EX also passed, as recorded below. Expanded
bounded geometry readback (up to 63 points within the existing 4 KiB diagnostic
reserve) reveals FACE_0 frame-15 face 19's final clipped X=26.249998092651367;
at 2x this rounds below the 26.25 half-pixel boundary. Its other vertices are
(0,0), (0,92.352951), and (74.245163,47.995167). The prior wave-specific
diagnosis is superseded by this animated clipping precision evidence.

Preserving projection residuals for ordinary continuous Euler geometry (not
only exploding geometry) fixes both FACE_0 and EX FACE_0_1: each passes all
12 animated-wave images including surface metadata. Matrix and axis retention
conditions remain unchanged. Tested in separately linked
`tmp/gpu-wave-precision.exe`, because the original checker remains in use by
the EX frame-zero sweep. Broader sweeps rejected this experiment, as recorded
below; it is not the current implementation.

The pre-residual-change EX frame-zero wave sweep also completed successfully:
3,511 models / 42,132 images / 124,998,465 nonzero pixels, exact coverage and
palettes; normal error <=1.19209e-7, depth error <=0.000244141.

The broad Euler residual experiment is REVERTED: both full sweeps failed
TOWER_2 view 5 / scale 1 at pixel 23. Rebuilt after reverting, TOWER_2 passes
all 12 animated-wave images with exact surfaces (19,047 nonzero pixels).
FACE_0 animated clipping remains unresolved. Do not use the separately linked
`tmp/gpu-wave-precision.exe` as the current implementation; it retains the
failed experiment. Wave raster support and its full frame-zero proofs remain.

Wave lookup optimization: GpuModel supplies the shared source phase in uniform
data. Each pixel computes inverse Y once, then checks two candidate rows per
polygon (wave and ordinary) instead of seven neighboring rows and repeated
phase evaluation. Textured/line spans retain their ordinary row. The rebuilt
checker passes the initial 64-model animated-wave and ordinary sweeps (768
images each, exact coverage/palettes). Full optimized sweeps also pass:
Original 32,364 images and EX 42,132 images, retaining the exact coverage,
palette and surface bounds above. No whole-game FPS improvement is claimed.
Quest ARM64 debug APK rebuilt successfully in 35 seconds after the API/shader
changes. It was not installed or physically verified on a headset.

Mixed-scene wave integration (`--wave-batch`) passes 64 models / 768 images
for each game. Five ordered layers include distinct wave phases, a non-wave
layer, CPU-recorded draws, black writes without surface replacement, and
ping-pong reuse. Exact coverage/palettes and surface tolerances pass; partial
batch rejection/cancellation and reused-resource recovery also pass. This is
a bounded integration check, not full-level validation.

Upscale coverage correction: the earlier full wave sweeps covered 1x/2x only;
the checker inherited an ordinary-model 4x skip. Wave selectors now include
4x and allocate enough readback space for it. Expanded mixed-batch checks pass
64 models / 1,152 images per game at 1x/2x/4x (Original 5,198,894 nonzero
pixels; EX 3,050,822), preserving exact coverage/palettes and prior surface
tolerances. Full frame-zero Original and EX sweeps including 4x are running.
The earlier 74,496-image total must not be cited as 4x verification.

Sequential Euler groundwork: projection packets now retain high/low source
sine/cosine and byte/word scale operands separately from the existing matrix
poses. Packing tests verify reconstruction to 1e-14 and word-scale bypass.
These operands are not yet uploaded/consumed by the GPU; rendered behavior is
unchanged. The intended next step is source-ordered X/Y/Z rotation rather than
assuming a precombined matrix preserves double-rounding at clip boundaries.

Sequential Euler integration now runs in the diagnostic GpuModel path for
non-exploding, non-axis Euler geometry. Two extra operand records preserve
the existing fragment layout; the shader performs scale, X/Y/Z rotations and
translation in source order with compensated arithmetic and explicit rounding.
FACE_0 and TOWER_2 both pass 18 animated-wave images at 1x/2x/4x, including
surface metadata. Tests use `tmp/gpu-euler-sequence.exe`; full Original/EX
animated-wave sweeps of this implementation are running. General precision
compatibility is not yet proven. The older `gpu-wave-precision.exe` remains
the rejected experiment, not this implementation.

The pre-sequential-transform Original frame-zero wave sweep including 4x
completed: 2,697 models / 48,546 images / 341,728,689 nonzero pixels; exact
coverage/palettes, normal error <=1.19209e-7, depth error <=0.000244141.

EX pre-sequential-transform frame-zero wave sweep including 4x completed:
3,511 models / 63,198 images / 523,478,636 nonzero pixels; exact coverage and
palettes, normal error <=1.19209e-7, depth error <=0.000244141. Combined with
Original this is 111,744 images at 1x/2x/4x. The current sequential-transform
shared sources also compile successfully in the Quest ARM64 debug build
(42 seconds); the diagnostic GPU model path is not thereby enabled on Quest,
and no headset installation or visual verification was performed.

Rebuilt projection checker passes 393,987 exact native points/faces, 131,329
continuous transform fixtures, cancellation-depth cases and all 60 axis
reduction/projection cases. These protect the existing projection branches;
the new sequential branch is covered separately by the model sweeps.

Current sequential Euler FACE_0 isolation passes all 55 faces / 990 images at
1x/2x/4x, including animation frame 15. Inspected CPU-left/GPU-right proof of
the formerly missing edge:
`tmp/euler-isolated-fixed/model-47523-face-19-layer-0-mode-0-view-5-scale-2.bmp`.
Whole-model comparisons also pass. The 64-model destruction regression sweep
passes 5,760 images / 10,120,864 nonzero pixels, exact coverage/palettes;
normal error <=5.96046e-8, depth error <=0.000976562. Full animated sweeps
remain running; these local successes do not establish all-model completion.

Sequential Euler full Original animated-wave sweep completed successfully:
2,697 models / 48,546 images / 345,427,401 nonzero pixels, exact coverage and
palettes; maximum normal error 1.19209e-7 and depth error 0.000244141. EX is
still running. This samples animation frames selected by the six test views,
not every frame of every model.

Next color-warp implementation constraint: SoftwareRenderer advances the
16-bit carry-dependent material generator only after a face passes visibility,
in BSP painter order, before screen clipping. Animated random descriptors can
consume up to 32 words for one face. A parallel per-face seed or advancing
only for on-screen faces would change the result. The GPU implementation needs
an ordered material pass after visibility/BSP; the current rejection stays.

EX sequential Euler animated-wave sweep completed successfully: 3,511 models
/ 63,198 images / 532,183,731 nonzero pixels; exact coverage/palettes, maximum
normal error 1.19209e-7 and depth error 0.000244141. Both games now pass the
six-view animated-wave sweep at 1x/2x/4x; this does not cover every animation.

Color-warp groundwork: `colour_warp_portable.hlsl` implements the bounded
carry-dependent sequence in traversal order, with visibility gating and
output indexed by traversal occurrence (shared subtrees may repeat a face).
It validates the list before output and publishes failure status on invalid
input. DXC SPIR-V compilation passes. Device execution, material decoding and
runtime integration are still required; GpuModel continues rejecting warp.

Color-warp device test now passes 32,768 ordered descriptors across 128 seeds
and visibility patterns, with repeated face IDs, plus invalid traversal status,
oversized counts, invalid face IDs and an empty list after reused resources.
The Vulkan test compares against an independent arithmetic CPU sequence.
Portable SPIR-V/Metal header generation is integrated; CMake exposes
`starfox_gpu_colour_warp_check`. Material decoding and GpuModel integration
remain pending, so color warp is still rejected by the model pipeline.

Warp material decoder shader added and DXC-compiled. It handles palette/forced
overrides, texture-descriptor lookup, smooth flat colors, diffuse lighting,
depth-color tables, dither and palette-base wrapping. Diffuse data uses bounded
4x62x10-byte layout and a 65,536-entry texture descriptor lookup is required.
Device equality tests and occurrence-specific texture-coordinate integration
remain pending; a successful compile is not a rendering parity claim.

Material decoder device equality now passes: `starfox_gpu_warp_material_check`
compares all 65,536 descriptors over 16 shading/override fixtures against the
production CPU `face_material` resolver (1,048,576 results). Includes diffuse
table presence/absence and bounds, clamped depth bands, depth tables, real and
missing texture descriptors, smooth colors, forced/palette override precedence,
and wrapping palette bases. SPIR-V/Metal header generation and CMake target
are integrated. Runtime wiring and occurrence-specific texture coordinates
still remain; color warp is not yet enabled in GpuModel.

Warp texture resources now pack a full descriptor lookup, per-texture masks
and offsets, all four source UV coordinates, and aligned texel storage.
Duplicate descriptors preserve first-match semantics; inaccessible trailing
texels are omitted, short payloads reject, and uploads are capped at 16 MiB.
Unit fixtures and all 2,697 Original / 3,511 EX model packaging checks pass.
These resources are not yet wired into occurrence-specific GPU clipping.

Occurrence expansion shader added with generated SPIR-V/Metal: each ordered
draw receives separate polygon/corner/material slots, including texture-specific
UVs, palette/layer tags and scroll. Repeated source face IDs no longer imply
shared material storage. The shader rejects invalid texture/coordinate ranges
and clears unused output slots. It compiles; device execution tests and the
resident pipeline wrapper remain pending. No in-game color-warp support is
claimed from this stage alone.

The sequential-transform mixed-scene check passes 64 Original models / 1,152
images, including black writes, independent metadata and cancellation/reuse.
Packet preparation now evaluates each source sine/cosine once per pose and
reuses the values for both matrix and sequential operands; no arithmetic
reordering was introduced inside the matrix expressions. Rebuilt packing
tests pass all Original 2,697 models / 3,931 frames and EX 3,511 models / 5,447
frames. Full sequential animated rendering sweeps remain in progress; these
packing results are not substitutes for image comparisons or FPS benchmarks.

## Post-0.0.6.5 optimization work (unreleased)

### Latest verification checkpoint (2026-09-11)

The full Original destruction sweep is now terminal **passing**: 2,697 models,
242,730 images, 977,680,044 nonzero pixels; coverage/palette exact, maximum
normal error 1.19209e-7 and depth error 0.000976562. It includes the retained
SHIP_1 clipping fix and predates only scan/reserve optimizations already checked
separately. This does not cover EX's known TREE failure or axis collapse.

An optional backface-culling conversion was tested and reverted: 64 models /
768 images passed, but the full Original run failed TUNNEL_8 at Euler view 4,
scale 1, pixel 20724. Isolated face 6 (normal 0,-127,0, indices 3/2/1/0,
all source Y=0) reproduces coverage disagreement. Compensated projected-area
arithmetic is insufficient to reproduce source-double winding ownership at
this edge-on face. No culling conversion is enabled. The model checker retains
`--backface` and `--backface-faces` audit selectors for the eventual fix; current
GPU packing still explicitly rejects that unsupported option. Capture:
`tmp/backface-tunnel-proof/model-48755-face-6-layer-0-mode-0-view-4-scale-1.bmp`.

Current scene-queue benchmark (240 frames, two alternating-order pairs,
tmp/scene-queue-current-refresh) retains resident geometry without whole-frame
fallback and matches final presentation hashes. Queued medians are 4458/4299 us
versus serial 5030/5286 us; queued p95 5649/5408 us versus 6250/6401 us.
The destruction sweep was running concurrently, so these are comparative
contended diagnostic samples, not clean FPS or allocation-change speedup
claims. The four runs use the rebuilt desktop executable.

The model checker now reports direct CPU enqueue median/p95 separately from
the later GPU fence/readback. Current 90-case destruction runs measure
SHIP_1 at 65.1/126 us and KICHI_0 at 65.6/107.9 us; both remain pixel/metadata
parity-passing. These are diagnostic submission measurements with mixed
scales and allocations, not in-game FPS or a before/after speedup claim.

Fragment submission now reserves continuous/native vertex, pose and visibility
streams from known corner/face bounds, including the extra unmodified sprite
pose. This avoids repeated growth during destruction preparation. All 360
cases across BOSS_F_1A, KICHI_0, KICHI_3 and SHIP_1 still pass on the rebuilt
core. No gameplay FPS gain is claimed without a representative benchmark.

Optimized the interior-polygon guard: only non-residual compensated matrix
polygons perform its extra point scan, and the scan stops at the first outside
point. Ordinary/residual polygons and lines avoid that redundant pass. The
dedicated clipping suite and 90 cases each for BOSS_F_1A, KICHI_0, KICHI_3
and SHIP_1 pass on the rebuilt core. No frame-FPS improvement is claimed;
this removes known redundant reads without changing the checked output.
The running full sweep predates only this scan optimization.

A seventh residual clipping fixture now exercises a SHIP_1-style line with
an exact 16.25 top-edge intersection, enforcing its 2x rounded endpoint. It
and the existing clipping/span cases pass. GPU composition also passes its
108 base cases and resident/uploaded shutter, circle, fade, colour-math,
window, overlay and model/glow split fixtures. PIPE_5 Original / PIPE_4 EX
still fail axis coverage at pixel 21619: the refined clip now emits exact
(211.5,0)/(19.5,192), but source raster ownership still differs. The fresh
full Original destruction sweep is running separately.

SHIP_1 is fixed in the diagnostic renderer: face 27's clipped two-point line
previously narrowed to X=16.249998092651367 at 2x. A second compensated
division remainder correction in clipping now makes all 90 SHIP_1 cases
pass. BOSS_F_1A, KICHI_0 and KICHI_3 still pass 90 cases each, and the full
dedicated clipping/span suite passes. This refinement is retained for the
line fix; the earlier experiment did not fix KICHI_0 under matrix residual
integration, which remains disabled. Full model sweeps still need rerunning.

The fresh full Original destruction sweep with the retained quotient/interior
fixes reaches SHIP_1 after the 256-model checkpoint, then fails write coverage
at pixel 32 (progress 1 / Euler view 4 / scale 2). This sweep is terminal;
it is not the prior BOSS_F_1A run and must not be reported as passing.
All current desktop targets subsequently build successfully; a new full
CTest run was started against those rebuilt executables.

Preserving the compensated matrix clipping tail at final narrowing fixes all
90 TREE cases (and keeps BOSS_F_1A/KICHI_3 passing), but reintroduces KICHI_0's
pixel 643552 failure. Quantizing that final tail to binary64 spacing does not
remove the false intersection residual. Both experiments were reverted.
The remaining blocker is distinguishing a real subpixel remainder (TREE)
from accumulated arithmetic error around an exact intersection (KICHI_0).

TREE's failing view is now captured directly: camera corners include
(-21,105,236) and (-17.0001220703125,89,256); bottom clipping emits
(93.375,192). The source-double intersection of those projected endpoints
needs comparison against that half-pixel narrowing, independently of metadata.
The trace selector now includes progress 1 / view 1 / scale 4.

With the refined continuous quotient, the wholly-interior polygon path now
passes BOSS_F_1A, KICHI_0 and KICHI_3 (90 images each). The clip shader keeps
the producer's projected coordinates for polygons wholly within the viewport
and in front of the camera; lines and polygons requiring clipping retain
compensated camera re-projection. The dedicated clipping suite passes. TREE
still fails unchanged at pixel 671482. Fresh 64-model Original and EX sweeps
both pass 5760 images each;
this improvement remains diagnostic-only and does not establish full parity.
This supersedes the earlier failed interior-path experiment made before the
projection division refinement. Matrix residual transport remains disabled.

TREE reproduces on the latest rebuilt checker. Isolated face 39 (shift 2,
normal 65,73,81; vertices 40,43,45,41) fails write coverage at the same
pixel 671482, progress 1 / view 1 / scale 4. Thus the aggregate normal/depth
mismatch is caused by different face ownership under identical visible colors,
not established as an error in the normal transformation. The checker now
captures metadata-only failures too and reports actual as well as expected
depth. Do not weaken metadata assertions because color images match.

The long EX destruction sweep is terminal: after the 2816-model / 253440-image
progress checkpoint, TREE fails at view 1 / scale 4 / progress 1. Visible image
pixels match, but surface metadata differs at pixel 671482: maximum normal
error 0.784818, depth error 80, expected depth 302. This is a lighting-relevant
failure, not a passing image. This binary predates the latest projection
quotient refinement and near-residual updates. Original's same run had already
failed BOSS_F_1A; neither full sweep passed.

Rounding each compensated screen-intersection subtraction, division,
multiplication and addition to a binary64-sized tail quantum still leaves
KICHI_0's mismatch. Dedicated clipping tests pass, but the real-model failure
does not; the experimental intersection rounding was reverted. This suggests
the two-float inputs/intermediates have already lost information that final
tail quantization cannot restore. Do not repeat this as a purported fix.

The source-double arithmetic for KICHI_0's isolated bottom intersection
evaluates to exactly 60.125. Adding a second remainder correction to clipping
division does not fix the mismatch (although the clipping suite and the other
two isolated models pass). That clipping experiment was reverted. The next
check must preserve source rounding of the intersection operations, not merely
increase the quotient accuracy. Matrix residual integration remains disabled.

KICHI_0's matrix-residual regression is isolated to face 34 (shift 6, normal
-73,73,-73), progress 1 / view 0 / scale 4. Camera corners are
(-147,45,365), (-83,109,365), (-83,429,685), (-147,365,685).
Bottom clipping emits (38.5,192) and (60.124996185302734,192); the latter
crosses the 4x rounding boundary near 60.125. This supplies a compact
intersection fixture for the next precision check. Matrix residual transport
was only enabled for this diagnostic and remains disconnected in the worktree.

KICHI_3's precision failure was traced to the exact projection
96 + 127.875 * 256 / 4224 = 103.75. One quotient correction retained a false
negative tail; a second compensated remainder correction makes its 90 images
pass when matrix residual transport is enabled. BOSS_F_1A also passes, but
KICHI_0's palette mismatch at pixel 643552 remains. The division refinement
is retained for further tests; matrix residual integration is disconnected
again pending that remaining regression. Diagnostics now include scale 2
for progress 127 / view 1.

Continuous destruction projection now rounds its compensated numerator and
quotient separately before adding the vanishing point, matching project_point's
distinct source-double multiplication/division/addition boundaries. All
393987 native and 131329 continuous projection checks, cancellation fixtures,
and axis checks pass. Fresh 64-model Original/EX destruction sweeps both pass
5760 images each, including exact coverage, surface palettes and bounded
normal/depth checks. Cancellation fixtures now also reconstruct screen high/low
pairs and compare with separate source-double projection operations (relative
tolerance 1e-12). This is not full-model parity or permission to enable native models.
Matrix residual integration remains disconnected as before.

Restricting matrix camera re-projection to polygons needing near/viewport
clipping makes BOSS_F_1A and KICHI_0 pass all 90 images each, but KICHI_3
still regresses at progress 127 / view 1 / scale 2 (pixel 92936). Reverted
that experiment too: a wholly-inside fast path alone is insufficient. Next
precision investigation should compare KICHI_3's original double camera and
projection with the continuous producer before changing clip selection again.

A second experiment applied final subpixel-boundary tail preservation to
compensated matrix polygons without supplying the projection residual stream.
The dedicated clipping suite passed, but BOSS_F_1A still failed and both
KICHI regressions returned. This experiment was also reverted. The mismatch
cannot be fixed merely by broadening final narrowing: source camera rounding
and clipped-versus-unclipped projection semantics need to be distinguished.

The BOSS_F_1A failure is isolated to face 11 (normal 122,0,-36):
projection emits X=179.62498474121094, but camera re-projection in clipping
changes it to 179.625 at progress 127 / matrix view 1 / scale 4. Enabling
residual transport for all matrix destruction fixes this model's 90 images,
but regresses KICHI_0 (surface palette, view 0 / scale 4 / progress 1,
pixel 643552) and KICHI_3 (coverage, view 1 / scale 2 / progress 127,
pixel 92936). That integration experiment was reverted; no broader fix is
claimed. Face diagnostics now include this matrix/progress case.

The full Original destruction sweep now reaches another failure: BOSS_F_1A,
layer 0, mode 3 (progress 127), view 1 (Q15 matrix), scale 4, write coverage at
pixel 343886. This run includes screen-pair transport but predates the later
near-intersection residual changes. EX's corresponding sweep is still running.
The bounded passing cases below do not establish full destruction parity.

Four dedicated residual-axis fixtures pass positive/negative camera tails,
three-point averaging, singleton reduction, invalid validity and NaN rejection.
Reconstructed camera means and screen high/low pairs agree with source-double
fixture calculations within 1e-12. The original 60 no-residual axis and all
projection/visibility fixtures remain passing. This validates the transport and
basic reduction, not source operation-order fidelity at the failing pipe-model
rounding boundaries; model integration remains disconnected.

The axis model connection described below was subsequently disconnected:
the 64-model Original sweep regressed EXPLOSION at view 5 / scale 1, pixel
21173. The optional residual-aware reduction API/shader remains available for
dedicated testing, but GpuModel keeps the prior non-residual axis behavior.
Destruction continues to use its tested precision transport. The new axis
arithmetic is not accepted as source-parity rendering.

Axis precision transport is now connected: optional camera residual input,
two-point camera/screen high-low output, and residual-aware line clipping.
The no-residual projection fixtures still pass. PIPE_8 passes all 15 images.
PIPE_5 Original / PIPE_4 EX remain failing: the new path yields approximately
(211.4999847,0) / (19.4999981,192), moving their first coverage disagreement
from pixel 21619 to 211. This is not a complete fix; ordered averaging and
source-double rounding still need verification. It remains diagnostic-only.

Near intersections now carry camera XYZ residuals through line/polygon
interpolation and projection, including the surviving front vertices' depth
tails. A sixth residual fixture has one behind-camera vertex with a nonzero
camera-X tail; both generated intersections retain the expected rounding side.
All native/fractional clip and span regressions pass. The running catalog binary
predates this near-intersection extension, so its result cannot establish this
new path's catalog parity. Residual-aware axis reduction remains outstanding.

The new precision path passes both 64-model destruction sweeps: 5,760 images
per variant, with indexed pixels, write coverage, tags and surface checks intact.
Five dedicated clip fixtures now verify positive/negative/zero residual sides
at a 4x rounding boundary and reject invalid/short residual streams. Nonfinite
screen pairs also reject. Existing clipping checks pass: 25,362 native and
25,362 fractional polygons, 31,418,112 native raster pixels, 48,435,200 fractional
span pixels, and 24 source near-plane cases. Projection/visibility regressions
also pass. Full model-catalog reruns remain required; these fixtures do not yet
test residual transport through a near-plane intersection or axis reduction.

Fractional destruction clipping now consumes the preserved screen high/low pair
directly and preserves its rounding-boundary side on final narrowing. Transport
uses camera residual XYZ/validity followed by screen high XY and low XY; the
older residual-relative-to-adjusted-screen layout below is superseded. That old
layout lost the tiny tail when subtracting a deliberately shifted float.
BOSS_F_6 Original, BOSS_F_7 EX and KICHI_1 Original now pass all 90 images each,
including the previously failing 4x edge and 2x half-pixel cases. Surface/coverage
checks remain enabled. The older EX full sweep finished failing BOSS_F_7 after
2,304 models / 207,360 images; it is not still running. New 64-model sweeps are
running against the precision transport change. Full-catalog proof and residual
handling through near intersections/axis averaging remain outstanding.

Precision transport prerequisite: `enqueue_continuous` can now return an optional
borrowed residual buffer alongside existing projected points. Two float4s per
point retain camera residuals/validity and screen residuals relative to the
returned FP32 values, including boundary-adjusted screen values. Vulkan/Metal
bindings are regenerated. Callers not requesting residuals allocate only a
one-record binding and skip writes; the existing point layout is unchanged.
The four-vertex destruction cancellation fixture requests/readbacks residuals
and reconstructs camera XYZ against source doubles within 1e-9, confirming
nonzero tails. The prior 393,987 native, 131,329 continuous and 60 axis fixtures
also pass. Clipping/axis consumption is not yet connected; these model-level
failures remain open.

The paired axis rerun is now terminal: Original fails PIPE_5, EX fails PIPE_4,
both view 5 / scale 1 at pixel 21619. Direct targeted traces reproduce both:
GPU clipped endpoints are exactly (211.5,0) and (19.5,192). Full axis parity is
not established even though PIPE_8 passes.

Reprojecting every continuous destruction fragment from narrowed camera
coordinates was tested and rejected: BOSS_F_6 still fails, and KICHI_1 regresses
to the previous 15-pixel / depth mismatch. FACE_B still passes 90 images in
that trial. The change was reverted, core and diagnostic executable rebuilt,
and KICHI_1 again passes all 90 images. Future work must transport the original
compensated projection/camera residuals into downstream clipping and axis
averaging; recomputing from FP32 camera values is not equivalent.

Further catalog/trace results: the revised Original axis sweep reaches PIPE_5
and fails view 5 / scale 1 at write-coverage pixel 21619. Its paired EX sweep
is still running. PIPE_8's targeted fix therefore does not establish complete
axis parity. The separate EX destruction sweep has passed 1,536 models /
138,240 images so far.

The diagnostic checker now supports bounded single-face fractional readback
(up to 32 camera/projected points and 128 clipped corners). BOSS_F_6 face 5's
right-edge CPU intersection is (224,72.124999758525931), versus GPU (224,72.125),
changing the 4x rounded vertex row. Preserving only the final clipping residual
did not fix it; that trial was removed and shaders rebuilt. Temporary CPU trace
instrumentation was removed. The next investigation must retain/compare earlier
projection residuals, not adjust final pixel tolerances.

PIPE_8 axis follow-up: optional borrowed diagnostic buffers now expose projected
points and clipped polygons without production readback. The failing view's
CPU endpoints are X=211.50000000000006 / 19.500000000000057; GPU clipping of
narrowed screen coordinates gave 211.49998474121094 / 19.499984741210938.
Axis models now opt into the existing compensated camera reprojection during
clipping, yielding 211.5 / 19.5. PIPE_8 passes all 15 images in Original and EX;
64-model axis sweeps pass 960 images each, and ordinary Original rendering
passes 768 images. Full axis catalog reruns are underway. The diagnostic-only
status and unresolved native axis / destruction gaps remain unchanged.

The expanded Original destruction sweep passes at least 2,048 models / 184,320
images, then fails BOSS_F_6 at progress 1, Euler view 5, scale 4: write coverage
pixel 259834. The Original continuous axis sweep fails PIPE_8 at view 5, scale 1:
write coverage pixel 211. EX also fails the same PIPE_8 axis case. These are
unresolved parity failures, not full-catalog passes. The EX destruction sweep
continues separately. Neither feature is promoted
from the diagnostic path.

The isolated-effects test still expected the retired Enhanced Shadows override
to produce shadows under SDL's dummy driver. It now checks that override is
inert, explicitly disables ray tracing, and retains independent HDR/chromatic,
menu peek/restoration and localized-menu checks. The updated test passes;
hardware DXR remains covered separately by `check_ray_tracing.ps1`.

The full 52-test run finishes with 51 passes and only the pre-correction shadow
test failure; that corrected test separately passes. This is not a fresh single
52/52 run. Failing GPU frames are now captured before write-coverage assertions,
including black writes. The BOSS_F_6 failure isolates to face 5: normal
(125,-22,4), shift 3, vertices (-6,-9,48), (0,21,30), (-4,-9,-10).
CPU-left/GPU-right images were visually inspected in `tmp/gpu-boss-f6-failure`
(face 5, mode 0, view 5, scale 4) and `tmp/gpu-axis-pipe-failure` (view 5,
scale 1). Both show edge/coverage differences rather than wholesale missing
geometry; the numerical cause is still under investigation.

Axis investigation: replacing the final sum/projection arithmetic with
compensated pair multiplication/division still fails PIPE_8 at the identical
pixel 211, while all projection fixtures pass. That attempted change was
discarded and generated shaders/core rebuilt. It does not establish that the
whole projection/clip chain is correct; camera averaging and endpoint rounding
still need direct comparison. The EX destruction sweep has passed at least
640 models / 57,600 images and is still running.

### Native destruction transform prerequisite

The source-word GPU transform accepts an explicitly tagged per-face destruction
pose. It rotates the authored normal independently of vertex scale, forces Y
downward, applies signed floor division by four, and adds the fragment offset
after the wrapped object transform. Expanded camera coordinates remain intact
for near clipping; only the downstream source projection performs word wrapping.
Ordinary, untagged poses are unchanged.

`starfox_gpu_projection_check` now compares raw GPU camera coordinates as well
as projected points/visibility. Three phases cover 393,987 points/faces, including
the new destruction phase with progress 0/1/2/127/255, signed normals, arbitrary
Q15 matrices, source seams and invalid pose indices. All pass. The existing
131,329-point continuous projection/visibility tests also pass; Vulkan/Metal
shader regeneration is current.

`GpuModel` now duplicates native vertices per face and uploads tagged destruction
poses, bypassing source visibility/BSP for fragments. The `--destruction` checker
compares five progress values (1/2/31/127/255), three Q15 views including near
clipping, and native scale 1 against SoftwareRenderer. Original: 2,667 models,
40,005 images; EX: 3,457 models, 51,855 images. Indexed pixels, layer tags, surface
coverage and palettes match exactly. Maximum normal error is 1.19209e-7;
maximum depth error is 0.000976562, within the checker's relative tolerance.
The subsequent sprite-centre gate migration includes those previously deferred
models: 2,697 Original models / 40,455 images and 3,511 EX models / 52,665
images pass with zero deferred models. The GPU tests the original centre's
front flag before applying per-face movement, then clips/rasterizes the moved
sprite normally. Projection tests include valid, behind and invalid-index
single-point gates; all 393,987 native cases and continuous regressions pass.

Fractional destruction is now implemented in the diagnostic path, but is NOT
parity-complete. Each face uploads four compensated vertex poses plus two
unscaled normal records. The GPU uses source Q15 normal rounding when the
authored pose requests it, otherwise fractional rotation; fragment offsets are
added before projection. Sprite pre-offset gates work in both transform paths.
The first 64 Original models pass 3,840 images across six views and scales 1/2.
The complete Original sweep finds KICHI_1 view 5 / scale 2 / progress 1 failing:
15 indexed-pixel differences and surface depth 814.933472 away from the expected
1510.400024 at pixel 72336 (normal matches). This must be resolved before live
promotion. Reproducer: `starfox_gpu_model_check SF.SFC SYMBOLS.TXT 1
--destruction KICHI_1`. Projection regressions and a 64-model ordinary EX
rendering sweep pass. The complete EX sweep also finds FACE_B view 4 / scale 1 /
progress 1 with a write-coverage mismatch at pixel 112; its ordinary polygon
rendering passes all 12 images. Both failures are specific destruction
regressions, not grounds for relaxing the comparison. Full live gameplay
coverage remains unproven.

The `--destruction-faces` diagnostic now isolates these failures without BSP or
overdraw. EX FACE_B fails on face 2 (normal -127,0,0; X=30; model shift 4).
At yaw 90 degrees its nominal depth is 512-30*16=32, and progress 1 contributes
-32, placing the face at the zero-depth cancellation boundary. Original
KICHI_1 isolates to face 19 (normal 0,0,-127), view 5 / scale 2, coverage pixel
72335. Quantizing compensated residuals before/after offset addition did not
resolve either case and was removed. Next diagnosis needs source-operation-order
camera/projection comparisons, especially zero-depth cancellation; do not add
an arbitrary epsilon or relax pixel/surface checks.

FACE_B is now fixed: rounding the compensated rotation before translation,
then translation before fragment addition, preserves the source's binary64
cancellation. All four fixture depths now match exactly at +/-5.684341886e-14
(previously +/-3.117339e-14 or +/-3.810081e-14), and its full 60-image destruction
suite passes. This is an asserted camera regression in gpu_projection_check,
not only a printed diagnostic. KICHI_1 still fails unchanged and remains the
next fractional-destruction blocker; no live promotion has occurred.

KICHI_1 subsequently passes all 60 images too. Its isolated face 19 has a source
projection X of 116.74999999999999; narrowing to float 116.75 changed the 2x
integer vertex from 233 to 234. Destruction projection now preserves the side
of binary64 results at the supported 1x/2x/4x rounding boundaries when narrowing
to float. FACE_B remains passing. This does not establish full-catalog parity:
the expanded 4x sweep is pending. The test readback allocation was also extended
to fit 4x destruction output (previously sized for at most 2x outside billboards).

The 64-model Original regression now passes 5,760 images at 1x/2x/4x. Both
previously failing models independently pass all 90 images including 4x.
CPU-left/GPU-right diagnostic-palette captures were generated and visually
inspected at the failing poses:
`tmp/gpu-destruction-kichi-fixed/model-45983-face-0-layer-0-mode-0-view-5-scale-2.bmp`
and `tmp/gpu-destruction-face-b-fixed/model-44110-face-0-layer-0-mode-0-view-4-scale-1.bmp`.
These are model-render comparisons, not in-game photographic proof. A synthetic
face-packing regression also verifies destruction bypasses source visibility
without changing materials/corners and normal visibility returns afterward.

Live follow-up: `check_gpu_native.ps1 -Geometry -Resident -Bomb` at 200 and
1000 preroll ticks ran GPU model batches, but both failed the explicit bomb-disk
coverage gate. Logs are in `tmp/live-gpu-destruction-bomb-200` and
`tmp/live-gpu-destruction-bomb`. Do not count these as bomb/destruction parity
proof. The scripted X/A presses must first be shown to trigger a bomb in the
chosen saved-control/game state. Full 1x/2x/4x catalog sweep remains in flight.

The expanded Original sweep stopped on KICHI_0 view 0 / scale 4 / progress 2
(surface palette at pixel 589719). Face isolation found face 34, a quad crossing
the viewport edges. Enabling the existing compensated projection/clipping path
for matrix-based fractional fragments resolves it: KICHI_0, KICHI_1 and EX
FACE_B each pass 90 images. Euler fragments retain their compensated screen
path. The concurrent EX catalog run predates this latest change and must not
be described as validation of it. Future sweeps print progress every 128 models.

Bomb diagnostic follow-up: test-only input logging confirms X/A pressed masks
64/128 reach logic ticks, but SPECWEPCNT remains 3->3 at 200/400-tick checkpoints.
Configurable test hold length (`STARFOX_TEST_PRESS_FRAMES`, default 3, clamped
1..240) was added; the bomb check now holds 12 presentation frames. This still
does not exercise the disk (`tmp/live-gpu-bomb-long-press`), ruling out short
holds as a sufficient explanation. No bomb parity claim is made; inspect the
player strategy/control gate next rather than weakening the coverage assertion.

Live bomb coverage now passes using a playable asteroid checkpoint and enough
time for detonation: `check_gpu_native.ps1 -Level LEVEL1_2 -Geometry -Resident
-Bomb -Ticks 200 -Frames 360 -OutputDirectory tmp/live-gpu-bomb-asteroid-360`.
All 1x/2x/4x runs report resident GPU geometry and the GPU bomb disk; final
indexed captures match CPU rendering exactly, with no geometry fallback gate
failure. Corneria's earlier checkpoint retained source no-fire flags (96),
whereas LEVEL1_2 had flags 0. The 120-frame asteroid run was simply too short
to reach disk detonation. SPECWEPCNT alone is not a firing assertion because
cheats may replenish it. This verifies execution plus final-frame parity,
not per-frame bomb animation parity or proof of exploded models in that scene.

The same LEVEL1_2 / 200 ticks / 360 frames check also passes for EX at 1x/2x/4x:
`tmp/live-gpu-bomb-ex-asteroid-checked`. All three logs verify resident model
geometry and GPU bomb disks; final CPU/GPU indexed images match exactly.
Test-only input diagnostics now tolerate missing Original symbol names in EX
instead of indexing an empty symbol result. These runs do not change release
defaults or establish full-level/full-animation parity.

The older EX catalog run finished with KICHI_3 (progress 127, view 1, 2x)
failing at coverage pixel 92936. The current matrix-fragment clipping change
already fixes that case: all 90 KICHI_3 images pass. Both older full runs are
terminal failures, not still-running checks or complete catalog validation.

Axis-collapse prerequisite: `pack_axis_groups` identifies all maximum/minimum
authored-Z indices in source order for the selected animation frame. It does
not average object-space vertices (which would violate native wrapping) or
enable the unsupported axis path. Empty, tied, mixed word/byte and animated
fixtures pass, plus group membership/order checks across 3,931 Original and
5,447 EX frames. GPU camera-space averaging and line integration remain needed.

Axis camera averaging now has a Vulkan/Metal compute stage and borrowed-output
enqueue API in GpuProjection. It reads native camera words or fractional camera
floats and source-ordered index ranges, returning two float4 centres with explicit
validity. Empty, out-of-range and invalid-camera groups cannot emit a valid
centre. GPU fixtures pass native/fractional cancellation, singleton, empty,
invalid-index and invalid-camera cases, along with prior projection regressions.
Shader generation/staleness checks include this stage. Groups over 65,536 indices
are explicitly invalid to bound serial reduction work. This is not yet connected
to model clipping/line emission; broad source-average parity is still unproven.

Expanded axis reduction validation passes 50 native/fractional cases, with
3/64/1023/65535/65536-member groups. Means match the float-converted double
reference exactly for these fixtures; empty groups, invalid indices, invalid
camera flags and out-of-range ranges stay invalid while the other group remains
correct. Cancellation fixtures retain the small term between +/-16,777,216.
This establishes bounded reduction behavior, not yet complete axis rendering.

The reduction API is now `enqueue_axis_points`: it returns two
ContinuousProjectedPoint records, with fractional camera/screen positions and
validity/front flags. This allows the following clip stage to consume the result
without readback. Sixty GPU cases pass, including zero and negative mean depth;
projection agrees with the double reference within the stated numerical test
tolerance. Native input still receives fractional projection here; source-word
axis clipping/projection and model-level line emission remain to be connected.

Continuous axis model integration now connects transformed extrema -> GPU
averaging -> near/screen clipping -> line rasterization without readback. It
bypasses BSP, uses the first source face's colour without its texture, ignores
destruction offsets, and emits no surface metadata, matching the source's axis
branch. Wireframe thickness 1–4 and render scales 1/2/4 are exercised. The first
64 models of each variant pass 960 images each with exact indexed pixels, tags,
and absent surface metadata; an ordinary 64-model Original regression passes
768 images. Full-catalog axis sweeps are running, not yet passing claims.
Source-word axis rendering remains explicitly unsupported; native-camera
reduction fixtures do not establish native line clipping/projection parity.

### First live model-geometry integration (diagnostic only)

Expanded live checks now accept `-Level`. Original LEVEL2_1 and LEVEL2_3 pass
the geometry/no-fallback gate and exact final native/presentation capture
comparisons at 1x/2x/4x (200 source ticks, 60 presentation frames). Artifacts:
`tmp/live-geometry-level2-1` and `tmp/live-geometry-level2-3`.
LEVEL3_4 initially failed on a whole-object sprite at shape address 39292
(`tmp/live-geometry-level3-4-detail`). That primitive now uses a dedicated GPU
row-span generator: compensated projection/rounding, source depth cutoff,
240-pixel size clamp, original texture selection, colour override, transparency,
2D layer tagging and horizontal effect clipping. No billboard projection or
scan conversion runs on the CPU; CPU work selects/uploads the authored texture.
The new `--billboard-batch` comparisons cover 64 textured models per version,
six boundary/clip poses and 1x/2x/4x: all 2,304 images match the software renderer
in pixels, tags, coverage and surface ownership. Nontextured models are filtered
from this dedicated test, not treated as failed or passing billboard cases.
LEVEL3_4 now passes the live no-fallback gate and exact final native/presentation
comparisons at all three scales (`tmp/live-geometry-level3-4-billboard`); the 2x
presentation capture was visually inspected. This is a bounded checkpoint test,
not proof of the full stage or every floating-point input. Exploded geometry,
colour warp and other remaining effect paths still need migration.

Model rasterization can now merge its background in the same compute dispatch,
removing the extra full-image merge for model layers. Two alternating model
instances prevent input/output aliasing; explicit validation rejects aliased or
mismatched backgrounds. Legacy raster layers retain the separate merge. A
non-surface foreground still preserves earlier surface metadata, including
when it paints black. `STARFOX_TEST_SEPARATE_SCENE_MERGE` retains the comparison
path. Generated Vulkan/Metal shader layouts now include the background inputs.

The expanded `--queued-batch` test alternates mixed and model-only five-layer
scenes and passes 3,072 Original/EX comparisons, each preceded by four changing
unread submissions. Three live 600-frame merge-comparison pairs also have
identical final presentation captures (`tmp/scene-fused-current-proof`). Median
times (separate/fused, us): 4402/4017, 5273/4838, 5271/4425. All improve, but the
third baseline has a 130517-us maximum and inflated background/composite CPU
times, making it unsuitable for a strong frame-pacing conclusion. The new
geometry path remains diagnostic-only, not a completed/default migration.

The scene queue now retains at most two older submissions plus the current
one, using cycle-enabled storage and waiting only to enforce that bound or
explicit completion. Borrowed enqueue remains prohibited while owned work is
pending, including retired fences. `STARFOX_TEST_SERIAL_SCENE` retains the
serialized diagnostic baseline.

`--queued-batch` passes 3,072 Original/EX compared frames, each preceded by four
changing unread submissions. Indexed pixels, tags, write coverage and surface
metadata still match the CPU reference. The live benchmark in
`tools/benchmark_scene_queue.ps1` ran three alternating-order 600-frame pairs
(Original LEVEL1_1, 200-tick preroll, 16:9, 2x, 240-Hz unpaced presentation).
All final presentation pairs match, with resident geometry required and no
geometry-fallback logs. Median-of-run-medians improves 5,669 -> 5,070 us (10.6%);
all three paired medians improve. The worst observed frame increases from
22,556 to 25,754 us. Much of the world-stage wait moves to presentation, so this
is not proof of consistently better latency or GPU execution time. Artifacts:
`tmp/scene-queue-current-proof`. Broader frame-pacing work remains.

`STARFOX_TEST_GPU_GEOMETRY=1` now routes live ordinary models, native shadow
models and upgrade overlays through ordered recording and resident GPU geometry.
The default renderer is unchanged. The window consumes the batch output for
resident composition/effects; unsupported batch encoding replays the complete
frame. CPU-only transition/overlay composition also uses ordered replay for now.
Models collecting the hardware-ray-tracing scene still use the existing CPU
geometry path, and the separate Controls panel is not yet migrated here.

`tools/check_gpu_native.ps1 -DefaultPipeline -Geometry -PresentationCapture`
checks that actual deferred models were submitted, rejects geometry-fallback
logs, and compares both final indexed/native and final presentation captures.
Initial Original/EX LEVEL1_1 runs after 200 source ticks, over 60 presentation
frames at 1x/2x/4x, pass all six paired final captures. This compares final
captures, not every intermediate frame or every game state. An Original 2x
presentation capture was visually inspected. Artifacts are in
`tmp/live-geometry-original-first` and `tmp/live-geometry-ex-first`.

Initial isolated timings expose a substantial low-resolution Original cost;
this is not ready to enable by default. Multi-model dispatch overhead, queued
submission, unsupported effects, other live flows and ray-tracing integration
remain work. No broad FPS improvement or completed migration is claimed.

### Ordered mixed-draw batch API

`GpuSceneRecording` now splits legacy raster work at deferred model boundaries,
retains each chunk's texels, and exposes ordered draws for GPU submission. It
also provides full CPU replay without clearing intervening layers. Replay
initialization clears coverage rather than treating the background clear as an
opaque black write; the caller's framebuffer draw scale is restored afterward.
`--recorded-batch` passes 3,072 Original/EX images through recording, submission
and comparison, with a separate exact CPU replay check of pixels, layer tags,
write coverage and surface samples. Live diagnostic adoption is described
above; unsupported-effect replay and heterogeneous-scale recordings need
dedicated coverage beyond these ordinary-model cases.

Owned submission is now available through `GpuScene::render_resident`, with a
borrowed resident output for presentation and fence-only completion. Pending
owned work rejects borrowed writes without invalidating its output; failed
encoding cancels the owned command and exposes no partial resident frame.
The initial serialized implementation has been replaced by the bounded scene
queue described above; default-on presentation remains outstanding.
The `--submitted-batch` checks pass another 3,072 Original/EX images through
the owned submission path, including protected pending work and retained
buffers after fence completion. No performance improvement is claimed.

`GpuScene::enqueue_batch` now owns the model/raster/intermediate merge resources
and encodes an ordered list of model and legacy raster draws into a caller-owned
GPU command buffer. It validates output dimensions, preserves black-write
coverage and independent surface ownership, and clears empty batches. Callers
must cancel the command on failure, including a failure after earlier layers
were encoded. This is sequential painter composition, not a single parallel
dispatch for all models.

`starfox_gpu_model_check ... 128 --mixed-batch` passes for Original and EX:
3,072 total compared images across six poses, two scales and five interleaved
layers. Indexed pixels, layer tags, coverage and surface palettes are exact;
maximum normal error is 1.19209e-7 and maximum depth error is 0.00012207.
Empty-batch clearing, invalid raster dimensions and cancellation after four
encoded layers are exercised, followed by successful reuse of the resources.

The live game's diagnostic adoption is described above; these component tests
alone do not establish live GPU geometry completion or an FPS gain.

### Current Windows ray-tracing verification

The current rebuilt Windows game executes hardware DXR 1.1 on the NVIDIA
GeForce RTX 5070 Ti Laptop GPU. Fresh 60-frame presentation checks verify:
ray tracing changes the rendered image, the removed Enhanced Shadows override
has no effect, and requesting ray tracing with DXR forced unavailable produces
the exact ray-tracing-off/native-shadow image. The unavailable case also rejects
any replacement-shadow backend log. GameSimulation and saved-setting defaults
remain false; the native silhouette pass is gated off when hardware shadows
are active. This does not prove every scene or runtime/device-loss fallback.

Off/DXR captures were visually inspected. Four-way current-build proof:
`tmp/ray-tracing-current-proof/82fe35dd8413452395eb32e2dbe93eec`.
`tools/check_ray_tracing.ps1` now isolates/restores caller diagnostic environment
variables, validates its frame limit and exercises the unavailable case. No
Quest ray-tracing support or GPU frame-rate improvement is claimed here.

### Live resident raster submission overlap

The existing live `render_resident` path no longer unconditionally waits for the
previous raster fence before recording the next frame. It retains at most two
previous submissions plus the current one, retiring completed fences and waiting
on the oldest only when necessary to bound queued work. Uploads, pixel/surface
outputs and first-stage GPU-bin scratch now cycle on reuse. Explicit CPU capture,
completion requests and destruction still wait and release all retained fences.
Caller-owned enqueue APIs reject outstanding owned submissions, including retired
ones. This does not migrate the live model transform stage by itself.

The Windows `starfox_pc` target rebuilds successfully. All 168 raster parity cases,
the 768-image mixed recovery check and a new 32-unread-submission stress test pass.
The latter changes dimensions, switches bins and validates the final pixels and
surface depth after repeated queue wraps. No in-game FPS improvement is claimed
without an appropriate before/after gameplay benchmark.

The subsequent same-binary Windows live-path A/B benchmark completed five
alternating-order pairs of 1,200 frames (60 warm-up frames), Original LEVEL1_1,
16:9, 2x rendering, hidden/unpaced at a requested 240 Hz. All five final capture
pairs are byte-identical. Median-of-run medians fell from 1,088 to 786 us;
median-of-run p95 from 2,199 to 2,057 us; p99 from 4,248 to 2,997 us. Four of
five paired medians improved, but the worst queued outlier was 10,120 us versus
6,120 us serialized. Keep bounded queuing provisionally, not as a guarantee of
better worst-case latency. These are CPU render timings, not GPU timings,
displayed FPS, input latency or Quest results. Settings were inherited equally
by both modes. Logs and captures: `tmp/raster-queue-long-proof`; reproduction:
`tools/benchmark_raster_queue.ps1 -Frames 1200 -Repeats 5`.

### Mixed legacy/model command-buffer handoff

Failure ownership checks now run before `--mixed-scene`: an enqueue while a
submitted raster fence remains owned is rejected; the caller can still cancel
its separate command and finish the existing submission. Zero-width input is
also rejected without cancelling the caller's command. Subsequent five-layer
rendering passes 64 EX models / 768 images using that same raster instance,
checking recovery rather than creating a fresh instance after failure.

Repeated-use extension: `--mixed-scene` now submits five ordered layers on one
command buffer: GPU model / legacy black non-surface / GPU model / legacy
surface-bearing / GPU model. The two legacy submissions switch CPU/GPU binning
within the same command buffer, exercising uploads, bin scratch, output cycling
and surface-buffer growth from absent to present. 128 Original + 128 EX models
pass 3,072 images; the separate FOXGUY run passes 12 more. Its CPU-left/GPU-right
capture at `tmp/gpu-mixed-five-layer-proof/model-42467-face-0-layer-0-mode-0.bmp`
was visually inspected (diagnostic palette). The larger 42,132-image result below
is from the earlier three-layer version, not this expanded five-layer suite.

`GpuRaster::enqueue_commands` uploads existing raster commands on a caller-owned
SDL GPU command buffer. It does not submit, fence, wait or read back. Upload and
output buffers cycle for deferred reuse; GPU-bin scratch cycles only at its first
stage. Caller-owned commands are detached on errors and must be cancelled by the
caller. Existing pending submitted work is rejected rather than implicitly waited.
Ordinary CPU/GPU-binned output now optionally carries explicit bit-26 coverage,
including black writes, for GpuScene merging.

The new `--mixed-scene` diagnostic interleaves a GPU model, legacy recorded-model
commands and another GPU model before one submission. It alternates CPU/GPU bins
and checks colours, coverage, tags and independent metadata. Initial 64 EX models
(768 images) pass, as do all 168 existing raster cases and deferred-output tests.
The full EX mixed scan also passes all 3,511 headers / 42,132 images with no
empty-model exclusions. Max normal error is 1.19209e-7, depth error 0.000244141.
This is a necessary handoff for live particles/text/unsupported model effects;
the app has not yet adopted the mixed queue. Per-model batching and performance
still need work; no live-game speedup is claimed here.

### Empty model results remain GPU resident

GpuRaster now accepts zero row-span primitives and clears pixels/surface ownership
without a command upload. GpuModel uses this for empty selected geometry, avoiding
an error or stale output. Null spans remain invalid for nonempty batches, and
output-alias checks distinguish null from an actual output buffer.

The default diagnostic no longer skips empty models: all 2,697 Original and 3,511
EX symbol-header models pass six poses at 1x/2x (32,364 / 42,132 images), including
empty coverage and layer tags. A 64-model EX three-layer check also passes. These
are ordinary-mode tests of symbol headers, not exhaustive runtime LOD reachability
or completion of wave/explosion/other unsupported pose effects.

### Inspectable model comparison captures

`starfox_gpu_model_check` accepts a capture directory after a named model. For
view 4 at 2x it writes CPU-left/GPU-right comparison BMPs per mode; all numerical
checks still run. Filenames use numeric model/face/layer/mode IDs. The palette
is the diagnostic preview palette, not a claim of source CGRAM colour parity.

`tmp/gpu-model-foxguy-proof/model-42467-face-0-layer-0-mode-{0,1,2,3}.bmp`
contains cel, wireframe 1/2 and sparse wobble-2 three-layer comparisons. All four
were visually inspected; all 48 named-model cases pass exact pixels/coverage/
tags/surface ownership. These captures document the diagnostic geometry path,
not integration into the flat game or Quest application.

### EX sparse wobble mode 2

GPU spans now implement the source's mode-2 suppressed fill: only a continuing
right edge emits one pixel at the previous left X. The initial row and right
edge restarts remain empty. It takes precedence over cel/wireframe, while
textured polygons, lines and sprites retain their original behavior.
Wobble modes with bit 0 set still reject: their repeated-row emission requires
a separate path. Wave, explosion and order-dependent colour warp remain pending.

The expanded four-mode suite passes 40,128 EX single-model images and 26,448
Original three-layer images, covering six poses at 1x/2x per mode. Colours,
coverage, tags and surface ownership match exactly. Packing tests verify mode-2
flags, unaffected textures/lines and rejection of mode 1. Native/fractional/near
clip regression and generated shader consistency checks pass. This is Windows
Vulkan diagnostic evidence, not live gameplay or Quest validation.

### Shifted FOXGUY precision regression resolved

Model packets now upload low coefficient/translation residuals beside the two
existing byte/word poses. The continuous shader uses compensated products, sums
and division through final projection under strict IEEE compilation (`-Gis`).
The model clip stage consumes that screen result instead of reprojecting rounded
camera coordinates. This needs no float64 shader support and does not change CPU
projection or introduce endpoint bias. The original FP32 interface remains for
callers without the residual opt-in. Camera output is still FP32: exhaustive
near-plane and visibility precision is not established by this change.

The formerly failing `--alternate-scene FOXGUY` passes all 36 images. Expanded
three-layer suites pass 19,836 Original and 30,096 EX images (all three modes,
six poses, 1x/2x), with exact pixels, coverage, tags and surface ownership.
Normal error <=1.19209e-7; depth error <=0.000244141. Coefficient reconstruction
unit tests and existing 262,658 native/131,329 continuous projection checks pass.
Generated shader consistency and diff whitespace checks pass. Windows Vulkan
execution only; no live-game integration, Quest validation or speed claim yet.

### EX cel and wireframe span modes

Expanded audit: `--alternate` now runs all three modes at all six poses, and
`--alternate-scene` adds three-layer overlap. Fractional translation now adds to
the shifted pose instead of accidentally replacing it. Original passes all
19,836 layered images. EX finds `FOXGUY`, wireframe mode 1, view 4, scale 2,
coverage pixel 118524; the named `--alternate-scene FOXGUY` reproduction fails,
while unshifted `--alternate FOXGUY` passes all 36 images. Cause is not yet proven;
retain this failing case. Earlier passing counts below cover the narrower suite.
CPU raster-command replay now honors edge-only spans too, with a direct clipped
endpoint CPU/GPU fixture in the raster command diagnostic.

Isolation update: `--alternate-layers FOXGUY` reproduces on layer 1 without
composition; `--alternate-faces FOXGUY` isolates face 116 (vertices 152,151,147),
also visible in cel mode. `starfox_euler_precision_check ROM SYMBOLS FOXGUY
--shifted` shows vertex 147 Y=146.74999176524639 in the CPU calculation versus
146.75 after FP32 transform/projection, yielding 2x rounded Y=293 versus 294.
This is not a scene merge bug. Fix requires retaining more transform/projection
precision through quantization; do not bias all endpoints with an epsilon or
change the CPU reference. Isolated-layer runs now test each of the three poses
separately, rather than inspecting only the final layer.

GPU spans now implement source cel endpoint removal and both EX wireframe modes,
including mode 2's left-only edge continuation state. Edge-only spans retain their
original endpoints through viewport clipping, avoiding invented border edges.
Texture polygons, lines and sprite faces keep their original unaffected behavior.
`--alternate` tests cel and wireframe 1/2 across six poses and 1x/2x: 6,612 Original
and 10,032 EX images pass with exact colour, write coverage, layer tags and surface
ownership. This tests two poses per mode, not every mode/pose combination.

Explosion migration remains open: its per-face normal rotation/expansion happens
after shared vertex transformation, disables face visibility/BSP, and must also
feed clipped geometry and surface depth. It needs a dedicated expanded-camera
stage; merely changing shared vertices would be incorrect. Wave/wobble and
order-dependent colour warp also remain unsupported in GpuModel.

### GPU sprite-face emission

Sprite faces now use resident projection, visibility, BSP order and row-span
emission. Source depth sizing, 16-bit texture-coordinate wrap, transparent texels,
logical-pixel scaling and 2D layer tags are preserved. They do not replace surface
metadata underneath. Invalid multi-corner sprites remain empty, matching the CPU.
Whole-object `simple_scaled_sprite` and EX alternate effects remain pending.

Expanded real-model tests pass 6,612 Original images (551 models) and 10,032 EX
images (836 models), six poses at 1x/2x. Three-layer composition passes the same
16,644 images with exact colours, write coverage, layer tags and surface ownership.
The diagnostic now verifies coverage and tags directly, including black writes
and transparent holes. Packed-face unit tests and native/fractional/near clip
regressions pass. Generated SPIR-V/Metal were rebuilt; execution was Windows Vulkan.
The live app still uses CPU-generated raster commands: these model stages are not
yet wired into live rendering, and this is not a playable Quest 3 build.

### GPU line primitives; expanded mixed-model regression

Native and continuous clip stages now accept ordered two-corner lines, including
near clipping. Native clipping uses the source's signed-word inside anchor;
continuous lines use parametric screen clipping. The span emitter implements
source major-axis stepping with strict-underflow ties, scaled square thickness,
and dither. Monotone line coverage is accumulated into row spans. Lines retain
pixel ownership without replacing surface metadata. Textured line materials
follow source line colours while retaining the behind-camera rejection rule.

`--lines-only` checks extracted lines from 146 Original and 196 EX models over
six poses and 1x/2x, exercising thickness values 1–4. All 4,104 images match
SoftwareRenderer exactly (1,263,775 / 1,646,017 nonzero pixels); surface metadata
remains empty as expected. Polygon clipping regressions and face-packing tests
still pass. Sprite emission remains unsupported.

Expanding the **full** model scan to mixed polygon/line models finds a previously
untested filled-face mismatch in `DEBOSS_0`, view 1, scale 2 (surface pixel 44841).
It reproduces with `--polygons-only`, independently of line emission. This case
remains in the default diagnostic. It is now resolved: isolated face 1 has an
exact projected Y=50.25, but GPU division precision moved its 2x rounding
boundary. Model clip packets now request compensated camera projection and
preserve the residual through screen clipping. No CPU reference changes.

The new `--face-scan DEBOSS_0` diagnostic checks all 18 faces independently:
216 images pass. Full mixed-model scans pass 6,240 Original images (520 models)
and 9,372 EX images (781 models), six poses at 1x/2x. Pixel colours and surface
coverage/palettes match exactly; max normal error 1.19209e-7, depth error
0.000244141. Existing native/fractional/near clipping regressions also pass.
These remain diagnostic GPU paths, not proof of live renderer or Quest readiness.
The three-layer resident composition variants also pass all 15,612 images,
including black writes, independent surface ownership and ping-pong reuse.

### Shifted Euler visibility regression resolved

The IRIS failure was a collinear source visibility triple: vertices 26, 27 and
1 are (0,-2,0), (0,-1,0), (0,-60,0). The source camera-space determinant is zero;
independently rounded FP32 camera points produce 0.010185376, above the unchanged
0.000134217728 tangent tolerance. Rounded screen endpoints still agree: this
was visibility input quantization, not a pixel-rounding or scene-merge failure.
`starfox_euler_precision_check` records the numerical comparison.

Packing now marks exact source-word collinearity only for continuous triples
sharing the same scale/transform. The GPU preserves that affine invariant after
validating camera indices/validity. Native word transforms retain their existing
rules; mixed-scale triples and wider caller-provided coordinates stay on the
general path. Neither the CPU oracle nor the culling tolerance was changed.

The full default and `--scene` diagnostics now pass all six views, including the
shifted Euler case: Original 4,488 images and EX 7,020 in each run (11,508 single
model images plus 11,508 three-layer images). Indexed pixels, surface coverage
and palette ownership are exact; normal/depth error maxima remain 1.19209e-7 /
0.00012207. Projection/visibility regression and packing unit tests pass, including
collinear flags with invalid indices. Live scene integration is still pending.

### Resident multi-model painter merge; Euler regression discovered

`GpuScene` merges model layers on-device using ping-pong buffers. GpuModel now
marks explicit pixel coverage in packed bit 26, including black writes. Scene
merging keeps colour and surface ownership independent, so a later non-surface
draw does not erase the prior normal/depth sample. No intermediate scene
readback/upload is needed. Existing raster callers retain their old layout
unless row-span pixel coverage is explicitly enabled.

The `--matrix-scene` diagnostic isolates Q15/fractional-matrix poses: three
overlapping draws per image, including a black non-surface middle draw. Original
passes 2,992 images and EX 4,680, with exact pixels, surface coverage and palette
ownership. Normal/depth error bounds are unchanged. Clipping/raster regressions
still pass. This is not yet live game composition or a batching optimization.

**Regression found during this stage (now resolved above):** the expanded default/full `--scene` diagnostic
finds a coverage mismatch for Original `IRIS` in a shifted Euler pose. The same
failure reproduces without GpuScene (new view 5: yaw 16384, pitch 8192, z 512,
x 11, y -4, continuous geometry, scale 1), so it is upstream of merging. The
unshifted Euler fixture passed earlier; that evidence did not cover this case.
The full diagnostic retains this regression case and now passes it.
`--matrix-scene` remains optional isolation coverage, not a replacement for the
full parity check.

### GPU surface normals and depth

`GpuModel` optionally generates surface material metadata on-device using the
resident camera vertices. The new `surface_portable` stage preserves the source
distinction between word-exact and fractional normal transforms, independently
of geometry interpolation, and computes mean face depth before clipping.
Normals are normalized on the GPU; default normals and invalid-face rejection
are preserved. No CPU-transformed normals or per-face depth readback is needed.

Real-model diagnostics now compare indexed pixels, surface coverage, palette
ownership, normals and depth against SoftwareRenderer over five views (including
fractional normals and Euler poses), at 1x/2x. Original: 374 models / 3,740 images;
EX: 585 / 5,850. All pixels, surface coverage and palette ownership match exactly.
Maximum component normal error: 1.19209e-7; depth error: 0.00012207 source units.
SPIR-V executes on Vulkan; generated Metal remains hardware-unverified.
This supplies metadata for subsequent effects integration; live effects/RT
consumption of this new model path is not yet connected.

### End-to-end real polygon model pipeline

`GpuModel::enqueue` now packages decoded model data and chains GPU transform,
projection, visibility, BSP order, near/screen clipping, span generation and
rasterization on one caller-owned SDL command. No intermediate readbacks or
CPU-generated raster commands are required. Native camera output is passed
directly into near clipping. The first real-model checks exposed byte-addressed
texture storage incorrectly expanded to uint32 texels; storage is now bytes,
with aligned padding for shader loads.

`starfox_gpu_model_check ROM SYMBOLS 0` compares complete indexed images with
SoftwareRenderer for three views/depths (including near crossings), at 1x and
2x with fractional translation. Original: 374 eligible models / 2,244 images /
33,746,029 nonzero pixels. EX: 585 / 3,510 / 54,413,263. All compared images are
exact. This is 959 symbol-discovered polygon-only models, not all game models:
2,323 Original and 2,926 EX empty or line/sprite-containing models are deferred.
The diagnostic uses frame zero and selected poses, not exhaustive animation,
effects, gameplay states or Metal verification.

This renderer is standalone and clears its output. Live scene composition,
mixed primitive emission and game integration remain. It
currently repacks/uploads data per call and retains CPU material selection and
native prescale; caching/batching and those GPU conversions are still needed.
Do not treat this as completed migration or measured in-game FPS improvement.

### Face/material packaging

`pack_faces` now creates BSP-indexed corner/descriptors, material templates and
deduplicated texture storage. It preserves palette wrapping/overrides, dithering,
animated material selection through the shared material decoder, UV order,
texture scrolling, and 2D/textured-geometry layer tags. Unculled faces consume an
unconditional visibility entry appended by `pack_projection`; both GPU visibility
shaders implement and test that entry even with invalid vertex indices.

Asset packaging passes 2,697 Original models (7,052 polygons, 808 lines, 31
sprites) and 3,511 EX models (18,656 polygons, 1,231 lines, 55 sprites). These
counts use packed face batches rather than double-counting flattened BSP faces.
Lines and sprites are explicitly classified and flag the package as not
polygon-only; this does not implement their GPU emitters. Alternate modes and
explosion offsets reject pending dedicated handling. Surface metadata and
order-dependent colour-warp generation are also unfinished. Material selection
still runs on the CPU; this is not the final all-GPU state.

Visibility regression passes 262,658 native and 131,329 continuous cases after
adding unculled entries. Real-model end-to-end pixels and live integration remain.

### Model vertex/pose packaging

`pack_projection` selects the animation frame and packages vertices, visibility
triples and poses for `GpuProjection`. Continuous byte/word vertices select
separate scale matrices; word coordinates ignore both pose scale and header
shift, including EX word-only models with otherwise invalid shift bytes.
Native Q15 input retains source rounding and word wrapping. Per-vertex rotation
and projection are not performed by the packer. Native prescale/quantization is
still CPU-side; continuous scaling is encoded in GPU matrices. Continuous Euler
and Q15 poses are supported; other projection/visibility combinations explicitly
reject pending their matching paths.

CPU packaging tests pass all 3,931 decoded Original animation frames and 5,447
EX frames (2,697 / 3,511 models). Unit fixtures cover half rounding, wraparound,
mixed word/byte scaling, frame selection, Euler quarter-turn orientation,
invalid input and ignored word-only shifts. This is packaging evidence, not
yet real-asset end-to-end GPU pixel parity or a live game integration claim.

### Decoded model BSP packing and GPU asset coverage

`pack_bsp` converts decoded address-based graphs into owned, model-local GPU
nodes and face IDs. It preserves leaf-before-node precedence, first duplicate
address wins, missing batches/links, active-path cycle suppression, shared
subtree visits and flat explosion order. It computes conservative output/work
bounds and rejects graphs deeper than 64 or larger than the supported limits.
Face indices include lines/sprites so later geometry emitters can share them.

`starfox_packed_bsp_tests ROM SYMBOLS` compares packed traversal to a separate
address-based source oracle for 16 visibility patterns and explosion order:
2,697 Original and 3,511 EX decoded models pass. `starfox_gpu_bsp_check ROM
SYMBOLS` then executes the packed graphs on Vulkan: 43,280 Original and 56,304
EX trees pass (each includes 128 synthetic cases), with failure handling and
resident order-to-raster reuse checks still passing. Observed maximum graph
depth is 14 Original / 18 EX; conservative face-output bounds are 68 / 254.
This covers symbol-discovered decodable headers, not every runtime LOD route,
every possible visibility combination, Metal execution or live-scene imagery.

Model BSP packing is available but not yet called by the live renderer. Vertex,
material and primitive packaging, other emitters and game integration remain.

### GPU BSP painter-order stage

`bsp_portable.hlsl` implements the source recursive ordering with an explicit
active-path stack, consuming GPU visibility flags. Visible partitions emit
fallthrough, their own batch, then alternate; invisible partitions emit alternate
then fallthrough without their batch. Leaves preserve batch order. Shared
subtrees remain repeatable and cycles are skipped only on the active path.

`starfox_gpu_bsp_check` executes the Vulkan shader and compares 128 trees against
an independent recursive CPU oracle, including shared subtrees, cycles and
missing visibility indices. Four additional tests verify zero published count
on invalid batch ranges, output exhaustion, depth overflow and work exhaustion.
SPIR-V and Metal sources are generated; Metal hardware execution is unverified.
The current shader stack limit is 64; live asset packing must validate that
limit and handle failures, not silently render partial output.

`GpuBsp::enqueue` now exposes borrowed resident ordering/result buffers on a
caller-owned command buffer. `GpuClip::enqueue_spans` can consume one tree's
order directly, preserving duplicate face visits and generating empty rows for
unused slots or rejected trees. The diagnostic consumes these resident buffers
through clipping, spans and rasterization: the last source-ordered overlapping
face wins, coverage matches SoftwareRenderer, all four failed-tree cases draw
nothing, and subsequent successful reuse restores the expected pixels. The
diagnostic separately reads ordering for verification; the rendering interface
does not require that readback or a CPU-reordered list. Existing clipping,
texture, fractional and near-plane pixel regression tests still pass.

Live model-data packing/integration is still unfinished. These results are not
evidence of an in-game performance improvement or real-scene photographic parity.

The older notes below are chronological: native/fractional near clipping and
ordinary affine-texture span emission now have diagnostic coverage (see the
active delivery checklist). EX alternate emitters and live integration remain.

### GPU-generated solid commands reach raster output

`GpuRaster::enqueue_solid_spans` now consumes GpuClip's fixed row layout directly,
without CPU command staging or a binning pass. Projection, visibility, clipping,
span emission and rasterization execute in one caller-owned command stream.
The diagnostic verifies final pixels and tags against source painter composition.
The existing 168-case raster regression still matches pixels/tags/surfaces,
including textured, line and EX alternate-mode CPU-generated commands. This is
not yet the game's live geometry path; its texture/alternate emitters, BSP,
continuous/near clipping and command-space optimization remain unfinished.

### Resident native screen clipping

The diagnostic now also chains actual GPU projection and visibility directly
into clipping in one command buffer. Its 25,362 isolated/chained polygon cases
pass exact final XY/UV comparison; no intermediate projection or visibility
readback is used. Real-scene geometry and live draw-command integration remain.

`GpuClip` consumes caller-owned projected points, UV corners, polygon descriptors
and visibility flags and returns indexed-word clipped polygon data on the same
GPU command stream. It preserves inside-anchored division, left/right/top/bottom
order and exclusive right/bottom planes. `starfox_gpu_clip_check` passes 12,681
polygons with exact XY/UV output over 224x192, 398x192 and 796x448 viewports.
The diagnostic also tests invalid descriptors and scratch allocation reuse.
The current bounded interface accepts up to 32 input corners and reports invalid
input/128-corner scratch overflow explicitly. Asset-limit coverage, overflow-path
tests, continuous/near clipping, live chaining and integration remain pending.
This is not yet an in-game performance change or photographic parity proof.

### Resident native transform chain

The separate `enqueue_continuous` interface now generates fractional camera
and screen coordinates in one GPU dispatch. Shared pose matrices include scale;
the caller supplies focal length and vanishing point. Native-word visibility
cannot consume its result. A Vulkan test covers 131,329 fractional vertices,
zero/near/negative depth, invalid pose IDs and nonfinite coordinates against a
double-precision oracle. FP32 error in the +/-2048 screen region peaked at
0.000253176 source pixels for the tested dyadic inputs. This is not bit-exact
double parity or live-scene proof. Continuous visibility now chains on-device
using compensated FP32 determinant arithmetic and the CPU's 1e-12 tangent rule.
All 131,329 decisions match double arithmetic on the GPU-produced camera values;
ordinary FP32 disagreed on 37 cases. This does not validate rounding changes
from every original double pose. Live integration, clipping/BSP/command emission
and real-scene validation remain; no game FPS improvement is claimed yet.

`GpuProjection::enqueue_transformed` accepts pre-scaled source-word vertices
and shared Q15 poses, then dispatches transform and projection on the caller's
command buffer. Visibility consumes the result directly. No submission, wait
or readback is introduced between stages. Invalid poses are invisible instead
of reading out of bounds. The standalone Vulkan diagnostic passes 262,658
exact point/face cases across transformed and untransformed inputs. Metal is
generated, not hardware-verified. This does not yet replace the live CPU
transform/clip/BSP/command-emission path or its continuous high-FPS variant.

### Remove empty resident staging uploads

Unused storage-buffer slots now bind an existing valid read-only resource
instead of allocating and uploading four-byte placeholders. Bindings reset on
each apply, so switching overlays/shadows off cannot retain an earlier pointer.
Resident scenes without host overlay/shadow payloads now skip the staging map,
unmap and upload entirely (uniform push data is unchanged). Previously the two
empty auxiliary slots reserved 512 aligned staging bytes per such call.

The Windows hardware Vulkan and Linux lavapipe composite matrices verify zero staging bytes in all 108 resident
effects cases, while overlay, shadow, filter, split and allocation regressions
continue to pass. This removes CPU/driver work but is not an FPS measurement.

### Allocate optional effect textures on demand

SDL GPU no longer creates bloom snapshots/float intermediates, native filter
input or the layer-splitting target for a plain effects pass. Each is allocated
when first required, then retained until resize/device release to avoid toggle
churn. Unused shader bindings use the existing one-pixel read-only dummy.

At 400x224 logical / 4x render scale, a fresh plain pass uses 11,468,832 texel
payload bytes versus the previous eager 30,464,032: 18,995,200 bytes (62.4%) less.
This excludes buffers, capture/presentation targets outside that fixture, driver
alignment and metadata; it is not total process VRAM or an FPS measurement.
The allocation regression checks filter/bloom/overlay activation, cache reuse,
resize and release. Windows hardware Vulkan and Linux lavapipe
pixel/composite/split tests pass unchanged; the Windows runtime source compiles.

### Planet selection fades

The SDL GPU pipeline now implements isolated-selection and whole-level fades
before the cartridge window/shutter stages. Each subtraction independently
rounds RGB to five bits, clamps the fixed addend to 31, then expands back to
eight bits; alpha is preserved. Selection bounds are inclusive logical pixels.
The native presenter supplies this stage instead of falling back for fades alone.

Windows hardware Vulkan and Linux lavapipe pass 1,728 cases each through both resident and uploaded inputs,
covering 1x/2x/4x scaling, independent/combined fades, zero/full/out-of-range
amounts and selection edges. The desktop translation unit compiles. New in-game
captures and physical Metal testing remain outstanding.

### Resident planet and briefing overlays

Both ordered indexed layers now upload with their palette, then expand, filter,
subtract fixed white and composite on SDL GPU. Filtering uses the same six
choices as the main frame, including ScaleFX; each layer is reconstructed on its
own before composition. Filtered artwork retains source index-zero transparency
and alpha-weighted edge blending. Unfiltered artwork preserves palette alpha,
matching the previous desktop path. These passes precede fixed-colour effects,
planet isolation, shutters, lighting, bloom, menu ink and touch controls.

The native presenter no longer falls back solely for these overlays. Successful
resident submission emits `native-pipeline: GPU planet/briefing overlays` with
`STARFOX_TRACE_GPU=1`. Compact uploads reuse the auxiliary buffer; filtering and
final composition introduce no CPU RGBA expansion or intermediate readback.

Windows hardware Vulkan and Linux lavapipe pass 1,944 two-layer cases through resident and
uploaded inputs, with independent CPU subtraction/composition around the old
uploaded GPU filter path. Coverage includes all six filters, three render scales,
invalid indices, zero/partial/clamped brightness and overlapping layer order.
Nine full-size cases also match staged composition with fades, HDR, bloom, AA,
setup ink and touch controls. Deferred presentation leaves CPU pixels untouched;
explicit capture readback matches the reference. This is pipeline parity evidence,
not fresh in-game or physical Metal verification.

### Resident separated model presentation

The native presenter now supplies the existing GPU model-layer split directly
from resident composition instead of reading back the native raster when model
smoothing is enabled. The separate base/model/glow textures feed the existing
1440p SDL presentation target. Surface-bearing raster commands select the model
layer; the GPU's final coverage/index checks determine which pixels it owns.
Successful submission logs `native-pipeline: GPU separated model layer` with
`STARFOX_TRACE_GPU=1`.

Windows hardware Vulkan and Linux lavapipe pass 216 direct texture comparisons
against the uploaded GPU path, with and without bloom. Tests download the actual
base/model/glow targets, not only the unsplit screenshot capture. An independent
CPU reference additionally verifies ownership, opaque model alpha and ordered
neighbour edge filling in 108 no-bloom cases, across scales, offsets, mosaic,
clipping and same-colour foreground coverage. Deferred calls leave CPU inputs
unchanged. The Windows runtime translation unit compiles; final SDL target/window
visuals, physical Metal and new game captures remain unverified.

### Geometry preparation optimization

Model drawing now transforms/projects only the geometry actually used by
rasterization, visibility, BSP ordering and shadow casters. The previous
continuous/upscaled branch also constructed a source-exact copy that none of
these consumers read. Removing that copy preserves the selected arithmetic;
source lighting and native exact-mode geometry are unchanged. This is a CPU
preparation optimization for both backends, **not GPU transform migration**.

The isolated 256-vertex/no-face benchmark (`starfox_raster_commands_tests
--geometry-only`, 2 warm-up batches, median of 9 batches of 2,000 draws) measured
the following Windows microseconds per draw before/after, with no concurrent
build or game benchmark:

| Render scale | Exact input before | Exact input after | Fractional input before | Fractional input after |
| --- | ---: | ---: | ---: | ---: |
| 1x | 32.41 | 31.91 | 7.20 | 7.51 |
| 2x | 35.39 | 7.51 | 7.39 | 7.64 |
| 4x | 35.38 | 7.73 | 7.13 | 7.32 |

This fixture isolates vertex preparation, not whole-game FPS. Fractional input
already avoided the duplicate and its small timing differences are not claimed
as improvements. Runtime samples overlapped later builds and are correctness
evidence only. Twelve before/after captures (Original/EX, CPU/GPU, 1x/2x/4x)
are byte-identical in `tmp/geometry-single-copy-{before,after}-{original,ex}`.
Windows/Linux command replay and substrate tests pass; all 168 GPU raster
comparisons pass on Windows Vulkan and Linux software Vulkan. Windows Original
and EX geometry-pacing tests and shadow-geometry tests also pass.

### FPS overlay no longer forces native-frame readback

The live FPS counter now composites its packed glyph mask and one-logical-pixel
black shadow in the resident GPU pipeline. It retains the CPU ordering: after
lighting/HDR/chromatic/early shadows, before styles/bloom/AA. The small glyph
mask reuses per-dispatch uniform storage; no extra frame-sized upload or
readback is introduced. Oversized diagnostic overlays retain the CPU fallback.

648 overlay cases match the independent two-pass CPU glyph reference on
Windows Vulkan and Linux software Vulkan, with negative/edge clipping,
1x/2x/4x scales, overlapping glyph/shadow pixels, and split early/late effects.
Both resident and uploaded input paths pass. Existing compositor/transition
cases also pass. Actual Original and EX gameplay captures with the FPS counter
enabled match CPU captures exactly at all three scales, and require the GPU
overlay trace with no CPU-composition readback. Captures are in
`tmp/gpu-fps-overlay-original` and `tmp/gpu-fps-overlay-ex`; reproduce using
`pwsh -File tools/check_gpu_native.ps1 -DefaultPipeline -FpsOverlay -Frames 12`.
These short captures establish parity, not a whole-game FPS improvement.

![Resident FPS counter, Original 2x](../tmp/gpu-fps-overlay-original/ORIGINAL-1000-2x-gpu.bmp)

### Save-slot and exit panels

The same packed-mask path now draws the centered confirmation panel on-device:
opaque black interior, source-sized white border and white text, after the FPS
overlay and before styles/bloom/AA. The 112x40 panel fits the existing uniform
storage, so this adds no frame-sized upload. CPU fallback remains available for
oversized overlays and unsupported backends.

All 1,296 FPS/panel cases pass on Windows Vulkan and Linux software Vulkan,
including independent CPU panel painting and split effect-order comparisons.
Live Original save-slot and EX exit-confirmation captures match the CPU path
exactly at 1x/2x/4x, with the GPU panel trace and no overlay readback. Run
`tools/check_gpu_native.ps1 -DefaultPipeline -PanelOverlay Slot -Frames 12`
(or `-PanelOverlay Exit`, with the EX ROM/symbol arguments).

The initial combined FPS/panel comparison differed only in the measured FPS
number after shader startup (1 versus 240); it was not accepted as parity.
The panel captures disable that variable diagnostic counter. FPS rendering
has its own independent tests and previous matched captures above.

![GPU save-slot panel](../tmp/gpu-panel-slot-original/ORIGINAL-1000-2x-gpu.bmp)
![GPU EX exit confirmation](../tmp/gpu-panel-exit-ex/EX-1000-2x-gpu.bmp)

Direct presentation now retains its capture snapshot in GPU-local memory on
D3D11 and SDL GPU. Previously every frame was copied into CPU-readable staging
memory even when the application never mapped it. The staging copy is now
issued only when capture/history requests pixels. This retains one GPU-local
RGBA snapshot per active backend; it does not eliminate the earlier CPU/GPU
round trips around native composition.

D3D11 also reuses its indexed-pixel buffer/SRV and upload scratch allocation.
SDL GPU no longer zeroes upload bytes that are immediately overwritten, only
the DWORD padding actually consumed by raw buffer loads.

Validation: both standalone D3D11 and Windows Vulkan comparison programs pass.
D3D11 direct base/glow/model separation remains exact. New portable capture
tests cover replacement of unread frames and repeated capture reads at all
four bloom/HDR settings. Floating-point effects retain their existing maximum
one-channel-unit CPU/reference tolerance. The benchmark's batched/separate
timings do not measure these changes against the previous revision; no FPS
improvement is claimed from those numbers.

Portable shadow-ray tracing now runs in Vulkan/Metal compute when DXR is not
available. It retains eight rays and full resolution; no visual quality was
reduced to obtain the speedup. Current-frame geometry and conservative packed
BVH bounds avoid stale caster state. Hardware Vulkan is required in-game;
software Vulkan can be explicitly enabled for parity tests only.

On the NVIDIA RTX 5070 Ti Laptop GPU, a 128-triangle fixture measured:

| Resolution | Vulkan median | CPU median (4 workers) | Different mask pixels |
| --- | ---: | ---: | ---: |
| 400x224 | 0.462 ms | 10.626 ms | 0 |
| 800x448 | 1.166 ms | 45.016 ms | 0 |
| 1600x896 | 3.818 ms | 161.717 ms | 2 / 1,433,600 |

The two edge differences were one of eight light samples (mask delta 20).
GPU timings include packing, uploads, dispatch, fence wait and mask readback;
the shared BVH build is outside both timings. These are isolated measurements,
not whole-game FPS. Linux/WSL shader comparisons also passed, but its software
Vulkan timings are slower than native CPU rendering and are not GPU results.
Changing geometry, resolution, light axis, winding, ground and empty scenes
passed. A Windows gameplay capture verified portable shadows and direct bloom
presentation together. Metal/Android device validation remains outstanding.

### Native raster pipeline

The raster API now also supports a borrowed SDL GPU device and GPU-resident
packed pixels/surface buffers. Submission in this mode performs no download;
explicit capture reads them later. Tests cover frame replacement, generation
changes, exact deferred pixels/metadata and resource release.

The GPU renderer now connects resident raster output to GPU
composition, palette expansion, filters, lighting, early shadows, styles,
bloom, AA and direct SDL GPU presentation. Foreground write coverage preserves
black and same-colour overlays. Transitions and overlays not yet handled by
the combined path reconstruct the authoritative CPU frame through command
replay. Windows desktop now selects SDL GPU/Vulkan by default; explicit GPU
driver overrides are respected. Supported Vulkan/Metal renderers enable native
rasterization without test flags. Unsupported shader formats and software
renderers retain the CPU path. `STARFOX_DISABLE_GPU_NATIVE=1` provides a
diagnostic CPU reference; it does not change the user's saved settings.

Resident effects no longer allocate/upload three unused placeholder buffers.
Direct presentation allocates CPU-readable screenshot staging only when a
capture is requested, rather than reserving three full RGBA frames eagerly.
Deferred/repeated capture tests and all 108 compositor comparisons still pass.

108 standalone composition cases match pixels, tags, RGBA and both combined
and separately batched effects exactly, including clipping, mosaic, differing
draw scales, foreground writes and early shadow ordering. The shader checks
pass on Windows Vulkan and Linux software Vulkan. Original and EX gameplay
captures match exactly at 1x/2x/4x with resident presentation exercised.

Default-path validation (no native-GPU or SDL-GPU test enable flags) also
matches Original/EX gameplay and the Original opening at 1x/2x/4x. Logs and
BMPs are in `tmp/gpu-default-original`, `tmp/gpu-default-ex`, and
`tmp/gpu-default-transition`. Opening captures caught and now cover a
first-capture staging-allocation regression; the standalone effects test also
starts capture on a fresh backend, not one warmed by prior CPU readbacks.

An isolated 48-frame gameplay sample (16 warm-up frames) on the local Windows
Vulkan GPU measured these sums of the background/world/composite/present
host timers at 4x. CPU reference and resident mode used the same renderer,
scene, effects and screenshot checks; no build or test suite ran alongside.

| Experience | CPU raster/composition | Resident raster/composition |
| --- | ---: | ---: |
| Original | 13.154 ms | 3.030 ms |
| EX | 14.548 ms | 4.380 ms |

These are short sampled host rendering times, not whole-game FPS or GPU
timestamp measurements. They exclude simulation and do not establish
campaign-wide performance or timings on other hardware. The later opening
and regression runs overlapped tests and are correctness evidence only.
Original launch captures also match at those scales. These checks are not
full-game or physical-console validation.

The new RAY TRACING option defaults Off and selects hardware DXR 1.1 shadow
tracing independently of Enhanced Shadows. Unsupported devices show
UNAVAILABLE. Enhanced Shadows continues to use portable compute/CPU tracing
without implying dedicated RT hardware. This is shadow ray tracing, not
path-traced global illumination or reflections.

### Remaining native geometry boundary

The current desktop input to compute is still `RasterCommands`: ordered,
already-projected scanline spans. `SoftwareRenderer` performs projection,
clipping and source BSP selection before producing them, and `bin_rows()`
builds the tile lists on CPU. Finishing the requested migration requires
moving that upstream work too; resident effects alone do not satisfy it.
The earlier wording below about intentionally preserving CPU geometry describes
the prototype checkpoint, not the final delivery scope.

`starfox_raster_commands_tests --binning-only` isolates binning of actual
source-generated commands for 32 overlapping untextured quads at 400x224.
It uses two warm-up batches and nine median samples of 32 rebuilds, without
GPU submission. Windows/Linux Release measurements:

| Scale | Commands | Sparse list bytes | Dense bitset bytes | Windows / Linux µs |
| --- | --- | --- | --- | --- |
| 1x | 4,195 | 72,516 | 827,904 | 26.57 / 31.19 |
| 2x | 8,450 | 258,424 | 6,173,440 | 101.89 / 112.53 |
| 4x | 16,897 | 963,296 | 47,398,400 | 416.12 / 446.90 |

This rules against a dense tile/command bitset as the default migration path:
its storage grows about 49x over the current sparse list at 4x in this fixture.
A GPU sparse count/scan/scatter implementation must also retain command order
(atomic scatter alone is unordered), transparent-texture rejection and the
independent last surface owner. These measurements are not in-game FPS or an
implemented GPU binning stage. Windows' 168 command-replay cases still pass.

An experimental sparse GPU implementation is now available with
`STARFOX_TEST_GPU_BINS=1` (set before device initialization). Six compute passes
clear counters, count coverage, scan 64-tile blocks in parallel, scan block totals,
add block offsets and scatter command IDs. The
CPU only sums reference capacity for allocation; it no longer constructs the
row/index lists on this path. Rasterization independently selects the greatest
command ID for visible colour and source surface metadata, so atomic insertion
order cannot change the painter result. Transparent texels are still skipped.
Windows hardware Vulkan and Linux lavapipe pass all 168 raster comparisons and
resident replacement/readback tests. SPIR-V and Metal sources are generated;
physical Metal is unverified. The hierarchical scan reduces serial prefix work
from 22,400 tiles to 350 block totals in the 4x fixture (plus 1,400 scratch bytes).
This is not enabled by default yet: unordered traversal cannot use the existing
early exit. It now skips material/texture fetches only when a command is older than both
already-established owners (or just the pixel owner when surfaces are disabled).
The skip does not assume scatter order and cannot suppress a newer transparent
texel's underlying surface. Windows/Linux 168 parity cases and empty-frame reset
pass; controlled performance comparison/optimization remains. Projection/BSP still
remain CPU work. No full migration completion or FPS improvement is claimed.

`starfox_gpu_raster_check --compare-bins` alternates both implementations on
one initialized device and one recorded 32-object scene at each scale. Four
warm-up pairs precede nine measured pairs; table values are medians in ms.
Every sample checks pixels/tags and, when requested, every surface field against
CPU replay. Timings include binning, upload, GPU raster, fence/readback/unpack;
they exclude projection and parity-check time, and are not whole-game FPS.

| Scale | Surfaces | Windows Intel Vulkan CPU/GPU bins | Linux lavapipe CPU/GPU bins |
| --- | --- | --- | --- |
| 1x | Off | 0.320 / 0.301 | 0.976 / 3.345 |
| 1x | On | 0.986 / 0.988 | 2.429 / 4.698 |
| 2x | Off | 1.092 / 0.833 | 4.209 / 13.489 |
| 2x | On | 3.847 / 3.358 | 7.098 / 13.183 |
| 4x | Off | 3.650 / 2.597 | 10.824 / 34.805 |
| 4x | On | 15.028 / 13.664 | 20.786 / 43.067 |

`--compare-resident-bins` uses the same alternating harness but times submission
through fence completion without downloading pixels. Readback and every parity
check happen afterward. Fence-only waits preserve resident handles/generation,
are idempotent, and reject uninitialized/released instances. Windows lifecycle
tests and Windows/Linux paired parity pass. A Windows Intel run measured CPU/GPU
bins at 1x/2x/4x as 0.224/0.212, 0.793/0.520, 2.120/1.121 ms without surfaces,
and 0.454/0.344, 1.036/0.693, 2.936/1.594 ms with surfaces. A subsequent run
reproduced the higher-scale gain (4x 2.280/1.219 and 3.014/1.731 ms).
Linux lavapipe remains slower with GPU bins (4x 9.015/32.566 and 8.745/31.160 ms).
These are synchronized diagnostic timings, not asynchronous game frame times.

`--compare-mixed-bins` adds two resident workloads: scrolling transparent
textured polygons, and a mixture with 24 of 32 objects rendered as scaled
sprites (including palette overrides). The harness asserts that texture and
sprite commands are actually present, and checks output outside every timing.
Windows Intel 4x CPU/GPU-bin medians are 2.041/1.185 ms without surfaces and
2.738/1.573 ms with surfaces for textured polygons, but 0.986/2.260 and
1.217/2.456 ms for the sprite-heavy scene. All paired output checks pass.
This exposes a workload-specific regression even on hardware Vulkan; optimize
coverage counting/scatter for multi-row rectangles before default enablement.
The solid-polygon speedup must not be generalized to every scene.

Coverage count/scatter now divides each command among eight lanes, flattening
its covered tile rectangle into a strided work list. This addresses long sprite
rectangles without creating dense tile/command storage. Four lanes reduced the
4x sprite-heavy/surfaces GPU time to 1.401 ms versus paired CPU bins 1.269 ms;
eight lanes measured 1.116 versus 1.235 ms. Without surfaces the eight-lane
4x sprite case measured 0.847 versus 0.896 ms. The same run retained textured
polygon gains at 2x/4x, but low-scale overhead still sometimes loses to CPU bins.
These are separate runs, not a controlled lane-count sweep. Windows' 168 parity
cases, empty-frame/lifecycle tests and all mixed paired output checks pass.
Default enablement and physical Metal verification remain pending.

GPU-bin row/index buffers no longer receive dummy CPU uploads: the compute
passes initialize them. This removes two copy submissions and 32 placeholder
bytes per GPU-binned raster without changing the CPU-bin path. Windows' full
raster parity, resident lifecycle and empty-frame checks pass. This is a small
submission cleanup, not a separately measured FPS gain. SDL's public device
properties expose optional unstructured names, not a hardware/software enum;
do not infer default eligibility by parsing those names.

The hardware result supports continuing this implementation; the software-GPU
regression argues against indiscriminate enablement. Keep the prototype opt-in
until resident, diverse-scene and additional hardware measurements are covered.

Removed the unused `PresentationEffects::black_side_bars` fields, CPU pixel loop
and resident-path exclusion. No caller assigned these fields; this is dead-code
cleanup, not a new visual fix or a measured performance improvement. The Windows
desktop translation unit compiles without linking or replacing the executable.

### Hardware-Vulkan binning integration

The desktop now creates SDL's GPU renderer with the Vulkan hardware-acceleration
requirement explicitly set (except software-GPU diagnostic mode). The bundled
SDL renderer forwards that property to GPU-device creation. Only successful
hardware-required Vulkan creation enables sparse GPU binning by default through
the explicit `render_resident` option. Metal, software-test mode and automatic
fallback renderers retain CPU bins. `STARFOX_DISABLE_GPU_BINS` disables this
integration; the existing test flag remains available for diagnostics.

This supersedes the opt-in-only status above for that hardware-required path.
Windows desktop compilation and explicit API/resize parity checks pass, without
relying on a device-name heuristic. The desktop executable was not linked,
replaced or launched because of its existing Defender quarantine; real window
creation/presentation proof for this integration remains pending. CPU projection,
clipping and BSP selection are still not migrated.

Linux desktop object compilation and the standalone 168-case raster diagnostic
also pass. Binning can now switch on an initialized renderer: its optional
compute pipeline is created lazily after the previous submission completes.
The diagnostic replaces an unread CPU-binned frame with GPU bins for every
native raster case, checks pixels/tags/surfaces, and switches back on the next
case. Small resize cases additionally alternate CPU/GPU/CPU/GPU bins. These
checks exercise the explicit API rather than requiring the test environment
flag; they do not constitute desktop-window or additional physical GPU proof.

The opt-in OpenXR discovery build is documented in `VR-BUILD.md`. It is not
a playable VR build; this machine has no active OpenXR runtime for validation.

`STARFOX_TEST_GPU_RASTER=1` records ordered source scanlines and executes their
coverage, dither and texture sampling in Vulkan/Metal compute. Both ordinary
and scaled sprites are sampled on the GPU; line centres retain the original
Bresenham rule. CPU projection, clipping and BSP selection are intentionally
preserved. Ordered CPU command replay provides a fallback. The prototype only
captures the main Super FX scene layer, not every separated UI/model layer.

Standalone comparisons check original-width and widescreen rasters, 1x/2x/4x,
word matrices, flat/textured faces, wireframes, wave/wobble/cel modes, clipping,
sprite scaling, palette overrides, and surface ownership. All 168 cases pass
on Windows Vulkan and Linux software Vulkan. Original and EX gameplay captures
match the CPU path exactly at all three scales. The native raster
test deliberately remains opt-in: while a heavy-overdraw fixture improves
substantially, ordinary gameplay still pays a GPU-to-CPU handoff into the
existing compositor and showed slower world-pass times. Do not present the
synthetic result as a general in-game FPS improvement or enable it by default
without resolving that handoff. Test profiling can now discard shader-startup
frames with `STARFOX_TEST_PROFILE_WARMUP`.

Surface metadata is now collected only for its consumers (Enhanced Lighting
or legacy smooth polygons), not merely because enhanced graphics is enabled.

### Resident portable shadows

The portable shadow tracer now shares the SDL GPU presentation device and
passes its uint32 mask directly to effects. This removes the ordinary mask
readback/repack/upload round trip without changing eight-ray sampling or
resolution. CPU consumers can still request explicit mask readback. The
legacy immediate-readback API retains a single combined compute/copy submit.

Windows tests verify exact old/new GPU masks, repeated readback, changing
dimensions/geometry, empty-scene invalidation, release/reinitialization of
borrowed resources, and exact blending across layer tags and positive/negative
offsets. All 108 combined raster/composition/effects cases also compare direct
resident masks against uploaded masks. Original and EX gameplay captures at
all three scales match exactly, in `tmp/gpu-resident-shadows-original` and
`tmp/gpu-resident-shadows-ex`. The harness requires a resident-shadow backend
log entry, so silently falling back cannot pass this check. A representative
[Original 2x capture](../tmp/gpu-resident-shadows-original/ORIGINAL-1000-2x-gpu.bmp)
shows the unchanged building and ship shadows. Nine relevant Windows
regressions pass after these changes; both Windows and Linux builds succeed.
Linux/WSL also passes all 108 resident-shadow composition cases exactly using
software Vulkan (correctness evidence, not hardware performance validation).

The complete migration requested by the user remains unfinished: native
transition composition, remaining separated scene
layers, console GPU implementations, and eliminating DXR's separate-device
shadow-mask transfer require further work.

Final local regression builds passed 45/45 Windows tests and 39/39 Linux tests,
including the GPU-independent source-raster command replay suite. No release
was published from this work.

## Transition raster reuse (local)

Transitions and overlays now read back the existing resident model raster
instead of replaying the same model commands on the CPU. Software replay is
retained only if GPU readback fails. This removes duplicated raster work, not
the remaining CPU transition composition or its required readback.

Windows build passes. The 168-case raster checker passes exact pixels/tags/
surface comparisons and deferred-readback checks. Twelve actual 16:9 scramble
wipe frames at 60 FPS / 2x rendering match the CPU-raster path byte-for-byte
(`tmp/gpu-transition-readback-cpu`, `tmp/gpu-transition-readback-gpu`); the GPU
log confirms the transition readback path executed. This is correctness
evidence, not an end-to-end performance claim or a completed migration.

## Resident horizontal scramble wipe (local)

SDL GPU now masks the horizontal scramble shutter after 2D filtering and
before lighting/styles/bloom, retaining the CPU path's ordering and native
first-column guard. Interpolated double-precision edges are converted to exact
stored-pixel row bounds before dispatch, avoiding shader rounding differences.
The native eligibility gate now ignores inactive/zero-radius/zero-layer circle
effects exactly as the CPU compositor does. Other transitions still fall back.

Windows Vulkan and Linux/WSL software Vulkan pass 108 composition cases plus
432 shutter comparisons (closed/open, native/expanded, three output scales).
Actual runtime comparisons pass all 60 frames per case: Original 4:3 and 16:9
at 60 FPS, and EX 32:9 at 240 FPS. Logs explicitly confirm the resident GPU
shutter dispatch. Captures are in `tmp/wipe-resident-{4_3,16_9,ex}-{cpu,gpu}`.

![GPU scramble opening, Original 16:9](../tmp/wipe-resident-16_9-gpu/000030.bmp)

SPIR-V and Metal sources are regenerated; Metal hardware remains untested.
This completes this horizontal-wipe path, not all transition/overlay migration.

## Released in 0.0.6.5

Windows desktop: D3D11 compute implementations exist for filters, model/world
styles, smoothing, Enhanced Lighting, HDR, chromatic aberration, bloom, AA,
and shadow-mask blending. DXR 1.1 builds shadow masks on supported hardware.
Unsupported backends retain software fallbacks. This is not a complete GPU
scene renderer: geometry rasterization and native composition remain CPU-side.

Late smoothing/styles, bloom and AA now execute in one upload/dispatch batch.
Pre/post-bloom snapshots preserve the separately scaled glow layer. Final RGBA
is not modified until required readbacks succeed, preserving software fallback.

Validation: Windows build and standalone GPU comparisons passed. Batched output
and both bloom snapshots exactly match the separate GPU passes at three tested
intensity combinations. Offset shadow-mask composition also matches exactly.
An isolated 514x258 fixture, eight alternating-order runs per mode, measured:

| Level | Separate passes | Batched passes |
| --- | ---: | ---: |
| 1 | 4.47 ms | 2.86 ms |
| 2 | 4.08 ms | 2.80 ms |
| 3 | 4.34 ms | 2.77 ms |

These are effect-path timings, not an in-game FPS guarantee.

Direct presentation now copies the final compute output into SDL's D3D11
texture without mapping it to CPU memory or re-uploading it. Bloom's final
base/glow split also runs on the GPU, with separate SDL textures preserving
linear filtering of the additive glow. Model-layer separation and silhouette
background reconstruction now also run on the GPU before SDL's existing 1440p
scaling/composition. This direct path applies when setup/touch overlays are inactive.
Screenshots and frame-history capture request the matching CPU pixels lazily.
Other paths retain the existing readback/composition flow. Standalone comparisons
passed exactly for both direct bloom textures and deferred capture at three
bloom/AA combinations; the Windows build and targeted regressions also pass.
Model/base separation matches the CPU reference exactly with positive/negative
offsets, palette ownership mismatches, and bloom disabled or enabled at all three
levels. These are synthetic comparisons, not end-to-end gameplay validation.

Final integration checks: a real hidden-window Windows D3D11 run exercised
direct bloom presentation, DXR shadows and BMP capture. A shutdown crash exposed
driver lifetime ordering; GPU COM resources now release before SDL destroys its
renderer, including renderer switches. The repeated smoke test exited cleanly
and its captured scene was visually inspected. Regression suites passed 44/44
on Windows and 38/38 on Linux (the full runs began before the final lifetime fix).
The xBRZ build switch now also gates shader inclusion.

Portable backend: SDL GPU now executes the same effect shader through Vulkan
or Metal on Linux, macOS, iOS and Android builds. SPIR-V and Metal source are
generated offline; the game needs no runtime shader translator. Vulkan parity
checks passed on Windows hardware and under Linux/WSL. Hidden-window gameplay
smoke tests on both entered direct SDL GPU bloom presentation, captured frames,
and exited successfully. The integrated Linux regression suite passed 38/38.
Metal and Android device runs have not been performed.
The normal Windows executable was in use; Windows smoke testing used
`build/current/starfox_pc_gpu_review.exe` instead.

Remaining: broader end-to-end visual testing, overlay-filter validation,
Metal/Android device validation, Switch/Vita GPU implementations, portable GPU
shadow tracing (only mask composition is portable), and release documentation reconciliation. Do not
describe this checkpoint as a completed all-platform GPU migration.
# Resident bomb colour disk (current local increment)

The SDL GPU effects path now applies the expanding bomb disk before the
shutter/lighting/style/bloom passes, preserving CPU ordering. It uses exact
integer stored-pixel radius/clipping tests, indexed OBJ exclusion, brightness-
adjusted five-bit add/subtract/half math and unchanged alpha. Ordinary gameplay
no longer requires a GPU readback solely because this disk is active.

Windows hardware and Linux software Vulkan each passed 864 disk comparisons
against independently computed CPU pixels (all eight arithmetic/OBJ flag
combinations, multiple source/output scales and compositions), alongside the
existing 108 composition and 432 shutter cases. The public GPU entry rejects
out-of-range arithmetic inputs; the runtime retains CPU fallback for circles
outside the safe integer range or scenes with other unmigrated overlays.

Original gameplay at 60 FPS exercised the GPU disk (explicit trace marker) and
matched CPU final BMP bytes at 1x/2x/4x, including a visible bomb and comms:
`tmp/gpu-circle-live60`. Earlier `gpu-circle-runtime`/`gpu-circle-bomb-runtime`
runs did not reach an active disk and are not disk validation evidence.
EX also passed the same three scales with the disk trace present
(`tmp/gpu-circle-live60-ex`). Reproduce with `tools/check_gpu_native.ps1
-DefaultPipeline -Bomb`; pass the EX cartridge/symbols/experience for EX.
The new `-Bomb` mode fails if the disk trace is absent, rather than silently
counting ordinary gameplay as disk validation.

![GPU bomb disk](../tmp/gpu-circle-live60/ORIGINAL-1000-2x-gpu.bmp)

This does not complete other window masks, colour math, separated layers,
model transform migration, console backends or VR integration.
# Resident background-only subtraction (current local increment)

Game Over's fixed-white background fade now runs on SDL GPU before the bomb
disk and shutter. Composition carries a separate foreground-cell coverage bit,
independent of surface-normal availability, to preserve the CPU's model exclusion.
Sprite exclusion uses the original cell's top-left palette index, and subtraction
retains five-bit clamping/expansion and alpha exactly. Masks with incompatible
offsets still fall back; later unmigrated overlays are not claimed migrated.

Windows hardware and Linux software Vulkan pass 864 new background-fade cases
(four strengths including saturation, with/without model protection, multiple
source/output scales, offsets and mosaic/clipping), plus the previous circle,
shutter and composition tests. Original 16:9 and EX 32:9 Game Over sequences
each match all 36 CPU frame captures and final BMP byte-for-byte, with explicit
`GPU background fade` markers. Evidence directories:
`tmp/gpu-gameover-sequence-{cpu,gpu}` and
`tmp/gpu-gameover-ex-sequence-{cpu,gpu}`. Their later fallback markers concern
other overlays; this is not a claim that every Game Over frame is fully resident.

![Game Over GPU frame](../tmp/gpu-gameover-sequence-gpu/000025.bmp)
# Resident fixed-colour math (current local increment)

Global fixed-colour add/subtract/half math now runs on SDL GPU after the bomb
disk and before the shutter, preserving the CPU compositor's order and sprite
exclusion. It preserves the existing expanded-eight-bit arithmetic, including
signed division before clamping; it is not incorrectly replaced by the bomb
disk's five-bit rounding. Inactive/zero-layer requests remain no-ops.

Windows hardware and Linux software Vulkan pass 1,728 cases each through both
resident and uploaded indexed inputs, compared against `apply_colour_math`.
The 600-frame EX LEVEL3_2 death/revival run captures every fifth frame: all 120
captures match CPU BMP bytes, with an explicit `GPU fixed colour math` trace.
Evidence: `tmp/gpu-colour-revival-{cpu,gpu}`. The revived stage's later
non-horizontal window mask still uses fallback; that separate transition has
not been migrated. `capture_revival.ps1 -CaptureInterval 5 -Frames 600` exposes
the denser sample cadence used here.
# Resident cartridge window masks (current local increment)

The non-horizontal 192-row cartridge window table now uploads as packed
left/right byte pairs and is evaluated on SDL GPU. The shader implements
OR/AND/XOR/XNOR, wrapped bounds, native viewport guards, optional horizontal
and vertical expansion, and source-cell replication at higher render scales.
The existing interpolated horizontal shutter remains its separate smooth path.
Portable and D3D constant-buffer layouts were updated together; the D3D path
still declines this new stage rather than silently producing incorrect output.

Windows hardware and Linux software Vulkan pass 1,728 new window cases,
alongside all prior composition/effects checks. A new 600-frame EX LEVEL3_2
death/revival run matches all 120 sampled CPU captures. The GPU log confirms
bomb disk, fixed-colour math and cartridge window stages, with no transition
readback fallback during this run. Evidence:
`tmp/gpu-window-revival-{cpu,gpu}`. This supersedes the earlier revival mask
fallback limitation below, not the remaining overlays/planet layers/VR work.

## Resident setup/menu overlay

The native resident path now uploads the logical indexed setup ink and performs
its dimmed panel plus white/yellow/blue-grey glyph composition on SDL GPU.
Stage 25 runs after style, bloom, antialiasing and late shadows, matching CPU
ordering; alpha is preserved. Packed byte loads are padded safely, and smaller
overlay inputs are clipped. SPIR-V and Metal bindings were regenerated together.
The legacy D3D effects path explicitly declines this stage for CPU fallback.

Windows Intel Vulkan passes 648 setup cases through both resident and uploaded
inputs, including zero/partial/full brightness and bloom/antialiasing ordering.
Nine additional 256/400/800-wide, 1x/2x/4x full-height tests verify centred panel
edges and unchanged alpha. Existing composite/effects checks also pass. These
are synthetic pixel comparisons, not fresh in-game screenshots. Physical Metal
and Linux runtime validation were pending at this checkpoint; the later sections
record Linux, touch and planet-overlay coverage. Separated model layers remain.

## Resident touch controls and Linux overlay verification

Touch rectangles now compose on SDL GPU after setup ink, preserving their
source order, inclusive shared edges, integer alpha rounding and scene alpha.
The resident path no longer downloads solely for touch controls. Windows
hardware Vulkan and Linux software Vulkan both pass 108 clipped resident touch
cases and nine 256/400/800-wide 1x/2x/4x panels, including combined setup/touch
ordering. Both also pass the 648 setup cases and all prior composite checks.
This supersedes the setup stage's Linux verification gap above, not physical
Metal/mobile checks or fresh in-game capture requirements.

Reproduce Linux checks with `STARFOX_TEST_SOFTWARE_GPU=1` and the system
lavapipe ICD; diagnostic software-GPU opt-in is necessary because the default
renderer requires hardware acceleration. `STARFOX_TRACE_GPU` now reports
`GPU setup overlay` and `GPU touch controls` only after resident submission
succeeds. The desktop runtime source compiles separately; no quarantined
desktop executable was rebuilt or relaunched.

The uploaded-frame presentation path now also carries setup/touch composition
through to the GPU presentation texture; it no longer forces an extra download
just for these overlays when earlier scene work used CPU composition. If direct
presentation fails, overlay settings are cleared before the existing CPU path
to prevent double dimming/blending. Nine full-size deferred-capture checks
verify that direct presentation leaves the input CPU pixels unchanged and an
explicit later readback matches the independent combined-overlay reference.
This does not remove the earlier CPU work or claim full scene residency.
# Ordered colour-warp expansion validation

Optional GPU backface culling is implemented before viewport clipping and after
near clipping, matching the source stage order. Face packets mark polygon-only
bit 3; native clipping accumulates exact signed area in two 32-bit words to
avoid overflow. All 2,697 Original / 8,091 images and 3,511 EX / 10,533 images
pass `--native-backface` (three Q15 views, native 1x), coverage/palettes exact,
maximum normal error 1.19209e-7 and depth error 0.000244141. Packet tests pass.
Fractional culling uses compensated projected area but is NOT parity complete:
the EX sample fails TOTEM_2 / view 4 / 1x at coverage pixel 4966. The native
GPU model renderer remains diagnostic-only; this known failure must be fixed
before enabling generic fractional culling in gameplay. Earlier blanket
backface-rejection statements are superseded, not the outstanding parity gate.

Visual evidence added and inspected: `tmp/gpu-colour-warp-face-proof/
model-47523-face-0-layer-0-mode-0-view-0-scale-2.bmp` shows Original FACE_0
colour warp, CPU left/GPU right, using the diagnostic palette. Its polygon
boundaries and dither patterns match; all 18 numeric cases for that model pass.
The checker now captures front view 0 as well as the previous side view for
colour warp, avoiding a nearly empty side-view image as the only visual proof.
This is offscreen model evidence, not in-game or headset presentation proof.

Fractional PIPE follow-up: enabling camera residual transport through axis
reduction and continuous line clipping changes Original PIPE_5's view 5 / 1x
failure from pixel 21619 to 211. Endpoints become approximately
(211.4999847,-5.329e-14) and (19.4999981,191.9999847). Enabling source-order
Euler operands for axis vertices changes the latter X to 19.5000019 but still
fails pixel 211; the zero boundary gains -5.684e-14. Both experiments were
reverted, retaining the verified native-axis implementation. Its full Original
8,091-image native-axis regression passes again. Fractional line clipping,
not simply enabling residual plumbing, still requires an arithmetic fix.

Native-axis validation expanded: twelve direct device fixtures pass maximum
65,536-member signed-word sums, oversized/empty/invalid groups, half-away
rounding (including vanishing points), both near-crossing directions, fully
behind rejection and invalid-to-valid reuse. The existing 393,987 native and
131,329 continuous projection cases plus axis residual regressions pass again.
New `--native-axis` full-catalog runs pass Original 2,697 models / 8,091 images
and EX 3,511 / 10,533, no deferrals, exact coverage/palettes and zero surface
error. Scope is three Q15 views at native 1x, not fractional-axis parity; the
documented PIPE failures and unusual near-intersection fallback remain separate.

**Native axis path implemented:** axis reduction now has a source-word mode
that averages integer transformed camera coordinates, rounds half away from
zero, retains unrounded depth sign for rejection, performs wrapped midpoint
near clipping and feeds native camera/vanish records to the word projector.
The 1x native-view skips were removed from `--axis` and `--warp-axis` checks.
Original ordinary-axis sample passes 64 models / 1,152 images; EX colour-warp
axis sample passes 64 / 1,152, with exact coverage/palettes and zero surface
error. This supersedes the blanket native-axis rejection noted earlier, not
the separately documented fractional PIPE failures. Large/extreme groups,
invalid inputs and fallback intersections still need dedicated device tests.

Projection-only binary64-tail quantization was also tested with matrix tail
retention: rounding multiplication, division and vanishing-point addition before
screen clipping still fails KICHI_0 progress 1 / view 0 / scale 4 at palette
pixel 643552. Reverted and regenerated normal artifacts. Merely adding rounding
at projection boundaries is not sufficient; avoid repeating that experiment.

Compensated-arithmetic experiment: error-free low-part summation plus separate
cross-product error terms, with matrix clipping-tail retention, fixes TREE's
90-image destruction fixture and KICHI_0's progress-1 counterexample. It fails
KICHI_0 at progress 2 / view 0 / scale 4, surface palette pixel 589719.
Rounding each screen-intersection operation's tail to binary64 spacing does
not fix this later case. Both experimental variants were reverted; KICHI_0
again passes all 90 images on the restored renderer. The next precision work
must include this second-stage counterexample, not just the first two edges.

Temporary shader instrumentation established both clipping counterexamples.
TREE's compensated low component at (93.375,192) is
`-2.6591219466354232e-6`, consistent with the independent binary64 result.
KICHI_0 isolated face 34 (normal -73,73,-73; vertices 42,44,37,35), destruction
progress 1 / view 0 / scale 4, instead has low X `-5.6843418860808015e-14`
at (60.125,192). Its exact camera edge (-83,109,365) -> (-83,429,685)
produces binary64 X=60.125 exactly. Thus carrying every low component changes
the correct KICHI pixel while TREE needs its real remainder preserved.
Instrumentation and broad tail-preservation experiment were removed and the
normal checker rebuilt. The checker now prints UV payload alongside XY for
diagnostics; production UV semantics are unchanged. Next arithmetic fix must
distinguish these cases without a model-specific exception or tolerance waiver.

Projection follow-up: current TREE destruction still fails isolated face 39,
view 1 / scale 4 / progress 1 at coverage pixel 671482. A fresh binary64
calculation from its exact camera edge (-21,105,236) ->
(-17.0001220703125,89,256) gives bottom intersection X=93.37499734087815,
not 93.375. At 4x this is 373.4999893635126 and rounds to 373; the GPU's
narrowed 93.375 rounds to 374. This establishes an actual ~2.659e-6 remainder,
not merely a hypothetical tiny signed cancellation. A fix still must preserve
this remainder without reviving the documented false KICHI_0 intersection tail.
No tolerance change or renderer patch was made for this evidence.

**Destruction integration:** ordinary and destruction colour-warp models now
share the resident path. The PRNG seed uses the pre-fragment source vertex count;
its bit 31 selects unconditional face-word consumption during destruction.
Sprite centre visibility is still tested later, independently of consumption.
The generator fixture passes 33,287 descriptors including hidden destruction
faces. The final bit-31 build passes EX 64 models / 5,760 destruction images
(five destruction stages, six views/seeds, 1x/2x/4x), exact coverage/palettes,
normal error <=1.19209e-7, depth <=0.000488281. The matching Original final-build
run also passes 5,760 images with normal error <=5.96046e-8 and depth error
<=0.000976562; session 47979 is terminal success. Earlier destruction rejection
statements are superseded. This sample does not resolve previously documented
general destruction projection edge cases or prove every model/animation.

**Axis integration:** colour warp now works with the existing continuous axis
collapse path. The decoder retains random material colours but suppresses texture
sampling, matching the source's plain-line emitter; source face normals have a
separate upload from axis indices. Original and EX samples each pass 64 models /
960 images (six views, eligible 1x plus 2x/4x, thickness 1–4), exact coverage and
palette values, zero surface error. The independently checked decoder passes
2,097,152 results across all descriptors and 32 ordinary/axis shading fixtures.
Native word-axis clipping and colour-warp destruction remain pending; earlier
statements that all colour-warp axis combinations reject are superseded.

**Full EX sweep completed:** 3,511 models / 63,198 ordinary colour-warp images,
665,303,504 nonzero pixels, no deferred models. Coverage/palettes exact; maximum
normal error 1.19209e-7, depth error 0.000244141. Together with Original this is
6,208 models / 111,744 images at six views/seeds and 1x/2x/4x. Both full-sweep
sessions are now terminal success; earlier live-session entries are superseded.

New `--warp-alternate` fixture combines colour warp with cel, both wireframe
modes, supported wobble bit 1 and wave (five modes, six animation/view/seed
fixtures, three scales). EX sample: 64 models / 5,760 images pass with exact
coverage/palettes, maximum normal error 1.19209e-7, depth error 0.00012207.
Original matching sample also passes: 64 models / 5,760 images, 18,590,270
nonzero pixels; exact coverage/palettes, maximum normal error 5.96046e-8,
depth error 0.00012207. Session 79416 is terminal success. Combined alternate
sample coverage is 11,520 images, not a full alternate-mode ROM sweep.

Full Original ordinary colour-warp sweep completed: **2,697 models / 48,546
images**, six views/seeds at 1x/2x/4x, 446,614,705 nonzero pixels. Coverage and
palette values match SoftwareRenderer exactly; maximum normal error 1.19209e-7,
depth error 0.000244141. No models deferred. Original session 31405 is terminal
success; EX session 22689 remains live. This still does not cover every animation
frame, axis/destruction or every alternate-effect combination. The resident-chain
cancellation/reuse fixture also passes again.

Follow-up verification: material-free warp topology matches normal topology
(apart from texture flags/UVs) for all 2,697 Original and 3,511 EX decoded models.
Quest ARM64 debug compilation passes in 50 seconds with the shared changes;
the SDL native-model diagnostic backend remains disabled there, so this is
cross-platform compilation evidence, not Quest GPU-model rendering evidence.
Full ordinary colour-warp pixel sweeps were started for both ROMs and are still
running as of this entry (exec sessions Original 31405, EX 22689). Re-poll those
handles; do not treat a timeout as completion or restart a live sweep.

**Current integration update:** `GpuModel` now connects ordinary active colour
warp to the resident chain. Material-free face templates preserve alternate
untextured emitter flags; packed texture lookup/UVs and padded shading tables
feed the GPU decoder. Expansion precedes clipping, preserving painter-order
occurrences and generating source surface metadata before expansion. This
supersedes earlier statements below that all active colour warp is rejected.
Axis-collapse and destruction combinations remain explicitly pending.

`--colour-warp` model validation passes 64 Original and 64 EX models, six views/
seeds at 1x, 2x and 4x: 2,304 images with exact coverage/palettes. Maximum surface
normal error is 1.19209e-7 and depth error 0.00012207. These are sampled models,
not a full ROM sweep or all effect combinations. Face-template unit tests pass.
The broader native GPU model path remains diagnostic-only, not enabled gameplay.

The chained resident wrapper now has a Vulkan device fixture:
`starfox_gpu_warp_chain_check` passes repeated faces, shortened/empty/hidden
lists, invalid traversal/face IDs, command cancellation and subsequent reuse.
This fixture uses palette override to isolate orchestration and copied surface/
corner data; random material arithmetic and alternate UV selection retain their
separate stage tests. It does not yet prove end-to-end model pixels.

Resident orchestration is implemented in `GpuColourWarp`: generation, material
decode and occurrence expansion enqueue consecutively on the caller's command,
with owned cyclic output buffers and no submission/readback. It builds in the
desktop SDL GPU configuration; a chained device fixture and GpuModel connection
are still required. Generation now clears its full capacity before validation,
so downstream capacity dispatches cannot observe stale descriptor tails. The
generator GPU check passes 32,775 exact descriptors and explicitly checks cleared
tails for failed, empty and shortened lists. Expansion's existing device check
also passes after this change.

The diagnostic expansion stage now uses eight read-only storage buffers, within
SDL GPU's limit. Hidden decoded materials use texture sentinel `0xfffffffe`,
distinct from untextured `0xffffffff` (including solid black); this removes the
redundant descriptor buffer. SPIR-V and Metal artifacts were regenerated.

`starfox_gpu_warp_expand_check` passes on the local Vulkan device: repeated face
IDs retain independent UV/material slots, hidden draws clear outputs, and invalid
texture-coordinate ranges, traversal status, face IDs and corner counts cannot
retain stale polygons. The production-resolver comparison also passes again:
1,048,576 GPU material results across all descriptors and 16 shading fixtures.

This is stage-level validation, not completed gameplay integration. The native
GPU model path still rejects active colour warp until these stages are connected
to resident resources and ordered clipping/rasterization. No release or headset
deployment was performed for this change.
# DXR scratch-buffer reuse

DXR coverage serialization and CPU fallback vertex conversion now retain
scratch vectors across frames, swapping with the last-uploaded/built vectors
only when content changes. Full byte comparisons remain; no object-identity
shortcut is used. Fresh starfox_vulkan_external_check --dxr passes alpha,
indexed scroll, moving geometry, resource resize and imported-mask pixel
comparisons on RTX 5070 Ti Laptop. Small resident fixture median 1.9693 ms,
max 2.0036 ms; not a controlled before/after benchmark or gameplay FPS claim.
Desktop mask readback and full migration remain unfinished.
