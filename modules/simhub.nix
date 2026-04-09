{ config, pkgs, lib, ... }:
let
  username = config.flake.meta.owner.username;
  # Per-game Wine prefix configuration
  # Maps game names to their Wine prefix locations (Steam game IDs)
  gameWinePrefixes = {
    AssettoCorsa = {
      process = "acs";
      steamId = "244210";
      description = "Assetto Corsa";
    };
    ACC = {
      process = "ACC";
      steamId = "805550";
      description = "Assetto Corsa Competizione";
    };
    ACEvo = {
      process = "ac2";
      steamId = "2187720";
      description = "Assetto Corsa Evo";
    };
    iRacing = {
      process = "iRacingSim";
      steamId = "581800";
      description = "iRacing";
    };
    rFactor2 = {
      process = "rFactor2";
      steamId = "365960";
      description = "rFactor 2";
    };
  };

  # Create regex pattern for all game processes
  gameProcesses = lib.attrValues gameWinePrefixes;
  gamePatternList = map (g: g.process) gameProcesses;
  gamePattern = lib.concatStringsSep "|" gamePatternList;

  # Helper function to get prefix path from Steam ID
  getPrefixPath = steamId: "/home/${username}/.steam/steamapps/compatdata/${steamId}/pfx";

in {
  flake.modules.nixos.simhub = { config, pkgs, ... }: {
    # Environment variables for SimHub
    environment.variables = {
      SIMHUB_CONFIG_DIR = "/home/${username}/.simhub";
    };

    environment.systemPackages = with pkgs; [
      # Detect game prefix script - MUST be writeShellScriptBin for environment.systemPackages
      (writeShellScriptBin "detect-game-prefix" ''
        USERNAME="${username}"

        # Check which game is running and return its prefix
        if pgrep -ifE "acs|acs.exe" > /dev/null 2>&1; then
          echo "/home/$USERNAME/.steam/steamapps/compatdata/244210/pfx"
        elif pgrep -ifE "ACC" > /dev/null 2>&1; then
          echo "/home/$USERNAME/.steam/steamapps/compatdata/805550/pfx"
        elif pgrep -ifE "ac2" > /dev/null 2>&1; then
          echo "/home/$USERNAME/.steam/steamapps/compatdata/2187720/pfx"
        elif pgrep -ifE "iRacingSim" > /dev/null 2>&1; then
          echo "/home/$USERNAME/.steam/steamapps/compatdata/581800/pfx"
        elif pgrep -ifE "rFactor2" > /dev/null 2>&1; then
          echo "/home/$USERNAME/.steam/steamapps/compatdata/365960/pfx"
        fi
      '')
      
      # SimHub dependencies
      wine
      wine64
      winetricks
      dotnetCorePackages.runtime_8_0
      openssl
      
      # Utilities
      jq
      curl
      procps
      psmisc

      # Create wrapper scripts for SimHub with per-game prefix support
      (writeShellScriptBin "simhub-init-game" ''
        #!/bin/bash
        # Initialize SimHub in a specific game's Wine prefix
        # Usage: simhub-init-game <steam-id> [game-name]

        set -e

        if [ -z "$1" ]; then
          echo "Usage: simhub-init-game <steam-id> [game-name]"
          echo ""
          echo "Examples:"
          echo "  simhub-init-game 244210 'Assetto Corsa'"
          echo "  simhub-init-game 805550 'ACC'"
          echo "  simhub-init-game 2187720 'Assetto Corsa Evo'"
          exit 1
        fi

        STEAM_ID="$1"
        GAME_NAME="''${2:-Game}"
        WINEPREFIX="/home/${username}/.steam/steamapps/compatdata/$STEAM_ID/pfx"
        SIMHUB_INSTALL_DIR="$WINEPREFIX/drive_c/Program Files/SimHub"

        if [ ! -d "$WINEPREFIX" ]; then
          echo "Error: Wine prefix not found at $WINEPREFIX"
          echo "Make sure you've installed the game first."
          exit 1
        fi

        mkdir -p "''${SIMHUB_CONFIG_DIR:=$HOME/.simhub}"

        # Initialize Wine prefix if needed
        if [ ! -f "$WINEPREFIX/system.reg" ]; then
          echo "Initializing Wine prefix for $GAME_NAME..."
          WINEPREFIX="$WINEPREFIX" wineboot -i
        fi

        # Install .NET Framework if not already installed
        if ! WINEPREFIX="$WINEPREFIX" wine reg query "HKEY_LOCAL_MACHINE\\Software\\Microsoft\\.NET Framework Setup\\NDP\\v4\\Full" 2>/dev/null | grep -q "InstallPath"; then
          echo "Installing .NET Framework in $GAME_NAME's prefix..."
          WINEPREFIX="$WINEPREFIX" winetricks -q dotnet48 vcrun2019 corefonts
        fi

        echo "SimHub Wine prefix initialized for $GAME_NAME at: $WINEPREFIX"
      '')

      (writeShellScriptBin "simhub-install-game" ''
        #!/bin/bash
        # Install SimHub into a specific game's Wine prefix
        # Usage: simhub-install-game <steam-id> <path-to-installer> [game-name]

        set -e

        if [ -z "$1" ] || [ -z "$2" ]; then
          echo "Usage: simhub-install-game <steam-id> <path-to-installer.exe> [game-name]"
          echo ""
          echo "Examples:"
          echo "  simhub-install-game 244210 ~/Downloads/SimHub-Installer.exe 'Assetto Corsa'"
          echo "  simhub-install-game 805550 ~/Downloads/SimHub-Installer.exe 'ACC'"
          exit 1
        fi

        STEAM_ID="$1"
        INSTALLER_PATH="$2"
        GAME_NAME="''${3:-Game}"
        WINEPREFIX="/home/${username}/.steam/steamapps/compatdata/$STEAM_ID/pfx"

        if [ ! -f "$INSTALLER_PATH" ]; then
          echo "Error: Installer not found at $INSTALLER_PATH"
          exit 1
        fi

        echo "Initializing SimHub for $GAME_NAME..."
        simhub-init-game "$STEAM_ID" "$GAME_NAME"

        echo "Running SimHub installer in $GAME_NAME's prefix..."
        export WINEPREFIX="$WINEPREFIX"
        wine "$INSTALLER_PATH"

        echo "SimHub installation complete for $GAME_NAME!"
      '')

      (writeShellScriptBin "simhub-run-game" ''
        #!/bin/bash
        # Launch SimHub in the Wine prefix of the currently running game
        # This is called by the systemd service
        
        WINEPREFIX=$(detect-game-prefix)

        if [ -z "$WINEPREFIX" ]; then
          echo "Error: No game detected or game prefix not found" >&2
          exit 1
        fi

        if [ ! -d "$WINEPREFIX" ]; then
          echo "Error: Wine prefix not found at $WINEPREFIX" >&2
          exit 1
        fi

        SIMHUB_INSTALL_DIR="$WINEPREFIX/drive_c/Program Files/SimHub"
        SIMHUB_EXE="$SIMHUB_INSTALL_DIR/SimHub.exe"

        if [ ! -f "$SIMHUB_EXE" ]; then
          echo "Error: SimHub not found at $SIMHUB_EXE" >&2
          echo "Please install SimHub in this game's prefix first" >&2
          exit 1
        fi

        export WINEPREFIX="$WINEPREFIX"
        export PROTON_LOG=1
        export WINE_CPU_TOPOLOGY="4:2"

        exec ${pkgs.wine}/bin/wine "$SIMHUB_EXE" "$@"
      '')

      (writeShellScriptBin "simhub-monitor-games" ''
        #!/bin/bash
        # Monitor for racing games and auto-start/stop SimHub
        
        GAME_PATTERN="${gamePattern}"

        while true; do
          # Check if any configured game is running
          if pgrep -ifE "$GAME_PATTERN" > /dev/null 2>&1; then
            if ! systemctl --user is-active --quiet simhub; then
              DETECTED_GAME=$(pgrep -ifE "$GAME_PATTERN" | head -1 | xargs -I {} ps -p {} -o comm=)
              echo "[$(date)] Game detected ($DETECTED_GAME), starting SimHub..."
              systemctl --user start simhub.service
            fi
          else
            # No game running, stop SimHub
            if systemctl --user is-active --quiet simhub; then
              echo "[$(date)] No game detected, stopping SimHub..."
              systemctl --user stop simhub.service
            fi
          fi
          sleep 5
        done
      '')
    ];

    # udev rules for SimHub hardware (common VR/racing peripherals)
    services.udev.extraRules = ''
      # Valve Index / SteamVR devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28de", MODE="0666"

      # HTC Vive devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="2c87", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", ATTRS{idProduct}=="0306", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0bb4", MODE="0666"

      # Oculus/Meta devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2341", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2341", MODE="0666"

      # Generic HID devices (wheels, pedals, shifters)
      SUBSYSTEMS=="usb", ATTRS{bInterfaceClass}=="03", ATTRS{bInterfaceSubClass}=="01", MODE="0666"
      SUBSYSTEM=="hidraw", MODE="0666"
    '';

    # Allow user to access USB devices needed for SimHub
    users.users.${username}.extraGroups = [ "input" "uinput" ];
  };

  # NixOS module for home-manager and systemd user service configuration
  flake.modules.nixos.simhub-user = { pkgs, ... }: {
    config.systemd.user.services.simhub = {
      description = "SimHub - Sim Racing Dashboard";
      documentation = [ "https://www.simhubdash.com" ];
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "/run/current-system/sw/bin/simhub-run-game";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };

      wantedBy = [ "graphical-session.target" ];
    };

    # Monitor games and auto-start SimHub
    config.systemd.user.services.simhub-monitor-games = {
      description = "Monitor racing games and auto-start SimHub";
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "/run/current-system/sw/bin/simhub-monitor-games";
        Restart = "always";
        StandardOutput = "journal";
        StandardError = "journal";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };
}
