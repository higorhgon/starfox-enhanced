# Widescreen background audit (local, incomplete)

## EX VR scramble and boss horizon follow-up (September 13)

Fresh 8,000-tick, no-input/God Mode source traces identify the shared
`BG_5_1I` entry for LEVEL5_1/6_1/7_1. All switch to their individual ground
background at tick 179, then to `BG_5_1E` at ticks 2169/2156/2099 respectively.
These are simulation traces, not completed routes or headset acceptance.

Inspected VR-world captures at tick 60 in `tmp/vr-ex-horizon-detailed`,
`tmp/vr-ex-six-entry-current`, and `tmp/vr-ex-seven-entry-current` all show
the planet below the scene. Tick 2200 in `tmp/vr-ex-five-boss-current` also
shows a lower horizon. The shared surface continuation has smaller, stepped
detail instead of a soft gradient; it remains synthesized from source colours.
The capture check now distinguishes the 7-1 scramble from its later landscape
and checks thin-horizon classification at tick 2200 for all three levels.
Physical reports of a right-side horizon remain unverified, not dismissed.
The tick-2200 LEVEL6_1 and LEVEL7_1 Vulkan captures also pass the new
classification assertions and were inspected in `tmp/vr-ex-six-boss-current`
and `tmp/vr-ex-seven-boss-current`: lower planet horizon, visible comms,
no displayed teammate meter in these dialogue frames. Both processes exit 0.
These stationary desktop-eye views do not prove headset orientation handling.

## Independent Colony reference reached (September 13)

The previously stalled reference now has a concrete cause. An optional,
read-only CPU observer linked with the unchanged Snes9x objects reports PC
03:b578/03:b57a at frames 4800/6000. That is PLANETSEQ_L's custom rumble wait;
RUMBLE_CMD/INDEX are zero but RUMBLE_TIME remains 6. The verified bytes are
`a5 ee d0 fc` (LDA $ee; BNE -4). The core source checkout remains unchanged.

`check_reference_video.py --skip-rumble-wait --symbols ...` optionally replaces
only that LDA with LDA #0 in the in-memory ROM, guarded by symbols/signature.
It never writes the input ROM. Together with the existing first-stage pointer
override, this reaches Colony through Controls and the planet map.
`tmp/reference-colony-unmodified-core.png` was rendered by the unmodified
Snes9x DLL at frame 8000 and visually inspected via its identical observer-core
capture: it shows the same asymmetric left transparent/gold wedge and right
opaque wall. Observer and unmodified-core images are byte-exact; the ROM file
hash is unchanged. The observer also matches the earlier unmodified 600-frame
intro capture exactly.

This independently reproduces the asymmetry without changing any PPU/rendering
code. It is **not** an unmodified-ROM or naturally progressed route-2 run:
the two explicit diagnostic overrides remain limitations. Do not mirror or
recolor the port merely to hide this source behavior. Exact synchronized
full-layer comparison and natural-route acceptance remain separate work.

Reproduction input: Start at frames 600..602, 900..902, 1200..1202, 2500..2502,
Down at 3400..3402, Start at 3500..3502, 5000..5002, 6000..6002; 8000 frames;
`--first-stage LEVEL2_6 --skip-rumble-wait`, Original source ROM and symbols.
Observer implementation: `tools/reference_cpu_observer.cpp`; private DLL and
cartridge-containing probe artifacts must not enter release packages.

## Original long policy trace (September 13)

Added the explicit diagnostic `--preflight-invulnerable` option. It enables
the existing God Mode only in preflight, where cartridge saves are disabled;
it does not bypass map scripts or force a stage completion. Argument-guard
tests reject it without preflight, including with a graphics launch.

All 19 Original numbered entries completed 6,000-tick no-input traces using
that option. Every observed gameplay state selected landscape, stars,
space-horizon or tunnel, not the flat fallback. LEVEL2_4 still entered Game
Over at tick 3297; God Mode is not proof against scripted end conditions.
LEVEL1_3 and LEVEL3_4 showed their outdoor/tunnel and video-mode transitions.
These are policy traces, not rendered acceptance of every state or branches.
Original Meteor's fresh tick-1000 rear Vulkan capture passes and was inspected:
`tmp/vr-original-meteor-rear-current` shows stars, without a repeated meteor.

## EX transition-policy sweep and remaining surround fixes (September 13)

All 40 numbered EX entries completed a 6,000-tick `--background-audit`
preflight. This sweep has no input or invulnerability: some runs die and enter
Game Over/Continue/title. Its `flat` label describes tile policy only, not the
flow-specific clear color or world stars. It is not a full-route playthrough.

It exposed EX BG_2_2's explicit exclusion from the orbital surround. Its atlas
(`tmp/ex-sector-x-atlas`) has the same row-424 horizon and small-planet region
as the existing entry mapping. Removed that exclusion. The pre-fix rear
capture `tmp/vr-ex-2-2-audit` failed for blank output; corrected front/rear
captures `tmp/vr-ex-2-2-front-fixed` and `tmp/vr-ex-2-2-surround-fixed` pass and
were inspected: continuous planet surface, stars, and one separate small planet.

BG_3_4B/D also lacked a surround. Both cartridges' BG_3_4B atlases were captured
and inspected (`tmp/ex-meteor-atlas`, `tmp/original-meteor-atlas`); Original
BGS.ASM confirms D uses the same character/map assets. Their planet-free left
half now supplies surrounding stars, with the large meteor emitted once from
320,88,120,120. EX front/rear captures `tmp/vr-ex-meteor-{front,rear}-fixed`
pass native Vulkan checks and were inspected. Shared Original/EX game-input
tests now guard both mappings and pass (22.22 s). Physical acceptance remains.

## Remaining special-route VR surrounds (September 13)

`tmp/vr-blackhole-before` passes GPU diagnostics but its inspected rear image
is flat pink: BG_HOLE lacked a surrounding-sky classification. It now uses a
full authored pattern sphere with source scrolling retained, independently of
the face-planet suppression policy. `tmp/vr-blackhole-surround-fixed` passes
Vulkan scene checks and its rear image was inspected: authored blue/purple
pattern replaces the flat fallback.
Original required a follow-up: its tick-6000 BG_HOLE uses Mode 1, so the initial
Mode-2-only classification still left its rear flat pink. Both 4bpp BG2 modes
are now accepted. Before/after captures `tmp/vr-original-blackhole-current`
and `tmp/vr-original-blackhole-fixed` pass scene diagnostics; both rear images
were inspected and the latter shows the authored purple/blue field. A shared
Original/EX late-stage input regression guards the retained scrolling surround.

EX BG_COMET is also absent from the landscape classification. Its native atlas
was captured and inspected in `tmp/comet-atlas-current`: a heated sky/ground
scene, not a starfield. Added landscape mapping with atlas horizon row 384
(origin 272 plus logical horizon 112), preserving source scale and allowing
the hot ground to continue below the viewer. Front and rear captures at tick
6000 (`tmp/vr-comet-landscape-front` and `tmp/vr-comet-landscape-rear`) were
inspected: both show the heated sky, hot horizon and light ground instead of
a flat fallback. This verifies those static views, not headset motion or all
Comet transitions.

## Original dimension parity extension (September 13)

Original BG_SPECIAL's decoded 512x512 atlas is byte-exact with EX BG_SPECIAL
(`tmp/original-dimension-atlas`). The unique face-planet/saucer policy therefore
also applies to Original. `tmp/original-dimension-after` has fresh three-width
captures; its ultrawide image was inspected and the native center matches the
fresh before image byte-for-byte. VR now classifies Original dimension as a
star surround too. The shader explicitly exempts the native logical window
from duplicate suppression, so strong source distortion cannot erase its ink.
Generated shader/build and Original VR scene checks pass; the front capture in
`tmp/vr-original-dimension-fixed` was inspected. Physical motion/headset
acceptance remains.

## EX special routes, late snapshots (September 13)

Nine additional captures at tick 6000 completed at native/16:9/32:9 widths:
`tmp/ex-special-late-blackhole` and `tmp/ex-special-late-other`. All three
ultrawide samples inspected. Black Hole's abstract field and Comet's heated
landscape fill the margins. Out of This Dimension repeated warped face-planets.
The targeted `tmp/ex-dimension-atlas` capture has a byte-exact decoded 512x512
atlas and tilemap versus BG_6_3H (unused character memory differs). Its EX-only
BG_SPECIAL policy now shares those region definitions. Fresh three-width
captures in `tmp/ex-dimension-after` retain the distortion but remove repeated
planet ink; 32:9 image inspected. Native 4:3 and wide native center are byte-exact
before/after. The first VR rear capture (`tmp/vr-dimension-unique-current`)
passed renderer diagnostics but visibly showed the peach fallback, so it is
not acceptance evidence. Added full star-sphere classification and optional
retention of source scroll/HDMA for face-planet skies, keeping the deliberate
dimension distortion. The corrected rear capture in
`tmp/vr-dimension-surround-fixed` passes Vulkan stereo/depth diagnostics and was
visually inspected: stars replace the peach fallback without duplicate planets.
The retained-HDMA packet regression passes. Headset verification and front-view
motion acceptance remain; these are not full-route/branch proofs.

## EX later-stage sweep completed (September 13)

Completed capture command: `capture_background_audit.ps1 -Experience EX -Ticks
6000 -OutputDirectory tmp/background-audit-later-ex-current`. It visits all
numbered EX entries at native, 16:9 and 32:9 widths: 120 captures, terminal
exit zero. All 40 current 32:9 snapshots have been visually inspected.

These are direct-entry late snapshots, not whole-stage proof. Findings:

- EX LEVEL2_6 and LEVEL4_4 reproduce the asymmetric Colony wedge also present
  in Original; the independent captured-state calibration below does not prove
  natural source-game preparation, so this remains unresolved.
- EX LEVEL6_3 repeats the large orange face-planet and small pink/orange planets
  at the ultrawide margins. Fixed locally after inspecting the BG_6_3H atlas:
  shared desktop/VR rectangles suppress repeated planet/saucer ink while
  retaining surrounding stars. New native/16:9/32:9 captures are in
  `tmp/ex-face-planets-after`; the 32:9 image was inspected. Native 4:3 and the
  32:9 native center are byte-exact versus the before build; 6,764 margin pixels
  changed. VR uses the same region definitions, with the policy stored separately
  from the existing star-atlas row-wrap flag. Its spherical packet path is also
  wired explicitly. Regenerated shader freshness and payload flag tests pass;
  the final rebuilt VR scene check passes, including native Vulkan stereo/depth
  diagnostics. `tmp/vr-face-planets-final/live-scene-left.bmp` was inspected:
  the repeated lower-left planet is gone, with surrounding stars retained.
  Native headset acceptance is still pending. The earlier capture
  `tmp/vr-face-planets-current` predates the spherical-path wiring and must not
  be used as proof of the correction.
- EX LEVEL5_2 uses black wide margins against the tunnel's purple side wall.
  Native atlas captured in `tmp/ex-tunnel-border-before` confirms the purple
  wall. Fixed by sampling its center-height side-wall texel with source HDMA
  offsets; transparent ink falls back to darkest CGRAM. Desktop margins and VR
  surround now share that sample. `tmp/ex-tunnel-border-after` contains fresh
  native/16:9/32:9 captures; the ultrawide image was inspected. Native 4:3 and
  ultrawide center are byte-exact before/after. Colored-wall regression and VR
  packet tests pass. VR rear capture `tmp/vr-tunnel-wall-current` passes native
  Vulkan stereo/depth checks and was inspected: solid purple surround, no
  repeated tunnel cross-section. Quest debug APK rebuilt successfully in 19 s;
  it has not been installed or visually verified on the headset.
  Wide gameplay remains unclipped.

Original LEVEL1_3 was also captured after the wall-color change at 6000 ticks
(`tmp/original-tunnel-wall-regression`), and inspected: solid dark-blue margins
match the wall while foreground objects remain wide. Its native-center bytes
do **not** match the older later-stage audit image, so that old-build comparison
is inconclusive (the old and current model poses also differ). Do not claim
byte parity for this Original capture. Synthetic native-center tests and the
fresh EX before/after comparison above remain the direct regression evidence.

The bounded EX LEVEL6_3 source trace through 8000 ticks changes BG_6_3 to
BG_6_3H at tick 1984 and retains it through tick 8000. This confirms the fixed
atlas is reached by the stage's own transition, not only forced selection;
it does not prove all branch paths or a completed route.
- Other inspected samples show extended terrain/cloud/star fields, including
  the single moon in LEVEL3_3 and the paired planets in LEVEL5_4. LEVEL1_3 and
  LEVEL3_4 keep chamber artwork central with models visible in the margins.
  Foreground bosses obscure parts of several scenes. These samples do not
  establish every transition, palette state, camera angle, or native parity.

Remaining route-6/7 samples show full-width city, volcanic, desert, snow and
cloud backgrounds. Bright HUD colors in some samples warrant separate palette
state review; this capture pass does not establish their correctness.

### Captured-state raster calibration (September 13, follow-up)

Snes9x `gfx.cpp` publishes BG VOFS + 1 for visible line zero; the host isolated
layer samples its row zero directly. The probe now has an explicit
`--host-origin` option subtracting one from static and HDMA VOFS. Raw-register
mode remains the default; this option is coordinate calibration, not a claim
that source-game timing or production scanline parity is correct.

With that option, `reference-bg2-origin.png` matches **all 46,726 opaque pixels
in RGB555** against Colony's isolated BG2. RGB888 maximum difference is two
levels (reference RGB565 expansion). `check_ppu_snapshot.py` reproduces the
comparison and rejects the unadjusted image as a negative control: 2,624
mismatches. It excludes the explicit magenta transparency marker and does not
prove transparency/compositing or source preparation. Both Python tools compile.

Source trace confirms HPOSJMP 4 (TUNNEL2_HOF) selects TUNNELGRAD/MTUNNELGRAD;
at centred view X its base is 128, matching the captured rows. No evidence yet
supports a mirrored wall or altered horizontal base. Production rendering is
unchanged by this diagnostic work. The unresolved visual case remains open.

## Independent captured-state PPU probe (September 13)

Added explicit `-PpuSnapshot` to the bounded background capture tool. It emits
VRAM/CGRAM, BG2 per-row offsets and minimal JSON metadata only when requested.
`create_ppu_snapshot_probe.py` generates a private Mode-1 BG2-only LoROM probe
with DMA uploads and direct per-line HDMA. It contains captured user assets and
must never be distributed or installed into release packages. Source files and
the emulator are not modified. Unsupported modes/invalid payload sizes reject.

Fresh Colony capture: `tmp/colony-ppu-oracle`. Snes9x renders the private probe
to `reference-bg2.png` without needing the stalled Controls transition. Visual
inspection reproduces the transparent-left/opaque-right wedge from the captured
state. This strongly points away from mirroring the host BG2 decoder as a fix,
but does **not** prove correct source-game state or exact raster parity.

Quantitative comparison against host `...-layer2.bmp`: 46,726 opaque host pixels;
8,196 exact RGB matches, 2,624 differ by more than four channel levels, maximum
delta 239. Palette expansion and scanline-origin/HDMA alignment need isolation;
do not describe this as pixel-exact. Shifting the reference up one line reduces
but does not remove discrepancies. Next: calibrate raster timing separately,
then compare source preparation/GSU scrolling rather than invent symmetric art.

September 13 current runtime recheck: `tmp/colony-current-native` contains a
fresh Original LEVEL2_6 tick-1000 native-width capture plus isolated layers and
tilemaps. The final image was inspected and still shows the asymmetric tunnel
(transparent left wedge revealing geometry/sky, opaque right wedge). This
survives the GPU migration. It remains unresolved; do not conceal it with a
widescreen border-only change. Full desktop tests nevertheless pass 54/54,
demonstrating that their coverage is insufficient to prove this visual case.

## Independent reference-video bootstrap (2026-09-11)

The cached full_reference executable remains callable, but its new Colony
source/divided captures and older saved reference frames are entirely black.
Its original main.cpp is missing. Those images cannot prove PPU parity.

A fresh Snes9x checkout from https://github.com/snes9xgit/snes9x.git at
`7a8878f1306f65594c30b7d86dee41d972c2e495` now builds locally under
`tmp/ppu-reference-snes9x`. No source edits were made in that checkout.
Build uses its libretro makefile with local Strawberry CC/CXX/LD, empty LTO,
and Git Bash SHELL; these are invocation overrides, not environment changes.

`tools/check_reference_video.py` is a bounded, muted libretro frontend with
software-video decoding and core default-option negotiation. The latter is
essential: omitting defaults leaves the reference's Super FX clock uninitialized.
With the advertised 100% clock, both supplied Original and EX ROMs produce
nonblank 600-frame captures (`tmp/ppu-reference-smoke.png` and
`tmp/ppu-reference-ex-smoke.png`). An original, asset-free red-backdrop probe
generated by `tools/create_ppu_reference_probe.py` verifies all 57,344 output
pixels are exactly RGB(255,0,0). This calibrates capture, not gameplay parity.

Example: `python tools/check_reference_video.py tmp/ppu-reference-snes9x/libretro/snes9x_libretro.dll upstream-ultrastarfox/SF.SFC tmp/ppu-reference-smoke.png --frames 600 --dll-directory C:/Strawberry/c/bin`.
The DLL directory is process-local. The default run does not patch ROM/RAM or
load states. Optional `--first-stage` performs a signature-checked, in-memory
route-1 pointer substitution without changing the input file. Scripted joypad
input reaches Controls, but leaving it currently freezes the unmodified ROM:
at both 2,400 and 10,000 video frames, read-only WRAM observations show
GAMEFRAME=$00c3 and MAPPTR/MAPBANK=$0d:7bfa (the Controls map loop). Both final
images are black. This is not a slow transition and not caused by the optional
stage pointer override. The new `--watch` option exposes bounded WRAM byte
reads to diagnose it without mutating emulation state. A Colony-specific
reference comparison still needs to be constructed; no Colony renderer
workaround was applied.

`tools/capture_background_audit.ps1` enumerates normal route level symbols,
runs isolated hidden-window fixtures and captures each requested tick/aspect.
It preserves invoking-shell environment settings. Default sampling is 1000
and 6000 ticks at native width, 16:9 and 32:9. These are snapshots, not proof
that every background transition within a stage has been reviewed.

## Original entry sweep

Captured all 19 normal route entries at 1000 ticks, all three aspect ratios:
57 BMPs under `tmp/background-audit-entry-original`. All 19 ultrawide captures
were visually inspected. Terrain/space generally extends, repeating terrain
textures remain repeatable, and Fortuna's distant moon appears only once.
The tunnel sample LEVEL1_3 has solid black margins without repeating artwork.

Two findings require distinguishing different causes:

- **Macbeth LEVEL3_5: fixed.** BGMACS.INC's `undergnd` macro sets INATUNNEL=1
  just as enclosed tunnels do, but uses ROTATE_HOF rather than a closed tunnel
  projection. The port incorrectly filled its outer landscape with black.
  Classification now excludes rotating underground landscapes, while keeping
  tunnel/nograd boss chambers closed and open water expandable. Native 4:3
  Macbeth is byte-identical; 16:9/32:9 now fill the scenery. LEVEL1_3 control
  captures remain byte-identical at all three widths. Source-mode tests cover
  rotate, three tunnel modes and nograd with flag values 0/1/2.
  Windows Original simulation regressions pass. EX Macbeth was also captured
  at all three widths and its 32:9 result visually confirms full-width terrain
  (`tmp/background-audit-macbeth-ex-fixed`); this is not an EX-wide sweep.
- **LEVEL2_6: unresolved.** The direct-entry sample is malformed even at
  native width. This is not classified as a widescreen-only defect. Determine
  whether entry prerequisites or normal gameplay rendering are responsible
  before changing expansion behavior. Further native-width captures at ticks
  100/500/2000 reproduce it, as does EX at 1000: it is not just the first
  captured frame. Isolated BG2 contains the asymmetric opening; BG3 shows
  through its transparent area. Diagnostics report Mode 1, BG2 map 0x7000,
  size 3, characters 0x5000, horizontal/vertical scanline scrolling enabled,
  and horizontal offsets 128 at rows 0/111/223. Missing horizontal-table
  initialization is therefore not supported by this evidence. The source
  BG_2_6A explicitly selects TUNNEL2_HOF with the water macro. Evidence:
  `tmp/level26-diagnostic`, `tmp/level26-phases`, `tmp/level26-ex`.

Use `-Layers` to capture each native BG separately (magenta is transparent)
and log its rendering state; this helps separate source setup/decoding errors
from expansion errors. No LEVEL2_6 rendering workaround has been applied.

![Macbeth before, 32:9](../tmp/background-audit-entry-original/ORIGINAL-LEVEL3_5-1000-32_9.bmp)
![Macbeth after, 32:9](../tmp/background-audit-macbeth-fixed/ORIGINAL-LEVEL3_5-1000-32_9.bmp)

## Remaining coverage

Later samples/background changes, natural-entry
LEVEL2_6 reproduction, and physical platform checks remain. Earlier Titania
water/bridge and Game Over fixes have separate evidence in
ISSUES-43-49-VERIFICATION.md. Do not describe this as an all-level audit pass.

## Colony tunnel archive/transfer isolation

September 13 arithmetic follow-up: the shared simulation regression now checks
MTUNNELGRAD for all 65,536 VIEWPOSX words and every mirrored scanline record.
An independent signed fixed-point product/floor formula agrees with the host's
split carry accumulator, including negative positions and word overflow.
Original and EX simulation-data suites both pass (137.49 s combined parallel
run). This rules out that translated arithmetic, not source camera preparation
or final multi-layer composition; Colony remains unresolved.

### Separate source scroll-override omission fixed

The host disabled tunnel scanline scrolling when BG2VOFSOVERRIDE was set but
did not publish BG2VOFSREQ/BG2HOFSREQ as IRQ.ASM's SETBG2VOFS does. It now writes
both words in source order during the gameplay video phase. The source uses
this path for Game Over and credits. Ending transfer modes retain their own
scroll owner. This is not the LEVEL2_6 asymmetry fix (its override is off).

A regression executes the cartridge's actual SETBG2VOFS after loading its
relocated WRAM code through normal startup and compares the host PPU values
for four requested coordinate pairs. It failed before the fix; Original and
EX full Windows simulation suites pass after it. Disabled-override and ending
isolation cases guard against publishing stale requests into other phases.
No fresh desktop screenshot is claimed: the quarantined desktop executable
has not been rebuilt or bypassed for this check.

Added a cartridge-backed regression at LEVEL2_6 tick 1000 that compares every
decompressed BGCMCCR character byte with live VRAM at VCHR_LOGBACK, and every
BGTSSPCR map word with live VRAM at VSC_BASE2 after the native SCR_OFFSET
adjustment. Both Original and EX full simulation substrate suites pass. Thus
the observed asymmetry is not explained by a dropped/corrupted character or
tilemap transfer in those fixtures. The raw tilemap alone is not proof of a
renderer defect: its authored asymmetry must be interpreted with the source
scrolling, palette and layer composition. Next investigation should compare
that final source composition/HDMA behaviour, rather than mirror the tilemap
or change widescreen sampling. This does not establish visual parity or fix
the tunnel report. Original's suite also reports the existing recovered path
object instruction-limit warning; that separate recovery remains unaudited.

## Original later-stage sweep (6,000 ticks)

Captured all 19 normal routes at 4:3, 16:9 and 32:9: 57 BMPs under
`tmp/background-audit-later-original`. All 19 ultrawide images were visually
inspected. These direct-entry, no-input samples mostly reach boss encounters;
they do not replace a natural playthrough or every intermediate background.

- Corneria/day/sunset, Fortuna clouds, Macbeth's red landscape, space
  starfields and the straight planetary horizons continue into the margins.
- LEVEL1_3 and LEVEL3_4 boss chambers retain solid black outside their native
  tunnel artwork without repeating walls. Objects remain free to draw wide.
- LEVEL1_6/3_7 repeat terrain/mural texture across the landscape; no additional
  isolated distant-planet copy was apparent in these samples.
- LEVEL2_4 is heavily obscured by near-camera geometry. Its visible starfield
  extends, but this image is weak evidence for any hidden background detail.
- LEVEL2_6 remains malformed at 6,000 ticks, including native width. This is
  **not fixed** and is not merely a short entry transition. A targeted layer
  capture in `tmp/level26-later-state` records gameplay flow 9, BG $a5, Mode 1,
  BG2 map $7000/characters $5000, 8x8 tiles and horizontal offsets 128.
  Its raw tilemap view already contains the transparent left triangle and
  opaque right triangle, so an extra-margin sampling change would not address
  the native asymmetry. Source/reference and natural-entry investigation remain.

The capture tool now records reached flow/background state for future runs and
validates requested ticks against the runtime's 0..8,000 limit. A request for
8,001 is verified rejected rather than silently becoming an 8,000-tick image.
The 57-image sweep predates the new state-log option; the targeted LEVEL2_6
diagnostic exercises it. EX later-stage and natural-transition coverage remain.

![Later Macbeth landscape](../tmp/background-audit-later-original/ORIGINAL-LEVEL3_5-6000-32_9.bmp)
![Later tunnel boss, solid margins](../tmp/background-audit-later-original/ORIGINAL-LEVEL3_4-6000-32_9.bmp)
![Unresolved native LEVEL2_6](../tmp/level26-later-state/ORIGINAL-LEVEL2_6-6000-4_3.bmp)

## BG3 camera-scroll transfer restored

Tracing LEVEL2_6 exposed a separate omitted source operation. TRANS.ASM's
`TRANSFER_L` snapshots `VIEWPT.AL_WORLDX`, arithmetic-shifts it right three
times and subtracts four into `BG3SCROLL` when enabled. IRQ.ASM's `FOXIRQ3`
then writes that saved word into BG3HOFS. The host now mirrors both steps:
capture before strategies, publish during the gameplay video phase. It does
not derive scrolling from a newer camera position or overwrite ending mode.

Original and EX Windows full simulation-data tests pass, including seven
camera positions from -32768 through 32767, negative division rounding,
disabled-transfer preservation, signed PPU publication and ending isolation.
Linux Original and EX full simulation-data tests also pass.

This correction does **not** resolve LEVEL2_6's asymmetric map: new native and
wide captures in `tmp/bg3-scroll-level26-fixed` still show it. Original
LEVEL2_3 entry control captures remain unchanged; the separately invoked
Titania bridge/water scene still renders correctly at 32:9 in
`tmp/bg3-scroll-titania-end`. No arbitrary fill or mirrored-wall workaround
was applied to disguise the remaining native defect.

## Headless transition coverage supplement

`starfox_background_transition_check ROM SYMBOLS LEVEL TICKS` records changes
to flow, requested background ID, PPU mode and BG2 map/character layout at each
source tick (1–8000). It uses god mode, no input, unlocked 20 FPS logic and
native SPC feedback. It does not create a window or render frames. This profile
is explicit and should not be confused with the original-speed capture sweep.

Windows runs through 6000 ticks show:

| Route | Metadata changes |
| --- | --- |
| Original LEVEL2_6 | BG 165 throughout; Mode 2 becomes Mode 1 at tick 1 |
| EX LEVEL4_4 | BG 291/Mode 2 → BG 105/Mode 2 at 187 → BG 237/Mode 1 at 328 |
| EX LEVEL6_2 | BG 369/Mode 2 throughout |

Linux reproduces LEVEL4_4's two transitions through tick 600. The 1000-tick
entry image therefore misses its first two backgrounds. Follow-up visual
samples should straddle ticks 186/188 and 327/329 using the same timing/input
profile. LEVEL2_6's later asymmetry cannot be explained by a background-ID
switch in this run; tile/palette/scroll changes within an ID remain possible.
These are coverage findings, not new visual fixes or completed route proof.

The log now resolves BGLISTS-relative names and records tunnel classification,
scanline scrolling and request-pending state. EX LEVEL4_4's backgrounds are
BG_3_5 (underground/rotate), BG_1_3DA (nucleus entrance/nograd), and BG_2_6A
(colony/tunnel2), matching the source BGS.ASM routines. At tick 187 the entrance
is installed with `request_pending=0`, but `tunnel_scene` only becomes true at
188. At 328 the colony Mode 1 background is installed while the old tunnel bit
remains; at 329 it becomes false and scanline scrolling becomes true. This
identified a host metadata timing discrepancy at transfer completion.

The transfer service now refreshes presentation-only tunnel/scanline metadata
after native background setup. It does not repeat scroll-register writes or
advance the raster; reads use mapped RAM/ROM without touching I/O or open bus.
Windows and Linux 600-tick checks now install the entrance classification at
187 and colony scanline classification at 328, with no delayed metadata-only
changes at 188/329. A CPU-state regression checks that refreshing already-current
metadata preserves the entire saved state, including scroll latches and bus.
This fixes the measured metadata lag, not a claim that every expansion is
visually correct; captures around these boundaries remain pending.

### Isolated transition images

The headless transition diagnostic optionally accepts a new output directory.
It refuses existing directories and writes final-tick BG2-only BMPs at widths
256/400/800 using PPU scroll registers and CGRAM. These intentionally omit other
layers, source brightness and host scroll interpolation, so they are diagnostic
images, not final-game screenshots or release proof.

Windows EX LEVEL4_4 ticks 187/327/328 are captured in
`tmp/bg2-ppu-transition-{187,327,328}`. Visually inspected 800px images and
tick 328's 256px image: the colony cross-section is asymmetric at native width
too (blue left, dark right), immediately after installing BG_2_6A. Thus the
metadata synchronization fix does not resolve this remaining image problem,
and widescreen extension alone cannot explain it. Tick 327's preceding BG2
cross-section is symmetric with solid outer margins. Further tile/scroll/source
phase comparison remains necessary before changing the authored expansion.

The diagnostic also logs requested versus PPU BG2 scroll and separately writes
requested-scroll BG2 and BG3 images. EX LEVEL4_4 at ticks 328 and 600 reports
both scroll pairs as `(0,248)`, with main-screen mask 23. Thus choosing those
two scroll sources cannot explain this fixture's difference. The tick-328 BG3
capture contains mountain/star artwork, not a complementary tunnel wall. Files
are in `tmp/bg2-scroll-layers-{328,600}`. These isolated layers still do not prove
the final composed scene; source transfer/tilemap comparison remains open.

The headless diagnostic now checks BG_2_6A's live character bytes and tilemap
words against the active cartridge's BGCMCCR/BGTSSPCR archives, applying its
SCR_OFFSET exactly as the source transfer does. Windows EX ticks 328 and 600
both match all 2,048 character bytes and 4,096 map words; Original LEVEL2_6 at
tick 1000 does too. There is no transfer corruption in those samples. The open
question is how the valid source data should be sampled/composed, not whether
the archived tilemap reached VRAM intact. This does not validate all other
background transfers or palettes.

An independent diagnostic Mode 1/8x8 decoder now reads screen pages, tile
attributes/flips and four bitplanes directly from VRAM, using the published
per-row scroll metadata but none of BackgroundRenderer's expansion heuristics.
EX tick 328 matches all 57,344 native pixels (`direct_mode1_decoder_changed_pixels=0`);
capture: `tmp/bg2-direct-decoder-328c/direct-mode1-bg2-256.bmp`.
Horizontal row offsets are enabled in this fixture; the Mode 2 vertical-offset
flag is also set but correctly has no effect in Mode 1. Tile decoding and
centre expansion are not the discrepancy in this sample. Next compare the
published per-row scroll metadata against native source calculations; this
oracle shares that metadata and therefore cannot independently validate it.

The diagnostic now compares horizontal metadata directly with the native
DMAHPOS destination selected by HDMABG2HOFS2, explicitly reading bank $7E
(the table offsets are not low-bank I/O addresses). EX LEVEL4_4 tick 600 and
Original LEVEL2_6 tick 1000 each contain 224 records with count 1, and all 224
scroll words match the published metadata. This validates the capture step,
not the correctness of upstream scroll-generation inputs or final composition.

Live input logging confirms HPOSJMP=4 (TUNNEL2_HOF) and VIEWPOSX=M_VIEWPOSX=0
in both of those samples. A separate 64-bit fixed-point reference, derived from
MHOFS.MC's signed gradient and accumulator, matches all 224 output rows. This
only validates these zero-camera-X samples; it is not a boundary-value proof
of every gradient or a full SNES PPU comparison. The apparent asymmetry is not
explained by a wrong horizontal dispatch or the captured zero-input gradient.

The same diagnostic now forks the completed state and invokes DO_HPOSITIONS_L
with 25 signed camera-X inputs spanning -32768..32767, including quarter-step
and accumulator carry boundaries. It compares both symmetric halves and every
record count directly in BG_SCROLLBUFFER against the independent fixed-point
reference. Original and EX each pass 5,600 rows on Windows. The live sample is
not mutated by this probe. This strengthens the horizontal-generator check;
it is not exhaustive input coverage or an independent full Super FX execution.

## EX entry sweep and special-route samples

Captured all 40 EX normal route entries at 1000 ticks and three widths
(120 BMPs in `tmp/background-audit-entry-ex`). Visually inspected all 40
32:9 images. This sweep found additional problems rather than establishing
an all-clear:

- LEVEL3_4 duplicated its distant planet at the right edge. The BG_3_4B
  approach and BG_3_4D departure now use one tilemap occurrence outside the
  native window, across the full height. This does not change repeatable
  terrain/cloud backgrounds. EX 4:3 is byte-identical; the new 32:9 capture
  visibly removes the second planet (`tmp/background-audit-planet-fixed-ex`).
  Original also retains a byte-identical 4:3 capture. Windows build and
  substrate regressions pass, including single-occurrence checks at widths
  256/400/800 and unchanged native-window pixels.
- LEVEL4_4 shares the asymmetric tunnel/water appearance seen in LEVEL2_6;
  its source/setup cause remains unresolved.
- **LEVEL5_4: fixed locally.** The planets share a 512x512 BG2 tilemap with
  repeating clouds/terrain. BG_5_4 now applies two source-coordinate/indexed-
  colour masks only to extra map occurrences outside the native window.
  The large planet includes its white crescent; the smaller one's mask keeps
  cloud pixels sharing its tiles. Replacement uses the authored sky index,
  so it follows palette changes instead of assuming RGB black or blue.
  Wrapped scroll 8191 is treated as -1 when anchoring the unique occurrence.
  Entry and later boss captures (ticks 1000/3000, all three widths) retain one
  complete pair and surrounding clouds (`tmp/background-audit-level54-final`).
  Native 4:3 at tick 1000 is byte-identical. Earlier `level54-fixed` captures
  are rejected development iterations, not proof of the final fix.
  Windows/Linux focused regressions cover native/16:9/32:9 widths, retained
  cloud indices, and equivalent scroll values -1/8191.
- **LEVEL6_2: fixed locally.** Its stripes also occurred at native width.
  Valid Mode 2 per-tile vertical offsets were incorrectly losing precedence
  to scanline BG2VOFS. They now replace that register; invalid entries keep
  the scanline value. This agrees with the replacement order in
  [bsnes's background renderer](https://github.com/bsnes-emu/bsnes/blob/master/bsnes/sfc/ppu-fast/background.cpp).
  A second issue clamped Mode 2 open-water scenery as if it were Mode 1's
  singular bridge cross-section. That restriction now applies only to Mode 1.
  New 4:3/16:9/32:9 captures show continuous water and sky
  (`tmp/background-audit-level62-fixed`). The Original LEVEL1_3/2_3/2_6
  control captures remain byte-identical at all three widths after the offset
  precedence correction (`tmp/background-audit-offset-controls`).
  A later 3000-tick sample at all three widths retains the corrected ocean,
  including the boss scene (`tmp/background-audit-level62-later`). Focused
  Windows/Linux renderer substrate tests pass for valid/invalid offset
  precedence and Mode 1 bridge versus Mode 2 scenery wrapping.
  Windows Original and EX full simulation-data regressions also pass.
- **LEVEL6_4: not a background-expansion defect.** The final frame has a
  dark wedge at the extreme right, but the isolated expanded BG2 capture
  has continuous ground there. It is introduced by a later render layer,
  not by ground wrapping/continuation. No terrain workaround was applied.
  Evidence: `tmp/background-audit-level64-isolated`, including the final
  frame and `-layer-bg2-expanded.bmp`. Whether the foreground geometry itself
  is appropriate requires a separate object/scene check.

Also captured Original Black Hole/Out of This Dimension and EX Black Hole/
Out of This Dimension/Comet at three widths (15 BMPs), inspecting their 32:9
samples. Evidence: `tmp/background-audit-special-original` and
`tmp/background-audit-special-ex`. These are direct-entry snapshots, not
natural transition or complete level coverage. Their patterned backgrounds
extend; whether every authored motif should repeat still needs source/reference
comparison. The harness now accepts these symbol-validated special routes
explicitly, or includes them with `-IncludeSpecialRoutes`.

![EX distant planet before](../tmp/background-audit-entry-ex/EX-LEVEL3_4-1000-32_9.bmp)
![EX distant planet after](../tmp/background-audit-planet-fixed-ex/EX-LEVEL3_4-1000-32_9.bmp)

![EX water before](../tmp/background-audit-entry-ex/EX-LEVEL6_2-1000-32_9.bmp)
![EX water after](../tmp/background-audit-level62-fixed/EX-LEVEL6_2-1000-32_9.bmp)

![EX twin planets before](../tmp/background-audit-entry-ex/EX-LEVEL5_4-1000-32_9.bmp)
![EX twin planets after](../tmp/background-audit-level54-final/EX-LEVEL5_4-1000-32_9.bmp)

`-Layers` now also saves an unscrolled BG2 view and full 8x8-character tilemap,
and logs native SETBG2VOFS/XHDMA_BG2VOFS bytes. For LEVEL6_2 the native routine
confirms scroll constants 24/280 match the host: those values were not the
cause. Diagnostics are gated behind the existing test/capture hooks.
It additionally saves expanded BG2 in isolation, so foreground geometry is
not mistaken for missing background coverage.
