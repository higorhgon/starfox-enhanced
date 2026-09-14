# Requested issue verification

## Reproducible current GPU handoff (September 13)

`tools/package_pc_quest.ps1` installs into a fresh unique directory, adds the
tracked player instructions and Quest APK, and checks the exact ten-file list
and current binary hashes before moving the archive to its requested path.
Existing archives are refused (guard tested); no earlier handoff is overwritten.
It never runs the game in the package directory. Failed candidates remain in
their unique temporary directory for inspection rather than being published.

Current development archive: `tmp/StarFox-Enhanced-PC-Quest-GPU-current-20260913.zip`
(13,045,300 bytes), SHA256
`37D13B5F12FB6A31C11B418192D00434640307B35F20F02CE636AE51C9ED6D6A`.
The APK and both executables match the current builds; no ROM/BIN, saves,
settings, add-ons or development audits are included. This supersedes the
older archive below, which remains preserved. Nothing was released or installed.

All Windows and Linux targets rebuilt against the Controls/caster migration.
Fresh full suites pass: Windows 55/55 (263.44 s), Linux 54/54 (277.00 s),
and the separately rebuilt Windows VR suite 15/15 (46.96 s). These concurrent
test durations are not performance benchmarks.
Quest and regular Android debug builds both succeed; the Android APK contains
its nonempty arm64 main/SDL/C++ libraries and manifest. Generated Metal literal
length and Gradle deprecation warnings remain non-fatal. This does not replace
physical device acceptance. All six requested issue bodies/comments were
re-read through GitHub; no new reports change the outstanding Deck/Android gaps.

## Clean handoff package regression (September 13)

Added `tools/check_pc_quest_package.ps1`: exact ten-file allowlist, duplicate/
empty-entry rejection, full entry decompression, and optional hashes against
the current APK and both Windows executables. A settings-contaminated archive
is rejected. The earlier smoke-run staging directory had generated BIN/config/
save files, so packaging now uses a fresh install directory rather than that
directory. No files from the contaminated directory were deleted.

`tmp/StarFox-Enhanced-PC-Quest-development-current.zip` passes the checker with
`-VerifyCurrentBuild`; no ROM/BIN, saves, settings, DLL add-ons or development
audits are included. SHA256:
`1CF1ADA64CB53DE8372ABAEB5B041DF23D86FB0F1D827785AC5B42CFC9494D22`.
The packaged asset-builder binary generated and validated a retail-derived BIN
in `tmp/asset-builder-current-check`, outside the package. No release was pushed.

## Regular Android shared-background refresh (September 13)

`:app:assembleDebug` succeeds in 24 s after the selective face-planet and
source tunnel-wall changes. APK inspection confirms nonempty arm64 libmain,
SDL3, C++ runtime and manifest entries. The activity still hides system bars on
create/resume/focus through current Insets and legacy immersive APIs. No device
installation or visual acceptance is implied. Non-fatal build warnings remain:
unused parameters in unsupported DXR stubs, long generated Metal literals, and
Gradle deprecations. These did not prevent native compilation or packaging.

September 13 live recheck: #43/#44/#46/#47/#48 remain open, #49 closed. No new
comments change the evidence or outstanding physical Deck/Android checks.

## Regular Android build refresh (September 12)

Fresh workspace-local `:app:assembleDebug` succeeded in 1m29s (35 tasks),
using the installed SDK/NDK/JDK. This builds the regular SDL Android app,
not Quest, including current shared HUD/comms code and fullscreen activity.
Inspected app-debug.apk: nonempty arm64-v8a libmain.so, libSDL3.so,
libc++_shared.so and AndroidManifest.xml are present. No installation or
publication was performed. Compilation/packaging does not prove Android
results-screen visuals or gesture/three-button navigation behavior.

GitHub bodies/comments rechecked: #43/#44/#46/#47/#48 remain open with no
new comments, #49 remains closed. Physical Deck mapping and Android visual
acceptance remain outstanding; issue states were not modified.

## Current authored Titania ending verification (2026-09-12)

Re-ran the native SETBG 2_3b map-command fixture, not a guessed elapsed
stage time. Current Windows GPU captures were visually inspected:

- `tmp/issue48-ending-current-16/titania.bmp`: Original 16:9.
- `tmp/issue48-ending-current-32/titania.bmp`: Original 32:9.
- `tmp/issue48-ending-current-ex/titania.bmp`: EX 16:9.

All show sky/mountains/water filling both margins and a single central bridge
cross-section, without repeated bridge wedges at the outer edges. Runtime
trace confirms Mode 1 with water scanline mode (hofs=1). The capture script
now requires this state and retains its process handle for reliable ExitCode.
VR native Vulkan fixture also passed and its forward-eye image was inspected:
`tmp/issue48-water-vr-current/live-scene-left.bmp` (Original, background 147,
Mode 1, 200 ticks after the authored water command). This is offscreen Vulkan
evidence, not a new physical headset acceptance run or complete playthrough.


2026-09-12 latest GitHub recheck: #43/#44/#46/#47/#48 remain OPEN and #49 CLOSED;
no new comments beyond the previously recorded reports. Rebuilt
starfox_transition_parity_tests against current shared core and reran both
Original and EX cartridge fixtures successfully. This is automated transition
regression evidence, not physical Steam Deck/Android acceptance or issue closure.

2026-09-12: rebuilt and reran transition parity against Original and EX ROMs.
Corrected the revival fixture to explicitly select EX simulation behavior for
EX assets (the constructor defaults to Original). Both modes pass the Corneria
and bottom-route meteor palette-row restoration checks. This strengthens the
automated checkpoint regression; it does not verify the reporter's Falco ship
configuration or replace physical-device acceptance.

Reports and comments inspected through GitHub on 2026-09-09. No issue closure
or release publication is implied by this local checklist.

Live GitHub recheck on 2026-09-11: #43, #44, #46, #47 and #48 remain OPEN;
#49 remains CLOSED. Current report bodies still identify #43 as EX bottom-route
meteor death tint and #47 as Android tally/HUD/alignment. #44 still has only
the unanswered Steam Input question; #47 has no comments. Local Windows and
virtual-device results below do not close the physical Deck/Android gaps.

Rechecked #43 and #44 on 2026-09-10: no new comments/evidence. #44 still has
only the Steam Input clarification question, with no reporter answer; physical
Deck verification remains open rather than inferred from local input tests.

| Issue | Reported case | Status / required evidence |
| --- | --- | --- |
| [43](https://github.com/kandowontu/starfox-enhanced/issues/43) | EX original pacing, bottom-route meteor stage; red tint survives death | Fixed locally: restore model palette row seven from the selected GAMEPALBUFF after checkpoint background requests. Regression failed on EX LEVEL3_2 before the change and passes for both Original/EX, Corneria/meteor stages afterward. Actual death/respawn captures below. |
| [44](https://github.com/kandowontu/starfox-enhanced/issues/44) | Steam Deck controls mapped to desktop actions; system buttons unavailable | Removed application Deck HIDAPI override that bypassed a launcher's global HIDAPI disable. Regression tests cover inheritance and explicit device enable/disable. This fixes a verified backend-policy conflict, not yet the entire report: physical Deck/Steam Input verification remains. |
| [46](https://github.com/kandowontu/starfox-enhanced/issues/46) | Extend Game Over stars into widescreen margins | Fixed locally: draw the existing world-space stars into only the added margins, after the solid backdrop fill. The native artwork remains untouched. Captured Original 16:9 and EX 32:9; source-width exclusion tested at 1x/2x/4x. |
| [47](https://github.com/kandowontu/starfox-enhanced/issues/47) | Missing completion bar/HUD and total score alignment, Android | Fixed locally in shared rendering: restore MSHOWPERCGRAPH geometry/colours, retain native meters at tally entry, draw HUD sprites above models and right-align percentage/total to Slippy's frame. Matching Windows runtime captures below; Android-device verification remains. |
| [48](https://github.com/kandowontu/starfox-enhanced/issues/48) | Titania ending area background remains 4:3 | Fixed locally: distinguish open water (INATUNNEL=2) from enclosed tunnels (1), and extend one bridge cross-section without repeating it at ultrawide edges. Windows Original 16:9/32:9 and EX 16:9 captures; water/bridge/tunnel substrate regressions pass. |
| [49](https://github.com/kandowontu/starfox-enhanced/issues/49) | Development documentation in release package | Already closed on GitHub, but install rules still shipped audits. Removed those rules locally; font notices retained under licenses/fonts. Verified fresh installation into tmp/package-issue49-check: only two executables, README, credits, third-party notices, xBRZ licence and font notices; no docs folder. |

Visual evidence should be actual runtime captures, not generated illustrations.
Nonvisual changes require tests or package manifests rather than decorative screenshots.

## Issue 44 route diagnostic

2026-09-10 additional compatibility change: identify Steam Input by Valve's
28de:11ff virtual-gamepad ID as well as its name. Prefer that stream for a
single player and exclude the duplicate raw Deck (28de:1205/name) when Steam's
virtual controller is present. Otherwise retain native SDL Deck handling;
do not override global HIDAPI policy or rewrite the user's remappings.
Windows SDL virtual-device tests verify selection, native fallback after
disconnect, no duplicate EX player, all 12 standard buttons, and no game action
from Steam/Quick Access buttons. Physical SteamOS/system-menu behavior is not
yet verified. This cannot transform a Steam desktop keyboard-only profile
into gamepad events when no controller stream is exposed.

References: [Valve gamepad emulation](https://partner.steamgames.com/doc/features/steam_controller/steam_input_gamepad_emulation_bestpractices)
and [SDL native Deck driver policy](https://wiki.libsdl.org/SDL3/SDL_HINT_JOYSTICK_HIDAPI_STEAMDECK).

Rechecked the live issue on 2026-09-10: it remains open; the sole comment asks
whether Steam Input is being used. Keyboard-layout emulation is a plausible
explanation, not a verified diagnosis. No physical Deck is available locally.

The developer build now has `starfox_controller_check` (not installed into
release packages). `--snapshot` reports SDL version/platform, effective HIDAPI
policy, whether Steam launch context exists, and joystick mapping/vendor/product
information. It does not dump environment values, device paths or serials.
`--seconds 15` opens a bounded diagnostic window and the same preferred gamepad
as the game; while focused it counts gamepad/axis and keyboard events. Only
Enter/Escape/Tab are named; other keys are redacted and no text is captured.
Escape exits early; the maximum duration is 30 seconds. Run from the same
Steam shortcut/layout as the game when checking that route, then compare with
a direct launch. The tool does not change Steam configuration or bindings.

Windows/Linux builds and snapshot checks pass; Windows dummy-window lifecycle
also passes with no attached controllers. This is diagnostic tooling, not resolution or physical verification
of issue 44. Its output should determine whether further work belongs in input
selection/mapping or Steam launch configuration before changing either.

## Issue 48 captured evidence

Current-build refresh (2026-09-10): rebuilt `build/current/starfox_pc.exe` and
captured Original/EX at 4:3, 16:9 and 32:9. The capture script now isolates and
restores diagnostic environment settings, forces original pacing/GPU rendering,
disables optional visual effects and records the reached render state. Both
logs report GPU-resident raster, Mode 1, BG2 scanline scrolling; background IDs
are `$93` (Original) and `$cf` (EX). The four wide captures were visually reviewed:
one central bridge cross-section, with water/sky continuing through the margins.

Against each game's fresh 4:3 reference, the central 512 stored pixels at rows
80..219 are byte-identical at both wide ratios (71,680 RGB pixels per comparison).
This is a background-band preservation check, not whole-HUD or full-level parity.
Current captures live in `tmp/titania-current-{original,ex}-{native,16,wide}`.

![Current Original 32:9](../tmp/titania-current-original-wide/titania.bmp)
![Current EX 32:9](../tmp/titania-current-ex-wide/titania.bmp)

`tools/capture_titania.ps1` enters the cartridge's authored BG_2_3B command,
including its native initializer and water scanline program. BGMACS.INC assigns
INATUNNEL=1 for enclosed tunnels and 2 for water; treating both as tunnels
incorrectly blacked out Titania's added columns. The water layer now extends
its edge material while BG3 continues the mountain/sky backdrop. A contrasting
bridge fixture verifies that the central cross-section does not repeat at
400- or 796-pixel widths; separate tests preserve solid tunnel margins.

![Original before](../tmp/issue48-before/titania.bmp)
![Original 16:9 after](../tmp/issue48-after/titania.bmp)
![Original 32:9 after](../tmp/issue48-ultrawide/titania.bmp)
![EX 16:9 after](../tmp/issue48-ex/titania.bmp)

These are Windows runtime captures, not physical console verification.

## Issue 47 captured evidence

`tools/capture_results.ps1` follows the cartridge's authored CL_WARP transition
from LEVEL1_2. Before/after captures at the same frame (1440), Original 16:9,
2x rendering:

![Before completion bar and HUD restoration](../tmp/issue47-before/results.bmp)
![After completion bar and HUD restoration](../tmp/issue47-after/results.bmp)

The source MTXTPRT.MC draws a 104x12 border at (60,24), with an inset 100x8
maximum fill. Tests cover 0/1/50/100/255 values, clamping and untouched pixels
outside the bar. MAIN.ASM keeps the live stage underneath its tally; the host
had explicitly cleared M_METERS and excluded this flow from the final OBJ pass.
The code is shared with Android, but these captures are Windows evidence only.

## Issue 43 captured evidence

`tools/capture_revival.ps1` runs the actual EX LEVEL3_2 death strategy and
captures through respawn at original pacing, 60 FPS, 2x rendering. No save or
menu preference is modified. The screenshots below are the same frame number
from before and after the palette fix, not recreated illustrations.

Before (pink model palette persists):
![Before respawn palette fix](../tmp/issue43-baseline/001740.bmp)

After (selected model palette restored):
![After respawn palette fix](../tmp/issue43-fixed/001740.bmp)

The complete capture sequences and runtime logs remain in those directories.

## Issue 46 captured evidence

`tools/capture_game_over.ps1` captures the real Game Over flow. Matching
Original 16:9 captures at 2x and frame 90:

![Before star extension](../tmp/issue46-before/gameover.bmp)
![After star extension](../tmp/issue46-after/gameover.bmp)

Pixel comparison found **zero changes in the native 256-pixel-wide canvas**
and 24 changed stored pixels in the margins. Andross and the source stars/text
remain centred and identical. The newly visible stars use the same camera,
point cloud and projection, not tiled backdrop art.

![EX 32:9 star extension](../tmp/issue46-ex/gameover.bmp)
