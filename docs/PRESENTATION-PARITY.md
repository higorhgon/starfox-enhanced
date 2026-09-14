# Presentation parity checks (unreleased)

## Current EX native-width final target (September 12)

Fresh EX 4:3, 2x, message 1 at 60 presentations: final GPU and software
597x448 BMPs match byte-for-byte (SHA256
896021E0302D9570E868D036E318564761BFA4DAF3A0A777108002E23EC3121E).
Visually inspected `tmp/comms-ex-native-gpu-final.bmp`; reference is
`tmp/comms-ex-native-cpu-final.bmp`. Logs confirm resident GPU geometry/raster.
This message depicts Fox, not Falco: it proves final-target portrait aspect
agreement, not a teammate-meter timing test or all-language coverage.
The capture tool now accepts explicit -Renderer GPU/SOFTWARE and -FinalTarget
to capture presentation.bmp with the required startup-preroll skip.

## Scramble shutter

`SF/MARIO/MDATA.MC:MSCRAMWIPE` opens a horizontal band eight source
scanlines per edge per update. Interpolating the left/right mask values of
each changing row produced vertical slits instead of moving horizontal edges.
The host now recognizes that exact contiguous band pattern and interpolates
its top/bottom in source-line units, applying the mask at output-pixel
precision. Other wipe patterns retain their table interpolation. Completion
still follows the source transition, without an extra held frame.

Tests cover twelve fractional phases (240 FPS over 20 Hz), exact band bounds,
unchanged row masks, rejection of noncontiguous masks, and normal wipe cuts.
Runtime source-program captures:

- [240 FPS widescreen](../tmp/scramble-240-fixed/000070.bmp)
- [60 FPS 4:3](../tmp/scramble-60-4x3-fixed/000020.bmp)

These are captures of the actual source wipe program triggered through its
native animation register, not mockups. The 144-frame 240 FPS capture has 88
distinct visible top-edge positions measured from the BMP centre column;
frames 52-67 progress from row 213 to 202 instead of holding source-sized
eight-line jumps. This sample does not claim to cover every level transition.

## Upgrade wireframe

`SF/STRAT/GASTRATS.ASM:FLASHPLAYER_STRAT` copies the player's position and
rotation but alternates between NULLSHAPE and the wire model. The generic
shape-change guard consequently discarded its motion history on each flash.
Presentation now anchors only this named attached effect to the same player
snapshots. Shape/blink/colour timing remains native. Missing/recycled owners
and owner shape/strategy changes use the same history cuts as the player.

Tests compare position and rotation across twelve subframes, coordinate wrap,
source blink identity and recycled player slots. A source FLASHPLAYER effect
while holding Right at 240 FPS is visible in this
[runtime capture](../tmp/upgrade-240-fixed/000070.bmp).

## Optional teammate meter

`SF/ASM/CONTINUE.ASM:FRIENDS_MESSAGES_L` shows MSHOWTEAMMATE2 only while
FRIENDS_METER is active and the portrait has finished opening. It raises the
message by sixteen pixels to make room. The host dialogue state and HUD now
consume that source gate and animated health value. Opening/closing frames,
ordinary calls, Fox/non-team speakers and EX's alternate channel do not inherit
a teammate bar.

Source-requested Falco call at the same capture frame:

- [Meter requested](../tmp/comms-falco-meter/000050.bmp)
- [No meter requested](../tmp/comms-falco-no-meter/000050.bmp)
- [EX meter requested](../tmp/comms-ex-falco-meter/000050.bmp)

The source portrait copy and host decoder both use 32x40 pixels / 640 bytes.
The 4:3 presenter was incorrectly displaying a square-pixel 256x224 (8:7)
canvas. Its final presentation now uses a 4:3 extent, without resampling the
game raster or changing portrait decoding. Windowed dimensions and pointer
coordinates use the same correction. Tests cover 1x/2x/4x/10x and ensure
widescreen canvases remain unchanged.

Actual software-renderer output at 2x is 597x448 (rounded 4:3), rather than
512x448. Captured through SDL to an off-screen presentation target:

![Corrected 4:3 comms proportions](../tmp/comms-aspect-4x3-software-display.bmp)

Reproduce with STARFOX_TEST_RENDERER=SOFTWARE,
STARFOX_TEST_SKIP_PREROLL=1 and STARFOX_CAPTURE_PRESENTATION_PATH, then
tools/capture_presentation.ps1 -DisplayMode 4_3 -Message 1 -Frames 60.
The ordinary numbered BMPs preserve the source raster and intentionally do
not reflect display-aspect correction. Omitting SKIP_PREROLL can capture the
black startup preroll instead. GPU target readback produced an unreliable
uniform-colour image and is not counted as visual proof. The separate
widescreen portrait discrepancy is addressed separately below.

Rechecked after the desktop build was restored: the current resident GPU path
now produces a valid final presentation readback. Fresh Original GPU and
software captures at 60 FPS/60 presentations, message 1 and 4:3 are both
597x448 and byte-identical (SHA256
`FDCA49D9960249BA63BFBDEC71C5C915AEB860ADE83014B1BF9B1C0A237DB6CB`).
The GPU runtime log confirms resident raster/composition/effects/presentation.
This supersedes the earlier failed-readback observation for this fixture.

![Current GPU 4:3 comms presentation](../tmp/comms-gpu-presentation-restored.bmp)

Reference: `tmp/comms-software-presentation-restored.bmp`; logs and source
frames: `tmp/comms-gpu-presentation-frames` and
`tmp/comms-software-presentation-frames`. This is an Original 2x display
fixture, not verification of every language, platform or display mode.

Widescreen uses square output pixels and did not receive the native canvas's
7:6 horizontal pixel-aspect correction. Comms portraits now apply that ratio
at stored-pixel resolution, retaining their original height and right edge.
Text/meter coordinates, wrapping and custom HUD offsets are unchanged. Native
width and non-comms portraits retain their existing rendering. Tests compare
every resampled pixel against the original decoded face at 1x/2x/4x/10x and
verify the unchanged height/right edge and untouched surrounding pixels.

![Original widescreen corrected comms](../tmp/comms-aspect-wide-fixed/000059.bmp)
![EX ultrawide corrected comms](../tmp/comms-aspect-ex-wide-fixed/000059.bmp)

`tools/capture_presentation.ps1` provides source-message, shutter and upgrade
fixtures without saving settings. `STARFOX_TEST_PRESSES` accepts frame:mask
input for moving-ship capture. All hooks require STARFOX_TEST_FRAMES.

Verification: Windows builds succeed; Original/EX simulation and hit-list
suites pass (4/4). Linux builds succeed and Original/EX hit-list/transition
suites pass (4/4). Those suite counts predate the widescreen portrait update;
its Windows/Linux Original simulation regressions and Windows Original/EX
runtime captures pass separately.

## EX title widescreen guards

The EX BG1 diagnostic capture identifies two opaque 16-pixel guard columns
outside the 224-pixel Super FX bitmap. In widescreen title presentation, both
the background pass and restored foreground pass now omit these guards.
Interior opaque black text remains opaque; native-width presentation is
unchanged. Substrate tests cover both guard edges and retained interior ink.

Matched Windows EX TITLEMAP captures (300 preroll ticks, 180 frames, 16:9, 2x):

![Before title guard removal](../tmp/title-guards-before.bmp)
![After title guard removal](../tmp/title-guards-after.bmp)
![BG1 diagnostic: magenta is transparent](../tmp/title-guards-layer1.bmp)
