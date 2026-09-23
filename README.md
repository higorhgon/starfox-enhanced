# Star Fox Enhanced

A native C++/SDL3 port of [UltraStarFox](https://github.com/Sunlitspace542/ultrastarfox),
with **Original Star Fox** and **Star Fox EX** experiences, high-frame-rate
presentation, widescreen support, and optional visual enhancements.

**[Download 0.0.6.7](https://github.com/kandowontu/starfox-enhanced/releases/tag/v0.0.6.7)** ·
[Changelog](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/RELEASE-0.0.6.7.md) ·
[Settings and controls](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/SETTINGS-AND-CONTROLS.md) ·
[Build guide](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/BUILDING.md) ·
[Report a bug](https://github.com/kandowontu/starfox-enhanced/issues)

> This is an alpha release, not a cycle-accurate SNES emulator. A supported,
> unmodified retail ROM supplied by you is required. No retail ROM is included.

## Get started

1. Download the package for your platform. Desktop users should extract it
   into a writable folder before launching; no source build is necessary.
2. Launch the game. On desktop, place your supported `.sfc`/`.smc` ROM beside
   the executable, or set `STARFOX_RETAIL_ROM` to its path. Mobile apps provide
   a first-launch file picker.
3. The game validates your ROM and creates `Starfox-Assets.BIN` locally.
   Keep that companion with the application; it may need rebuilding after
   updates to the embedded assets.
4. Choose **Original** or **Star Fox EX**, adjust your options, then select
   **Start Game** from the main menu.

For devices needing prepared assets, the release includes a standalone Windows
[asset builder](https://github.com/kandowontu/starfox-enhanced/blob/main/platform/mobile/ASSET_BUILDER.md). It accepts the same ROMs;
mobile users can also select a ROM directly.

### Supported ROMs

- Star Fox Japan: 1.0 / 1.1
- Star Fox USA: 1.0 / 1.1 / 1.2
- Starwing Europe: 1.0 / 1.1
- Starwing Germany: 1.0

A 512-byte copier header is accepted. Known revisions are checksum-verified
and canonicalized before the source-built patches are applied. Hacks, betas,
competition cartridges, Star Fox 2 and unknown revisions are not supported.

## Platforms

| Package | Notes |
|---|---|
| Windows x64 / x86 | Extract and run `starfox_pc.exe`. |
| Linux x64 | Native SDL3 runtime. |
| macOS universal | Unsigned application for Intel and Apple Silicon. |
| iOS arm64 | Unsigned device bundle; [signing/sideloading instructions](https://github.com/kandowontu/starfox-enhanced/blob/main/platform/apple/IOS_INSTALL.md). |
| Android arm64 | Installable development APK; see the upgrade notice below. |
| Nintendo Switch | Homebrew NRO; [setup and optional forwarder](https://github.com/kandowontu/starfox-enhanced/blob/main/platform/switch/README.md). |
| PS Vita | Homebrew VPK; [setup](https://github.com/kandowontu/starfox-enhanced/blob/main/platform/vita/README.md). |
| Xbox UWP x64 | Developer Mode required; [setup](https://github.com/kandowontu/starfox-enhanced/blob/main/platform/uwp/README.md). |

Build success does not guarantee identical behavior on every device.
See the [release notes](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/RELEASE-0.0.6.7.md) for verification limits.

**Android upgrades:** 0.0.6 uses a permanent signing key. Older APKs used
temporary keys, so upgrading from those builds requires a one-time reinstall.
**Back up saves and settings before uninstalling.** Later public builds will
retain the permanent signing certificate.

## PortMaster / Anbernic H700 (muOS)

Packaging files for [PortMaster](https://portmaster.games/) live under
[`portmaster/`](portmaster/), targeting the Anbernic **RG34XX / RG34XX H /
RG34XXSP** family (H700 chipset, Mali-G31 GPU, 720x480 physical panel — a
3:2 aspect ratio). **This target is unverified on real hardware**; it has
only been built and exercised in a Linux x86_64 sandbox. Treat it as a
starting point for a maintainer with the hardware to test on, not a
finished, confirmed-working port.

- **ROM requirement:** exactly the same as every other platform above — no
  ROM is bundled. You need your own legally obtained, unmodified retail
  Star Fox/Starwing ROM (see "Supported ROMs"). Never redistribute a
  package that already contains one.
- **3:2 display mode:** a new `DisplayMode` (3 BY 2 WIDE, alongside the
  existing 4:3/16:9/16:10/21:9/32:9 options) matches the RG34XX family's
  native panel instead of stretching or letterboxing a 4:3 image. Its HUD
  layout profile reuses the 4:3 profile's (zero) offsets, since there is no
  way to hand-tune pixel placement without the actual hardware in front of
  you; expect to nudge HUD elements yourself with the in-game HUD editor if
  anything looks off.
- **GPU/driver note:** this runtime is built on SDL3's GPU API. Its default
  "GPU" renderer requests Vulkan (`SDL_GPU_SHADERFORMAT_SPIRV`) on Linux,
  with an automatic fallback to SDL's native renderer if that device fails
  to create; the separate "Software" renderer option (Options → Renderer)
  forces a pure CPU rasterizer that needs no GPU driver support at all. The
  H700's Mali-G31 uses Mesa's Panfrost driver stack, whose Vulkan support
  (`panvk`) for this GPU is still comparatively new/limited; if the GPU
  renderer misbehaves or fails to start, switch to Software in Options.
- **Fullscreen:** the desktop build normally opens windowed and only
  toggles fullscreen via Alt+Enter on a keyboard, which most handhelds
  don't have. This port adds a small, real opt-in for that:
  `STARFOX_START_FULLSCREEN=1` (set by the packaged launcher) starts the
  window in borderless fullscreen at whatever resolution the display is
  already running, i.e. muOS's native 720x480 mode — there is no separate
  CLI flag or persisted setting for it.

### Build, package and install

1. **Automated (recommended):** unlike FZeroSNESRecomp/SuperMarioWorldRecomp,
   `starfox_pc` is a hand-written C++ reimplementation, not code statically
   recompiled from your ROM — so building it needs no ROM at all, and the
   `linux-arm64` job in
   [`.github/workflows/portable-builds.yml`](.github/workflows/portable-builds.yml)
   now builds, tests, packages, and uploads a ready-to-use
   `StarFoxEnhanced-portmaster-h700.zip` as a run artifact, entirely on
   GitHub-hosted infrastructure. Go to **Actions → Portable platform
   builds → Run workflow** on this fork, wait for the `linux-arm64` job, and
   download the artifact from the run summary. No self-hosted runner needed
   for this game.
2. **Manual (equivalent, for local iteration):** build `starfox_pc` for
   aarch64 yourself (natively on aarch64 hardware, or with a cross
   toolchain) using [`tools/build_linux.sh`](tools/build_linux.sh), the same
   script the CI job above calls, then run
   [`tools/package_portmaster.sh`](tools/package_portmaster.sh) against that
   build's install directory to assemble the zip:
   ```sh
   tools/build_linux.sh . /tmp/build-arm64 dist/StarFoxEnhanced-linux-arm64
   tools/package_portmaster.sh dist/StarFoxEnhanced-linux-arm64 StarFoxEnhanced-portmaster.zip
   ```
   This produces the standard PortMaster shape (`StarFoxEnhanced.sh` and
   `port.json` at the zip root, a `StarFoxEnhanced/` folder with the binary
   and a default `pregame.cfg` that selects the 3:2 display mode, native
   render scale, and turns off the on-screen touch overlay since the
   handheld has physical controls) plus an empty `StarFoxEnhanced/roms/`
   folder for your ROM.
3. Add your own ROM at `StarFoxEnhanced/roms/sf.sfc` inside the extracted
   package (matching what `portmaster/StarFoxEnhanced.sh` points
   `STARFOX_RETAIL_ROM` at). Neither the CI artifact nor the manual zip ever
   contains a ROM — the CI job actively checks for and refuses to publish
   one.
4. On the muOS device: install [PortMaster](https://portmaster.games/)
   itself first if you haven't already (its own zip goes in `/ARCHIVE/` on
   the SD card, then **Applications → Archive Manager** extracts it).
   Ports are then split across two folders on the SD card: the port's game
   folder goes under `ports/`, and its launcher `.sh` goes under
   `roms/Ports/` (muOS lists that folder as a launchable system) — copy
   this package's `StarFoxEnhanced/` folder and `StarFoxEnhanced.sh`
   accordingly, or use muOS's built-in PortMaster app to install the zip
   directly if that flow is available on your muOS version. Folder naming
   has shifted across muOS releases, so cross-check against PortMaster's
   own current install instructions if this doesn't match what you see.
5. Controller input uses SDL3 gamepad support already built into the
   runtime (`src/app/runtime_input.cpp`) — no `gptokeyb`/keyboard-emulation
   layer is used or needed.

### What is and isn't verified

Verified in this sandbox: the new `DisplayMode::widescreen_3_2` value
compiles, every switch/table that enumerates display modes was updated for
it (grepped exhaustively), the full native x86_64 `STARFOX_BUILD_TESTS=ON`
suite passes (22/22 `ctest` targets, including the pre-game display-cycle
test extended for the new mode and a HUD-layout-migration test fixed for
the profile-count change), and `portmaster/default-pregame.cfg` round-trips
through the real `load_pregame_settings` parser with `display_mode` == 5.

Not verified, because no ROM and no H700 hardware are available here:
actual gameplay, HUD pixel placement in the new 3:2 mode (its layout
profile is a placeholder reusing 4:3's zero offsets, not hand-tuned),
Vulkan/Panfrost behavior on Mali-G31, fullscreen/resolution behavior on a
real muOS install, controller mapping on RG34XX hardware, and performance.

## Features and settings

- **Original and EX:** original routes and frontend flow, plus EX's shipped
  campaigns, native options and mechanics.
- **Smooth presentation:** 20–480 FPS choices, defaulting to 60. Game pace is
  independent of render FPS; Original Speed preserves source-style slowdown.
- **Display:** 4:3, 16:10, 16:9, 21:9, 32:9 and 3:2; GPU or software presentation.
- **Languages:** English, English (Europe), Japanese, German, French and Spanish, including menus
  and dialogue. EX translations include authored additions.
- **2D Options:** artwork filtering, 2D Bloom, World Effects and their intensity.
  The artwork filter also covers textures on 3D polygons.
- **3D Options:** anti-aliasing, VSync, 1–4× Render Upscale, 3D Bloom, 3D Smoothing,
  Enhanced Lighting, HDR Effect, Ray Tracing (hardware DXR shadows, default Off),
  Chromatic Aberration, Model Effects
  and Model Effect Intensity. HDR Effect is brightness/contrast
  processing, **not HDR display output**.
  Ray Tracing replaces original shadows rather than drawing a second set;
  there is no separate Enhanced Shadows toggle.
- **Preview:** a fixed reference scene shows graphics changes live. Hold **Tab**
  to hide the menu temporarily. Preview defaults off each launch.
- **Customization:** draggable HUD layouts, controller/keyboard remapping,
  crosshair colors, separate music/SFX volumes, rumble and optional God Mode.

Model and world effects are independent; CEL-DRAWN is model-only and BLUEPRINT
is world-only. Most visual enhancements are optional. Higher render scales and
additional effects can increase CPU, GPU and memory use.

Optional Original MSU-1 music requires `Starfox-MSU1.PAK` beside the desktop
executable (or in the platform's writable storage). It is not included in the
standard packages. Without it, native SPC music remains available.

See [Settings and controls](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/SETTINGS-AND-CONTROLS.md) for detailed options,
EX peripherals, multiplayer and presentation debugging.

## Default controls

| SNES control | Keyboard | Gamepad position |
|---|---|---|
| D-pad | Arrow keys | D-pad / left stick |
| B | Z | South |
| Y | A | West |
| A | X | East |
| X | S | North |
| L / R | Q / W | Shoulder buttons |
| Select | Apostrophe (`'`) | Back/View |
| Start | Enter | Start/Menu |

Button names above follow the SNES layout, not the letters printed on an Xbox
controller. Remap controls under **Options → Controller**. Menu A actions fire
once per press; B or Back returns from submenus.

| Shortcut | Action |
|---|---|
| Escape | Exit confirmation |
| Tab in setup | Hide the menu while held |
| Tab / Ctrl+Tab / Ctrl+Shift+Tab outside setup | 2× / 3× / 5× fast-forward |
| Ctrl+Shift+R | Reset; remap the final key under Keyboard → Reset |
| Ctrl+Alt+F12 | Toggle God Mode live |
| Ctrl+F1 / Ctrl+F2 | Save / load the selected state slot |
| Ctrl+F3 | Select state slot 0–9; arrows or D-pad, Enter/A to close |
| F12 on the main setup page | Enable/disable presentation history for this run |
| F5 / F6 / F7 | Freeze / step forward / step backward with history enabled |

## Saves and upgrades

Desktop builds are portable: keep these files beside the executable when
moving or upgrading the game. Use a writable folder, not a read-only directory.

| File | Purpose |
|---|---|
| `Starfox-Assets.BIN` | Locally reconstructed runtime assets |
| `starfox-ex.srm` | EX cartridge SRAM |
| `pregame.cfg` | Game and graphics preferences |
| `input-bindings.cfg` | Keyboard and controller mappings |
| `hud-layout.cfg` | Per-experience, per-aspect-ratio HUD layouts |
| `Starfox-MSU1.PAK` | Optional replacement music |

The first normal launch copies missing data from former preference locations;
existing portable files win, and originals are not deleted. Mobile and console
builds use writable platform storage instead of their read-only package folders.

## Development and credits

To build, regenerate source assets or run tests, use the
[build guide](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/BUILDING.md). The
[architecture notes](https://github.com/kandowontu/starfox-enhanced/blob/main/docs/ARCHITECTURE.md) explain the hybrid native/65C816
boundary: gameplay remains fixed-point while extra presentation frames are
interpolated. Visual parity remains an ongoing effort.

See [Credits](CREDITS.md) for Nintendo/Argonaut, EX, UltraStarFox and port
contributors, and [Third-party notices](THIRD_PARTY_NOTICES.md) for dependencies
and licenses. Development uses Codex.
