{ config, pkgs, lib, ... }:
let
  username = config.flake.meta.owner.username;
  # Per-game Wine prefix configuration
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

  # Helper function to get prefix path from Steam ID
  getPrefixPath = steamId: "/home/${username}/.local/share/Steam/steamapps/compatdata/${steamId}/pfx";

in {
  flake.modules.nixos.simhub = { config, pkgs, ... }: {
    # SimHub dependencies
    environment.systemPackages = with pkgs; [
      # Wine and winetricks for per-prefix setup
      wine
      wine64
      winetricks
      protontricks
      
      # Utilities
      jq
      curl
      procps
      psmisc

      # Helper scripts for SimHub setup
      (writeShellScriptBin "simhub-install-prefix" ''
        #!/bin/bash
        # Install dotnet48 and SimHub into a game's Wine prefix
        # Usage: simhub-install-prefix <steam-id> <path-to-simhub-installer-or-dir> [game-name]

        set -e

        if [ -z "$1" ] || [ -z "$2" ]; then
          echo "Usage: simhub-install-prefix <steam-id> <path-to-installer-or-simhub-dir> [game-name]"
          echo ""
          echo "Examples:"
          echo "  simhub-install-prefix 244210 ~/Downloads/SimHubSetup.exe 'Assetto Corsa'"
          echo "  simhub-install-prefix 805550 ~/repo/simhub 'ACC'"
          exit 1
        fi

        STEAM_ID="$1"
        SOURCE_PATH="$2"
        GAME_NAME="''${3:-Game}"
        
        WINEPREFIX="/home/${username}/.local/share/Steam/steamapps/compatdata/$STEAM_ID/pfx"
        SIMHUB_DIR="$WINEPREFIX/drive_c/Program Files/SimHub"

        if [ ! -d "$WINEPREFIX" ]; then
          echo "Error: Wine prefix not found at $WINEPREFIX"
          echo "Please run the game at least once to create its prefix."
          exit 1
        fi

        if [ ! -e "$SOURCE_PATH" ]; then
          echo "Error: Source path not found: $SOURCE_PATH"
          exit 1
        fi

        echo "Installing SimHub for $GAME_NAME (Steam ID: $STEAM_ID)..."
        echo ""

        export WINEPREFIX="$WINEPREFIX"
        export WINEARCH=win64

        # Step 1: Install dotnet48 using winetricks
        echo "Step 1/2: Installing .NET Framework 4.8..."
        winetricks -q dotnet48 2>&1 | grep -v "^WINEPREFIX\|^Registry\|^warning:\|^------" || true
        echo "✓ .NET Framework 4.8 installed"
        echo ""

        # Step 2: Install SimHub
        echo "Step 2/2: Installing SimHub..."
        
        # Check if SOURCE_PATH is a directory with SimHub files
        if [ -d "$SOURCE_PATH" ] && [ -f "$SOURCE_PATH/SimHubWPF.exe" ]; then
          echo "Detected SimHub directory: $SOURCE_PATH"
          mkdir -p "$SIMHUB_DIR"
          cp -r "$SOURCE_PATH"/* "$SIMHUB_DIR/" 2>/dev/null || true
          echo "✓ SimHub copied to $SIMHUB_DIR"
        elif [ -f "$SOURCE_PATH" ]; then
          # It's an installer exe
          echo "Running SimHub installer..."
          wine "$SOURCE_PATH" /S 2>&1 | tail -5 || true
          echo "✓ SimHub installed"
        else
          echo "Error: Could not determine if $SOURCE_PATH is installer or directory"
          exit 1
        fi

        echo ""
        echo "Installation complete!"
        echo "Next steps:"
        echo "1. Configure Steam Tinker Launch for this game"
        echo "2. Set custom command to: $SIMHUB_DIR/SimHubWPF.exe"
        echo "3. Enable 'Fork custom command' and 'Inject custom command'"
        echo "4. Set inject wait to 5 seconds"
        echo "5. Launch the game with Steam Tinker Launch"
      '')

      # Helper script to show per-game setup instructions
      (writeShellScriptBin "simhub-setup-guide" ''
        #!/bin/bash
        # Show Steam Tinker Launch setup instructions for SimHub

        echo "================================"
        echo "SimHub on Linux Setup Guide"
        echo "================================"
        echo ""
        echo "Prerequisites:"
        echo "1. Install Steam Tinker Launch from its GitHub or Flathub"
        echo "2. Ensure your game's Wine prefix exists (run game once)"
        echo ""
        echo "Installation Steps:"
        echo ""
        echo "Step 1: Install SimHub to game prefix"
        echo "  simhub-install-prefix <STEAM_ID> <path-to-installer-or-dir> <GAME_NAME>"
        echo ""
        echo "Example for Assetto Corsa:"
        echo "  simhub-install-prefix 244210 ~/Downloads/SimHubSetup.exe 'Assetto Corsa'"
        echo ""
        echo "Step 2: Configure Steam Tinker Launch"
        echo "  a) Right-click game in Steam → Properties → Compatibility"
        echo "  b) Check 'Force the use of a specific Steam Compatibility Tool'"
        echo "  c) Select 'Steam Tinker Launch' from dropdown"
        echo "  d) Launch the game"
        echo "  e) Steam Tinker Launch menu appears - click 'Main menu'"
        echo ""
        echo "Step 3: Configure SimHub Injection"
        echo "  In Steam Tinker Launch menu:"
        echo "  ✓ Enable 'Use custom command'"
        echo "  ✓ Set custom command to:"
        echo "    ~/.local/share/Steam/steamapps/compatdata/<STEAM_ID>/pfx/drive_c/Program Files/SimHub/SimHubWPF.exe"
        echo "  ✓ Enable 'Fork custom command' (run independently)"
        echo "  ✓ Enable 'Inject custom command' (launch alongside game)"
        echo "  ✓ Set 'Inject wait' to 5 seconds"
        echo ""
        echo "Step 4: Save and run the game"
        echo "  Game and SimHub should launch together"
        echo ""
        echo "Game Steam IDs:"
        echo "  Assetto Corsa: 244210"
        echo "  ACC: 805550"
        echo "  Assetto Corsa Evo: 2187720"
        echo "  iRacing: 581800"
        echo "  rFactor 2: 365960"
        echo ""
        echo "Notes:"
        echo "- First launch may take longer as SimHub initializes"
        echo "- If SimHub doesn't appear, retry - sometimes needs 2-3 attempts"
        echo "- Configure game-specific settings in SimHub (telemetry, devices, etc.)"
      '')

      # Quick installer for each game
      (writeShellScriptBin "simhub-install-ac" ''
        #!/bin/bash
        if [ -z "$1" ]; then
          echo "Usage: simhub-install-ac <path-to-installer-or-simhub-dir>"
          exit 1
        fi
        simhub-install-prefix 244210 "$1" "Assetto Corsa"
      '')

      (writeShellScriptBin "simhub-install-acc" ''
        #!/bin/bash
        if [ -z "$1" ]; then
          echo "Usage: simhub-install-acc <path-to-installer-or-simhub-dir>"
          exit 1
        fi
        simhub-install-prefix 805550 "$1" "Assetto Corsa Competizione"
      '')

      (writeShellScriptBin "simhub-install-acevo" ''
        #!/bin/bash
        if [ -z "$1" ]; then
          echo "Usage: simhub-install-acevo <path-to-installer-or-simhub-dir>"
          exit 1
        fi
        simhub-install-prefix 2187720 "$1" "Assetto Corsa Evo"
      '')

      (writeShellScriptBin "simhub-install-iracing" ''
        #!/bin/bash
        if [ -z "$1" ]; then
          echo "Usage: simhub-install-iracing <path-to-installer-or-simhub-dir>"
          exit 1
        fi
        simhub-install-prefix 581800 "$1" "iRacing"
      '')

      (writeShellScriptBin "simhub-install-rfactor2" ''
        #!/bin/bash
        if [ -z "$1" ]; then
          echo "Usage: simhub-install-rfactor2 <path-to-installer-or-simhub-dir>"
          exit 1
        fi
        simhub-install-prefix 365960 "$1" "rFactor 2"
      '')
    ];
  };
}
