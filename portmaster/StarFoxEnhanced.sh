#!/bin/bash
# PortMaster launcher for Star Fox Enhanced (native SDL3 runtime).
#
# This follows the standard PortMaster launcher shape. It does not use
# gptokeyb/keyboard emulation: the runtime already talks to SDL3 gamepads
# directly (see src/app/runtime_input.cpp upstream), so the controller is
# launched straight into the game binary.
#
# UNVERIFIED ON REAL HARDWARE. See portmaster/README section in the main
# project README for exactly what has and has not been tested.

GRANDPARENTDIR="/$(dirname "$(dirname "$(readlink -f "$0")")")"
controlfolder="$GRANDPARENTDIR/PortMaster"
[ -f "${controlfolder}/control.txt" ] && source "$controlfolder/control.txt" "$0"
get_controls

GAMEDIR="/$(dirname "$(readlink -f "$0")")/StarFoxEnhanced"
cd "$GAMEDIR" || exit 1

echo "$GAMEDIR" > "$controlfolder/lastgame.txt"

# The engine validates and reconstructs its runtime assets (Starfox-Assets.BIN)
# from this ROM on first launch, then reuses that reconstructed file on later
# launches. No ROM is bundled with this port; you must copy your own legally
# obtained, unmodified retail Star Fox/Starwing ROM here yourself. Supported
# revisions are listed in the main project README ("Supported ROMs").
export STARFOX_RETAIL_ROM="$GAMEDIR/roms/sf.sfc"

# There is no command-line flag or config-file setting for fullscreen; the
# upstream desktop code only toggles it via Alt+Enter on a keyboard, which
# most PortMaster handhelds do not have. STARFOX_START_FULLSCREEN is a small
# addition made specifically for this port (see the Window constructor in
# src/app/starfox_pc.cpp) that starts the SDL window in borderless fullscreen
# instead, adopting whatever resolution the display is already running at
# (720x480 on a stock muOS RG34XX/RG34XXSP setup).
export STARFOX_START_FULLSCREEN=1

"$GAMEDIR/starfox_pc" "$@" > "$GAMEDIR/log.txt" 2>&1

printf "\033c" > /dev/tty0 2>/dev/null || true
