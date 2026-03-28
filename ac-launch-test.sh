#!/bin/sh
AC_APPID=244210
PROTON_PREFIX_DIR="$HOME/.local/share/Steam/steamapps/compatdata/$AC_APPID"

# Cleanup stale Wine processes (user's original script had this, keeping it)
echo "Cleaning up stale Wine processes..."
pkill -9 wineserver 2>/dev/null || true
rm -f /dev/shm/wine-*-fsync 2>/dev/null || true
sleep 1

export WINEPREFIX="$PROTON_PREFIX_DIR/pfx"
export WINEARCH=win64
# Explicitly add Proton's bin directory to PATH for winetricks to find wineserver
export PATH="/home/amiceli/.cache/protontricks/proton/GE-Proton/bin:$PATH"

echo "--- Now running winetricks to install corefonts..."
echo "--- This may take a while and open several installer windows."
echo
steam-run winetricks --force -q corefonts

echo
echo "--- About to launch acbridge.exe"

protontricks -c 'wine ~/.local/share/simshmbridge/acbridge.exe' 244210

echo "--- Finished"
