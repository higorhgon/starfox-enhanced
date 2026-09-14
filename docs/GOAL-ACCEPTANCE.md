# Current goal acceptance — September 13

The full goal is **not complete**. This is the current index; older delivery
notes are chronological history and often describe limitations since removed.
No publication or issue closure is implied.

Newest: EX introductory-logo margin repair now executes on GPU, with real
EX-logo trace assertions and CPU/failure/effects/stereo parity captures.
108 new repair fixtures pass on D3D12 and Windows/Linux Vulkan. Isolated
briefing and late restored layers plus sprite decoding remain.

Newest runtime connection: native-edge histogram reduction and solid margin
fills execute on GPU. Wide Controls/Continue/Game Over now use resident
backgrounds; CPU/GPU, late-star, effects and stereo/failure comparisons pass.
EX logo repair, isolated/late layers and sprite decoding remain. See the
latest GPU-MIGRATION-STATUS section for exact scope and capture locations.

Newest runtime connection: ordered early BG1/BG2/BG3 and sprite raster chunks
now feed the GPU compositor, including title/planet selection and 4:3 Controls.
Original/EX CPU/failure parity, wide effects and stereo checks pass; Windows,
Linux and Android rebuild. Remaining dependencies are enumerated in the top
GPU-MIGRATION-STATUS entry (CPU edge reductions, isolated/late layers and
sprite decoding). No full-migration or final-hardware acceptance claim.

Latest runtime connection: Mode 2 gameplay BG2 now executes on GPU, with
pre-model CPU coverage, mono/stereo composition and full CPU recovery.
Original/EX Corneria and asteroid final captures match CPU at 32:9/4x and
with effects enabled; both SBS layouts and DXR composition checks pass.
Windows/Linux PC and Android builds pass. Other background modes and special
presentation-layer routing remain; see the newest GPU-MIGRATION-STATUS entry.

Latest foundation: raw BG1/BG2/BG3 tile decoding and priority rasterization now
execute on GPU in ordered scene batches with immutable snapshots and replay.
BG2 includes HDMA, software-double horizon fitting, ground continuation and
unique-art/water/tunnel rules. The checker now covers 432 cases / 184 million
samples. Mode 2 gameplay is integrated; remaining ordered presentation
integration is listed above. See GPU-MIGRATION-STATUS.md.

The compositor now accepts resident backgrounds with independent pre-model
CPU coverage. 108 ordering/recovery fixtures pass across D3D12 and Windows/
Linux Vulkan; Game Over normal/forced-fallback captures remain byte-identical.
The application loop now supplies these for Mode 2 gameplay.

Latest implementation: Game Over margin stars now use a late GPU world layer,
including per-eye stereo projection and complete CPU fallback. D3D12/Windows
Vulkan/Linux lavapipe composition checks pass; photographic comparisons and
limitations are recorded in GPU-MIGRATION-STATUS.md. The previously handed-off
ZIP predates this new late-layer implementation; it has not been replaced.

Latest consolidated refresh: all Windows/Linux targets, Windows VR, Quest APK
and regular Android APK rebuild successfully. The rebuilt VR suite passes
15/15 (46.96 s with concurrent desktop tests). Fresh Windows CTest passes
55/55 (263.44 s, also under concurrent build/test load); fresh Linux CTest passes
54/54 (277.00 s). The current development ZIP is
verified below; physical headset/Deck/Android acceptance remains outstanding.

Current engineering progress: live GpuScene aggregation and shared DXR geometry
routing are connected on D3D12/Windows Vulkan, with a GPU-to-GPU completion
dependency. Supported mono and stereo scenes avoid CPU caster transforms.
Effect/axis modes (including exploding axes) export GPU source-mesh casters;
SBS no longer prepares an unused mono shadow pass. Training,
Corneria pillars, EX Corneria and Original title captures verify the selected
path and reference parity. Original full/EX half SBS match reference captures,
and injected stereo failure rebuilds correct mono GPU shadows. Controls player
models now join the GPU batch; 18 CPU/GPU captures match across Original/EX,
three aspect/scale combinations, and D3D12/Vulkan. Controls GPU caster routing
also passes reference parity. Remaining non-model layers and broader hardware
acceptance still need review; the small-scene
mono benchmark has a 4–5% median cost despite
comparable p95 timings. See GPU-MIGRATION-STATUS.md for evidence and limitations.

Latest continuation: current Linux build succeeds; full WSL/Linux CTest passes
54/54 (286.33 s), including both cartridge simulation/state/ending suites and
runtime input. Separate Linux Vulkan depth check passes 366,183 analytical
samples. This is not physical Steam Deck or Metal acceptance.
EX Continue/model-viewer resident shadow capture and F1 events also pass.
The refreshed `tmp/StarFox-Enhanced-PC-Quest-GPU-current-20260913.zip` contains
the current Windows binaries and Quest APK, with clean contents and binary
hashes verified. A reusable packaging script now creates fresh staging areas
and rejects existing output archives. See ISSUES-43-49-VERIFICATION.md for the
package check/hash. No release or device installation is implied.

Current user direction: future Quest installs are authorized, including stopping
the app for the update. Preserve saves/data. Batch related implementation work
and consolidate regressions; the user has approximately 15% of their plan left
and wants to wrap up within it. This does not change the completion criteria.
September 13 latest deployment supersedes the older controller-dialog notes:
the preview/reset/title-distance APK built (27 s), `adb install -r` succeeded,
and QuestActivity launched successfully. Current logs confirm OpenXR and Adreno
swapchain initialization. This is not physical preview/reset acceptance.
`deploy_quest.ps1 -StopRunning` preserves saves while stopping the authorized app.

Latest PC shadow report was Training: the gameplay-only dispatch gate excluded
that flow. Removed the flow gate, and included native viewer/continue models
before tracing. Current Windows executable rebuilt; Original/EX Corneria,
Training geometry and title captures pass resident/readback equality. Title
self-shadow capture has no invented ground. See RAY-TRACING-VISUAL-AUDIT.md.

Latest PC follow-up: opt-in planar-model geometry depth now runs entirely on
GPU and survives both mixed-scene composition paths. A new D3D12/Vulkan checker
passes 366,183 analytical samples plus invalidation/ownership checks; existing
real-model and mixed-binning regressions also pass. Details and exclusions are
in PC-DLSS-STATUS.md. This is not DLSS evaluation or complete scene depth, and
normal game records do not enable it yet. No Quest installation occurred.

September 13 PC follow-up: stable native object identity now reaches GPU model
draw records and survives stereo eye copies. Windows runtime and stereo tests
build; the stereo regression passes. This is a DLSS prerequisite, not motion
vectors or DLSS evaluation. The approved SDK probe initializes DLSS on a real
D3D12 device and queries Quality/Balanced/Performance/DLAA successfully.

Fresh runtime checks pass F1 open/resume/reopen for Original and EX. The verifier
now requires the requested experience, not merely a constant experience value.
Inspected EX Cheats capture in `tmp/dlss-identity-ex-menu-regression`, EX Half
SBS in `tmp/dlss-identity-sbs-half`, and Original Full SBS in
`tmp/dlss-identity-sbs-full`. These are limited fresh presentation fixtures;
they do not prove all scene/device acceptance. Full existing Windows CTest
suite completed 55/55 (193.47 s). Afterwards all Windows targets were rebuilt
against the current shared core. The new previous-pose history tests pass;
a fresh full suite against those relinked binaries passed 55/55 (187.31 s). DLSS motion
vectors and evaluation remain unimplemented; the history helper is not enabled
in normal rendering.

Latest deployment: user authorized the update. Added VR Posterize, Cyanotype
and Warm Film as independent model/world styles with translated labels and
existing intensity controls. New IDs round-trip preferences and retain old
desktop IDs; bitmap glyph coverage passes. Three-style GPU checks pass exact
OFF at zero and midpoint at 50%; full captures inspected in
`tmp/vr-extra-styles-verified`. All 15 VR tests pass (23.09 s); APK builds.
ADB force-stop then install -r succeeded, preserving app data. Launch was
intercepted by Horizon OS's controllers-required dialog; no new game PID
was observed. User must wake controllers; do not claim runtime acceptance.
PC DLSS requests are tracked in PC-DLSS-STATUS.md, not implemented yet.

Orbital scope follow-up: Original Sector X also uses the entry-horizon flag;
production and capture callers now explicitly require EX experience as well as
gameplay before applying the user-requested quarter-turn. New reusable
`tools/check_vr_orbital_backgrounds.ps1` passes six real-cartridge fixtures:
Original Sector X, EX entry/boss, and menu backgrounds 21/25/35. Captures are
under `tmp/vr-orbital-scope-check`; Original and EX menu horizons remain below
the scene. The relative EX gameplay rotation is still not physical acceptance.
Quest rebuilt successfully (18 s), not installed.

Latest GPU optimization: moved invariant orbital palette probes from fragment
to vertex shading with the same sampler, not a CPU cache. Both eyes plus
synthetic depth/coverage captures match the prior build exactly (222 BMPs
across two runs). Full VR suite passes 15/15 (24.26 s); Quest APK rebuild
passes. No installation or physical FPS claim. See GPU-MIGRATION-STATUS.md.

Current verification after gameplay-only orientation gating: full VR suite
passes 15/15 (23.27 s), and fresh native Vulkan captures complete for EX 5-1
boss tick 2500 and native menu page 2. Inspected
`tmp/vr-gameplay-clockwise-current/live-scene-left.bmp`: the local fixture
now puts the surface at the left, whereas the user's headset previously put
it at the right before correction. This confirms a relative quarter-turn,
NOT the requested final physical orientation; do not claim visual acceptance.
`tmp/vr-menu-page2-unchanged-current/live-scene-left.bmp` passes the fixed UI
transform assertion but is not byte-identical to the older capture (capture
conditions have not been established identical). GitHub #44/#47 rechecked:
still open with no new comments. No headset install or app shutdown occurred.

Latest horizon follow-up: user withdrew diagnostic installation and specified
a 90-degree clockwise correction in gameplay only; EX pre-game previews are
already correctly oriented. The EX entry/thin planet layer now gates that
correction on gameplay flow, including interpolated updates. Menu and Original
orientation regression checks pass. Quest APK rebuilt successfully, not
installed; physical orientation remains unverified. Removed the unsuccessful
CPU palette-cache experiment (colour mismatch) and extra orbit diagnostics;
the hole-fill and palette-boundary antialiasing fixes remain.

Sandbox integration follow-up: fresh Original and EX cartridge tests both pass
(19.06 s wall time). The fixture enters native pause, picks the actual player
mesh through the CPU bounds path, moves its rendered model without mutating
the live object, then unpauses, commits, captures the edited world position,
and runs another native tick. This strengthens the earlier isolated-box tests;
it does not replace physical controller/comfort validation. Only test/docs
changed after the last successful APK build; no headset update occurred.

Latest local pause-sandbox/control pass: Touch/Index triggers now map to L/R;
right/left grips map to Start/Select. Native aim spaces drive pause-only
controller rays. Trigger-edge grabs use model bounds, exclude HUD/backgrounds,
prevent simultaneous ownership, and release on invalid/untracked poses. Moves
remain render offsets while paused and commit once through the inverse source
view into live object coordinates on resume, guarded by pool generation.
Input and packet checks pass, including held-on-entry, two-hand ownership,
tracking loss and recycled-slot rejection. The Quest APK builds successfully;
this is not physical sandbox acceptance, and it has not been installed.
The final full VR suite passes all 15 tests (22.16 s wall time); the final
Quest rebuild also succeeds, including tracked-pose requirements. PID 15850
remains running unchanged. No install, app shutdown, commit or push occurred.

EX page placement is reproduced using native R-shoulder navigation: pages
1/3 report model vanishing point (76,92); page 2 reports (172,172). UI now uses
a fixed centered screen plane independent of that preview camera. All three
native page captures pass the fixed-transform assertion in
`tmp/vr-menu-fixed-page1` through `page3`; the camera regression checks both
origins and unchanged non-menu placement. Source menu text/layout is retained.
The sideways scramble report is still not reproduced: the fresh 180-tick
5-1 trace reports scroll (0,232) throughout the loaded entry, not a scroll-wrap
or rotating pitch. The latest headset screencap returned a zero-byte file,
so it supplies no visual evidence. Await an actual paused problem frame;
do not claim the orientation fixed or install over the running app yet.

VR style matrix now passes: seven styles, three intensities each plus OFF
(22 fresh Vulkan captures). Zero intensity is byte-exact OFF; 50% matches
the OFF/full midpoint within rounding tolerance; every full style changes
visible pixels. All seven full captures were inspected under
`tmp/vr-colour-style-matrix`. This verifies colour application/intensity, not
independent desktop-effect equivalence or headset performance. The reusable
check is `tools/check_vr_colour_styles.ps1`. Quest APK rebuilt successfully in
19 s including native-colour exemptions; it remains uninstalled. Earlier
statements that the reticle exemption is absent from the APK are superseded.

EX reticle follow-up: DrawPacket now carries `preserve_native_colour` through
resident and fallback draws; source aiming marks and shadows bypass styles.
Exact draw comparison includes the flag so resource reuse cannot retain a stale
policy. Fresh packet and EX cartridge tests pass (23.56 s). This latest change
is local and not yet included in the previously built Quest APK. All-style
GPU pixel verification and physical acceptance remain outstanding.

VR effects follow-up: startup/runtime menus now expose separate model and world
styles with intensity and defaults OFF. Shader-side cel colour bands (models
only), monochrome, sepia, thermal, night vision, pastel and vaporwave are wired
to native Vulkan model/background passes; HUD and menu text remain unchanged.
These are lightweight colour variants, not desktop screen-space outline/bloom
passes. Affine-view packing retains the guaranteed 128-byte push-constant size.
Preferences v4 stores effects, accepts validated v1-v3 records and preserves
default-off migration. All 15 VR tests passed after the camera/shader change;
updated menu and camera tests subsequently pass. GPU OFF regression and sepia
capture pass; `tmp/vr-effect-sepia-current/live-scene-left.bmp` was inspected.
Quest APK compiled in 43 s; subsequent native-shadow style exemption compiles
locally but requires another APK build. Effects are not installed/tested on the
headset. Native EX crosshair effect exemption and all-style pixel tests remain
to be checked. The earlier pending-effects wording below is superseded only
for these implemented styles, not the remaining desktop effects.

Latest user feedback: planet detail is crisp but shimmers with head movement;
the scramble horizon is still sideways; a black ring crosses the 5-1 backdrop;
EX pre-game page 2 shifts relative to pages 1/3. User also requests GPU-backed
2D/3D effects in VR (including cel and sepia). These remain active work, not
accepted features. The local shader now antialiases palette thresholds and
allows transparent orbital atlas samples to reach the surface continuation
instead of discarding the whole fragment. Fresh native Vulkan scene capture,
packet/camera checks and Quest APK build pass; this APK is not installed over
the running PID 15850. The orientation/page-placement reports and VR effects
integration are not fixed by that shader change.

Current local follow-up: surround sampling now uses 512 rather than 256
texels/radian, with matching unique-planet dimensions and orbital pitch.
Corneria and BG 18 rear captures were inspected in `tmp/vr-corneria-smaller`
and `tmp/vr-bg18-smaller`; artwork is smaller and the rear remains populated.
These scale changes are now installed on Quest serial `2G0YC1ZF8R059K`.
The lower hemisphere now uses higher-frequency, stepped-colour detail instead
of the soft gradient. `tmp/vr-ex-horizon-detailed/live-scene-left.bmp` was
inspected: EX 5-1 at tick 60 in VR-world mode has the horizon below the scene
and sharper surface detail. This is synthesized continuation, not new original
planet artwork. Physical acceptance and the reported right-side horizon in
EX 5-1/6-1/7-1 remain open; the desktop capture does not reproduce that report.
All 15 VR tests pass (42.86 s), including the bounded fence-wait change.
The Quest debug APK rebuilt successfully and `adb install -r` returned Success;
the launch intent was sent, but a subsequent PID check found no running game.
Do not count installation as on-headset rendering or performance verification.

EX showcase placement now scales its interpolated centre by 0.375 before both
GPU generation and fallback assembly, retaining original geometry and lighting
depth. Packet-only translation was insufficient for generated models and was
removed. The EX cartridge regression passes; the settled VR-world capture in
`tmp/vr-ex-showcase-pose-settled` shows enlarged visible models. Exact apparent
size relative to the EX logo and physical comfort remain unverified.

BG 18's explicit native-menu regression and rear capture pass. The shared full
atlas path no longer clears authored scroll offsets when scanline deformation
is disabled. Original 1-2 before/after captures place its meteor belt centrally;
EX 1-2 was also rendered. The latest installed APK includes these offset/menu
changes and removal of the title setback, but not the newer scale/showcase edits.
After installation, Quest initially required controllers; subsequent PID 12686
logs prove it ran and later entered XR_SESSION_STATE_IDLE. Sampled slow sections
show about 0.5 ms command submission versus 7–8 ms submission-to-fence observation
per eye, including polling latency; this is not GPU timestamp measurement.

Latest headset feedback rejects background acceptance: artwork is approximately
twice the desired size in menu/gameplay; orbital planet surfaces remain on the
right rather than below; procedural planet continuation is unacceptably blurry;
EX pre-game BG 18 lacks surround; 1-2's meteor band appears above/below rather
than centered. These override earlier desktop visual approvals. BG 18 now has
an explicit sphere/scroll dispatch and the title model's extra two-unit setback
has been removed locally; neither change is yet installed or visually accepted.
EX showcase models still need sizing against the EX logo's apparent size.
The latest screenshot attempt returned a zero-byte file and is not evidence.

Quest deployment update (September 13, 11:42 device time): with explicit user
authorization, stopped the old app and installed the current debug APK using
`adb install -r`; package manager confirmed Success, preserving app data.
QuestActivity cold launch succeeded and new PID 10324 reached OpenXR FOCUSED.
Inspected `tmp/quest-installed-verification.png`: both eye views contain the
Original title logo, characters, ship, PUSH START and surrounding stars. This
proves current on-device rendering, not stereo comfort or all-stage acceptance.
Startup included a 611.599 ms graphics-pipeline creation; telemetry initially
settled at 72/72 FPS but later samples during flow transitions fell to 58/72
with stale frames. Smoothness is therefore not accepted yet. No fatal error
was observed in the sampled process log. These results supersede the old
asleep/PID 10205 deployment blocker below, not other physical-device gaps.

Current Linux validation: the full non-embedded GCC build passes all 49 tests
(197.09 s), plus fresh Vulkan effects and stereo checks. Reconfigured with
release-style embedded patch/symbol resources, rebuilt successfully, and both
embedded startup and multi-region BIN lifecycle tests pass (11.94 s). The
embedded smoke fixture previously waited in the asset picker without a retail
input; it now receives the configured retail ROM and is only registered when
that input exists. This fixes test setup, not a claimed runtime startup defect.
Fresh Linux install manifests contain runtime, asset builder, user docs and
required notices, not development audits or ROM/BIN files. No publication or
physical Steam Deck/Quest acceptance follows from WSL testing.

Latest package audit: Quest was inadvertently bundling the NDK's `libandroid.so`
and `liblog.so` link stubs (their sysroot origin is recorded in AGP native-build
metadata). These are now excluded so the OS supplies the runtime implementations.
`build_quest.ps1` rejects either stub in any ABI. Rebuilt APK and the packaging
guard pass; no headset installation or runtime improvement is claimed. The
current full VR rebuild and all 15 tests pass (42.38 s); generated scene shader
source stamps also pass. Both APKs were refreshed at 04:24 before this additional
Quest-only packaging correction, superseding the historical stale-package notes
below. Regional desktop full-composition checks are complete as detailed below;
physical-device presentation remains unverified.

Colony reference breakthrough: the independent core stalled in the source
custom-rumble wait, not PPU execution. A signature-checked in-memory bypass
plus first-stage selection reaches Colony and reproduces its asymmetric
cross-section. The input ROM file and core source are unchanged; observer and
unmodified-core captures match exactly. These diagnostic overrides prevent
claiming natural-route/full unmodified-ROM parity, but rule against a guessed
renderer mirroring workaround. See BACKGROUND-AUDIT.md for exact evidence.

Regional full-title follow-up: `check_regional_titles.ps1` captures all six
language choices in Original/EX at 16:9/2x, validates title flow and expected
regional composition groups. It exposed a wrapped Original BG3 logo fragment
at x758..759/y64..75. Original title BG3 now stays centered; EX's repeatable
backdrop is unchanged. Native center pixels remain byte-exact for all six
Original choices, and all six EX frames are completely byte-exact before/after.
US/Japan/German/English-Europe and EX full compositions were inspected; fresh
script regressions pass in `tmp/regional-title-regression-{original,ex}`.
This strengthens desktop logo acceptance; headset/other-device titles remain
unverified. Existing Android packages predate this shared desktop-app change.

Latest Original policy audit: all 19 entries complete a 6,000-tick God Mode
preflight; no observed gameplay state selects the flat fallback. A scripted
Game Over still occurs in 2-4. This is mapping evidence, not visual completion.
New diagnostic guard tests pass, and Original Meteor rear was freshly rendered
and inspected. The current Quest APK predates this diagnostic-only CLI option.

Latest surround pass: all 40 EX entries completed a 6,000-tick no-input
policy trace (deaths included, not complete playthroughs). Fixed EX Sector X's
missing planet hemisphere and both cartridges' Meteor star surround. Fresh
EX front/rear images inspected; shared Original/EX regression tests pass
(22.22 s). Quest APK rebuilt successfully in 11 s with these changes, not
installed. Detailed limitations and capture paths: BACKGROUND-AUDIT.md.

Latest desktop regression: full rebuild, **55/55 tests pass (209.76 s)**,
including the standalone unsupported-DXR contract and exhaustive tunnel math.
Regular Android debug build succeeds (22 s). Quest is connected but asleep
(`mWakefulness=Asleep`) with old game PID 10205 suspended; that state cannot
provide current presentation/performance evidence and was not interrupted.

Fresh Original/EX pillar shadow captures pass ground-receiver, native fallback,
removed-override and exact CPU/GPU composition checks. Both DXR images were
inspected. Evidence: `tmp/current-ray-original-pillars/8b747e0f11924581ac58c9d3d41e2e66`
and `tmp/current-ray-ex-pillars/a7c80ef655cd41209000457a93d0a223`.
Explicit test mask requests now opt into diagnostic readback; normal gameplay
remains resident. This diagnostic-only app change postdates the full suite and
was verified by these runtime checks. The regular Android APK predates it.

Follow-up: Original Black Hole's Mode-1 surround omission is fixed and its
before/after rear images inspected. Fresh Original/EX late-Black-Hole VR input
regressions pass (21.35 s). Exhaustive tunnel-gradient input coverage also
passes both simulation-data suites; Colony's source composition is still open.

Latest special-route validation: full `build/vr-dev` rebuild succeeds and all
15 VR tests pass (27.63 s), including Original/EX game input and packet tests.
Quest debug APK rebuilt successfully in 17 s with the dimension, Black Hole,
Comet and planet-surface corrections. Comet front/rear images were inspected;
see BACKGROUND-AUDIT.md. A fresh ADB check still reports game PID 10205, so this
APK has not been installed over the active session. These results supersede
the older VR build/test timings below, not the outstanding visual/device gates.

Device recheck: Quest 3 serial 2G0YC1ZF8R059K is connected/authorized, but
com.starfox.enhanced.quest is running (PID 10205 on this check), installed
September 12 at 23:34. Deployment was intentionally refused before installation.
`deploy_quest.ps1` now checks for a live app and preserves the session; the guard
was exercised against this device. User was asked to close it when convenient.
This is only a device-install gate; local remaining work can continue.

Current complete desktop suite: **54/54** (197.74 s), after a full rebuild and
clean rerun. Three old black-only margin expectations were updated to the
fixtures' actual wall ink, retaining native-center and non-repetition checks.
Current rebuilt VR suite **15/15** (17.25 s), Quest debug package
build successful (19 s). Native Vulkan
and D3D12 shadow diagnostics pass after the initializer warning cleanup.
These suites do not establish all visual/device requirements below.

Fresh targeted checks: regional Original logo selection/upload/save-state tests
pass for all six languages; EX excludes Original replacements. US/Japan/German/
English-Europe isolated-layer BMPs were inspected (`tmp/region-logo-current-original`).
EX Ctrl-F1/F2/F3 real SDL-event save/load/slot checks pass with resident GPU
geometry/shadows; slot-1 overlay inspected (`tmp/state-hotkeys-current-ex`).

Follow-up audit: all 120 EX late captures completed and all 40 ultrawide samples
were inspected. LEVEL6_3 face-planet duplication fixed locally with native-center
byte parity and fresh captures. LEVEL5_2 tunnel margin color is also corrected
with unchanged native-center captures and a colored-wall regression test.
Colony asymmetry remains open. Details are in BACKGROUND-AUDIT.md.
`tools/check_runtime_options.ps1` now automates actual F1 open/resume/reopen
events and captures the menu; Original and EX both pass in fresh processes.
EX captured menu was inspected and shows Experience LOCKED. These event checks
prove opening/resuming, not every option or physical controller interaction.

| Requirement | Evidence and remaining work |
| --- | --- |
| Full GPU migration | Windows SDL Vulkan/D3D12 now have resident models, raster, composition, effects and hardware-shadow transfer. Original/EX 240 Hz captures match. See GPU-MIGRATION-STATUS.md. Broad scenes/effects, other adapters/platforms and performance acceptance remain. |
| VR build | Quest APK builds; 15 VR tests pass after current migration. Valve Index/OpenXR and physical Quest visuals/performance still require acceptance. |
| True ray tracing, default off, no duplicate native shadows | DXR hardware diagnostics and live shadow captures pass. `ray_tracing_{}` defaults off; old enhanced-shadow byte is archive-only. Wider caster/material/scene coverage remains. |
| Issues 43/44/46/47/48/49 | Local fixes and captures indexed in ISSUES-43-49-VERIFICATION.md. Live GitHub recheck: 43/44/46/47/48 open, 49 closed; no new comments. Physical Deck input and Android result/fullscreen checks are not proven. |
| Photographic proof | Actual runtime BMPs are indexed by the feature documents, not generated mockups. No universal all-fixes physical-device proof. |
| ScaleFX | Five-pass CPU/GPU implementation; independent upstream GLSL and 60-case GPU reference checks documented in SCALEFX-STATUS.md. DXIL added and tested. Physical Metal/console coverage remains. |
| Smooth scramble opening | Contiguous horizontal-band interpolation, phase tests and 60/240 Hz source-program captures in PRESENTATION-PARITY.md. Later transitions still part of broad coverage. |
| Comms meter and avatar aspect | Source gate and 32x40 artwork/aspect handling; meter-on/off and Original/EX GPU/software captures in PRESENTATION-PARITY.md. Full language/device coverage not established. |
| Cheats submenu | God Mode, Level Select, Single/Dual/Beam, Infinite Bombs/Boost plus later Infinite Lives present; shared simulation/input/settings tests. Current menu navigation/physical controller acceptance remains. |
| Ctrl-F1/F2/F3 states | Save/load/slot window implemented; Original/EX fresh-process video/PCM continuation, corruption and archive tests in SAVE-STATES-STATUS.md. Broader boss/state/platform coverage remains. |
| Every 16:9+ background | Entry and later sweeps documented in BACKGROUND-AUDIT.md, including 120 completed EX late captures and review of all 40 ultrawide samples. Duplicate face-planets and colored tunnel margins corrected. Colony asymmetry is independently reproduced by the unchanged reference emulator with two diagnostic ROM overrides; do not hide it with a port-only mirror/recolor. Exact synchronized comparison and natural-route coverage remain unproven. VR wrap corrections have separate captures. Do not mark this complete. |
| Upgrade wireframe synchronization | FLASHPLAYER anchored to player interpolation; phase/wrap/recycling tests and 240 Hz turning capture documented in PRESENTATION-PARITY.md. |
| Android system bars | Activity hides bars on create/resume/focus using current and legacy APIs; regular arm64 Android package rebuilt September 13 (24 s), required libraries/manifest verified. Physical navigation-mode acceptance missing. |
| Regional logos | Fresh six-language final GPU title captures pass Original grouping and EX exclusion. US/Japan/German/English-Europe final compositions inspected in `tmp/region-final-current-original`; EX final title inspected in `tmp/region-final-current-ex` (all six hashes identical). This proves this Windows 16:9/2x/tick-200 fixture, not every device. |
| Half/Full SBS | Implemented. Current Vulkan Original Full and EX Half both pass 240 Hz dimension/submission checks with two resident hardware shadow masks. Stereo visual/depth/comfort acceptance remains. |
| F1 in-game options, experience locked | Fresh real SDL F1 open/resume/reopen checks pass in Original and EX; captured EX menu shows Experience LOCKED. Shared input tests reject changing experience. Broader submenu and physical input acceptance remains. |

Next engineering priorities: remaining EX background-transition coverage,
exact synchronized Colony/reference comparison, current cross-platform migration
builds/diagnostics, and a bounded physical headset session when available.
Physical-device gaps do not block these local tasks.
