#!/bin/sh
APP_ID=244210

echo "--- Running protontricks to install dotnet48..."
echo "--- This may take a while and open several installer windows."
echo

# Support both common prefix locations
if [ -d "/home/$USER/.local/share/Steam/steamapps/compatdata/$APP_ID/pfx" ]; then
  WINEPREFIX="/home/$USER/.local/share/Steam/steamapps/compatdata/$APP_ID/pfx"
elif [ -d "/home/$USER/.steam/steam/steamapps/compatdata/$APP_ID/pfx" ]; then
  WINEPREFIX="/home/$USER/.steam/steam/steamapps/compatdata/$APP_ID/pfx"
else
  echo "Error: Wine prefix for app $APP_ID not found."
  echo "Make sure you've run the game at least once through Steam."
  exit 1
fi

# Cleanup stale Wine processes
echo "Cleaning up stale Wine processes..."
pkill -9 wineserver 2>/dev/null || true
rm -f /dev/shm/wine-*-fsync 2>/dev/null || true
sleep 1

export WINEPREFIX
export WINEARCH=win64

echo "Running winetricks..."
steam-run winetricks --force -q dotnet48

#protontricks --verbose $AC_APPID dotnet48

echo
echo "---"
echo "Script finished."
echo "If the command succeeded, the '.NET 4.8 required' dialog should now be gone."
