{ config, lib, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.simd = { pkgs, ... }:
  let
    argtable2 = pkgs.callPackage ../derivations/argtable2.nix {};
    simapi = pkgs.callPackage ../derivations/simapi.nix {
      inherit argtable2;
    };
    
    # Build Windows binaries using mingwW64 cross-compilation with Makefile
    acbridgeExe = pkgs.pkgsCross.mingwW64.stdenv.mkDerivation {
      pname = "acbridge-exe";
      version = "unstable-2025";

      src = pkgs.fetchFromGitHub {
        owner = "Spacefreak18";
        repo = "simshmbridge";
        rev = "740f64da83a3745c254778ac492f66bd7a972f9a";
        hash = "sha256-l1pz66U57Sxo9RpTHVT+h2RKcw6YnynXyZPB7iXeLm4=";
        fetchSubmodules = true;
      };

      buildPhase = ''
        runHook preBuild
        make -f Makefile.ac assets/acbridge.exe
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp assets/acbridge.exe $out/bin/
        runHook postInstall
      '';
    };
    
    simshmbridge = pkgs.stdenv.mkDerivation {
      pname = "simshmbridge";
      version = "unstable-2025";

      src = pkgs.fetchFromGitHub {
        owner = "Spacefreak18";
        repo = "simshmbridge";
        rev = "740f64da83a3745c254778ac492f66bd7a972f9a";
        hash = "sha256-l1pz66U57Sxo9RpTHVT+h2RKcw6YnynXyZPB7iXeLm4=";
        fetchSubmodules = true;
      };

      buildInputs = [ pkgs.gnumake ];

      buildPhase = ''
        runHook preBuild
        mkdir -p assets
        # Linux native binaries
        gcc -DASSETTOCORSA -Wall -Os createsimshm.c -o assets/acshm
        gcc -DASSETTOCORSA -Wall -Os bridge.c -o assets/achandle
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp assets/acshm $out/bin/
        cp assets/achandle $out/bin/
        ln -s ${acbridgeExe}/bin/acbridge.exe $out/bin/acbridge.exe
        runHook postInstall
      '';
    };
    
    wine = pkgs.callPackage ../derivations/wine-wow64-custom.nix {};
  in {
    environment.systemPackages = [
      simapi
      simshmbridge
      wine
      pkgs.libuv
      pkgs.libconfig
      pkgs.yder
    ];

    # Create systemd user service for simd with -n (no-daemon) flag
    systemd.user.services.simd = {
      description = "SimAPI Daemon - Racing Simulator Telemetry Service";
      documentation = [ "https://github.com/Spacefreak18/simapi" ];
      after = [ "default.target" ];
      wantedBy = [ ];  # Don't auto-start, but can be started manually

      serviceConfig = {
        Type = "simple";
        Environment = [
          "LD_LIBRARY_PATH=%h/.local/lib"
          "WINEARCH=win64"
          "WINE_BIN=${wine}/bin/.wine"
          "SIMD_BRIDGE_EXE=${simshmbridge}/bin/acbridge.exe"
        ];
        ExecStartPre = "${wine}/bin/wineboot --init";
        ExecStart = "${simapi}/bin/simd -n -vv";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Create systemd user service for acshm (creates and maintains AC shared memory)
    systemd.user.services.acshm = {
      description = "Assetto Corsa Shared Memory Creator";
      documentation = [ "https://github.com/Spacefreak18/simshmbridge" ];
      after = [ "default.target" ];
      wantedBy = [ ];  # Don't auto-start, start manually or as dependency

      serviceConfig = {
        Type = "simple";
        ExecStart = "${simshmbridge}/bin/acshm";
        Restart = "on-failure";
        RestartSec = 5;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    environment.sessionVariables = {
      SIMD_CONFIG_DIR = "/home/${username}/.config/simd";
    };
  };
}

