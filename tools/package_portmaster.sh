#!/usr/bin/env bash
# Assemble a PortMaster zip for Star Fox Enhanced from an already-built
# aarch64 Linux install tree.
#
# This script does NOT build the binary and does NOT embed any ROM or
# ROM-derived assets. You still need to:
#
#   1. Build starfox_pc yourself for aarch64, on hardware or via an aarch64
#      cross/native toolchain, e.g. with tools/build_linux.sh on an
#      aarch64 host (the CI "linux-arm64" job only validates the
#      ROM-independent test suite; it does not produce a redistributable
#      binary). A release build should be built with your own
#      STARFOX_ROM_FILE/STARFOX_EX_ROM_FILE set at configure time if you
#      want Starfox-Assets.BIN reconstruction exercised during your own
#      testing; the packaged binary itself does not need the ROM to be
#      present at build time (see tools/build_linux.sh).
#   2. Own a legally obtained, unmodified retail Star Fox/Starwing ROM
#      (see the "Supported ROMs" section of the main README). Never embed
#      it in a package you redistribute to other people; end users must
#      supply their own ROM.
#
# Usage:
#   tools/package_portmaster.sh <install_dir> [output_zip]
#
#   <install_dir>  Directory produced by `cmake --install` for an aarch64
#                  build, i.e. it must directly contain the `starfox_pc`
#                  binary (see tools/build_linux.sh's INSTALL_ROOT/
#                  ${install_root} argument, or dist/StarFoxEnhanced-*
#                  from the portable-builds workflow).
#   [output_zip]   Where to write the finished PortMaster package.
#                  Defaults to StarFoxEnhanced-portmaster.zip in the
#                  current directory.
#
# Result layout (matches PortMaster's expected zip shape):
#   StarFoxEnhanced.sh          <- launcher (portmaster/StarFoxEnhanced.sh)
#   port.json                   <- PortMaster metadata (portmaster/port.json)
#   StarFoxEnhanced/
#     starfox_pc                <- the aarch64 binary you built
#     pregame.cfg                <- default settings: 3:2 display mode,
#                                    fullscreen native panel resolution,
#                                    on-screen touch controls off
#     roms/                     <- empty; put your own ROM at roms/sf.sfc
#     <licenses/notices copied from the install tree>
#
# UNTESTED ON REAL HARDWARE. See the "PortMaster / Anbernic H700 (muOS)"
# section of the main README for exactly what has and has not been
# verified.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
portmaster_dir="${repo_root}/portmaster"

install_dir="${1:?usage: $0 <install_dir> [output_zip]}"
output_zip="${2:-$(pwd)/StarFoxEnhanced-portmaster.zip}"

if [[ ! -x "${install_dir}/starfox_pc" ]]; then
    echo "error: ${install_dir}/starfox_pc not found or not executable" >&2
    echo "       point this at a cmake --install output directory for an" >&2
    echo "       aarch64 build (see tools/build_linux.sh)." >&2
    exit 1
fi

binary_format="$(file -b "${install_dir}/starfox_pc" 2>/dev/null || true)"
case "${binary_format}" in
    *aarch64*|*ARM\ aarch64*) ;;
    *)
        echo "warning: ${install_dir}/starfox_pc does not look like an aarch64" >&2
        echo "         ELF binary (file(1) reported: ${binary_format})." >&2
        echo "         Continuing anyway, but this is probably not the build" >&2
        echo "         you want to ship to an Anbernic H700 device." >&2
        ;;
esac

staging="$(mktemp -d)"
trap 'rm -rf "${staging}"' EXIT

game_dir="${staging}/StarFoxEnhanced"
mkdir -p "${game_dir}/roms"

# Binary and whatever notices/licenses cmake --install placed alongside it.
cp -a "${install_dir}/." "${game_dir}/"
# roms/ must ship empty (mkdir -p above already created it before the copy
# could have pulled one in from a maintainer's own local install tree).
rm -rf "${game_dir}/roms"
mkdir -p "${game_dir}/roms"
cat > "${game_dir}/roms/README.txt" <<'EOF'
Put your own legally obtained, unmodified Star Fox/Starwing ROM here as
"sf.sfc" (the launcher points STARFOX_RETAIL_ROM at roms/sf.sfc). See the
"Supported ROMs" section of the main project README for accepted revisions.
No ROM is included in this package.
EOF

# The starfox_pc runtime reconstructs its own assets from the ROM on first
# launch; the separate CLI asset builder tool serves other platforms
# (see platform/mobile/ASSET_BUILDER.md) and is not needed here.
rm -f "${game_dir}/starfox_asset_builder"

cp "${portmaster_dir}/default-pregame.cfg" "${game_dir}/pregame.cfg"
cp "${portmaster_dir}/StarFoxEnhanced.sh" "${staging}/StarFoxEnhanced.sh"
chmod +x "${staging}/StarFoxEnhanced.sh"
cp "${portmaster_dir}/port.json" "${staging}/port.json"

rm -f "${output_zip}"
(cd "${staging}" && zip -r -9 -X "${output_zip}" . >/dev/null)

echo "Wrote ${output_zip}"
echo "Remember: add your own ROM at StarFoxEnhanced/roms/sf.sfc on the" \
     "device (or before zipping, for your own personal copy) -- never" \
     "redistribute a package that already contains one."
