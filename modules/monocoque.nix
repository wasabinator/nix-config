{ config, lib, ... }:
let
  username = config.flake.meta.owner.username;
in
{
  flake.modules.nixos.monocoque = { pkgs, ... }:
  let
    argtable2 = pkgs.callPackage ../derivations/argtable2.nix {};
    simapi = pkgs.callPackage ../derivations/simapi.nix {
      inherit argtable2;
    };
    simshmbridge = pkgs.callPackage ../derivations/simshmbridge.nix {};
    monocoque = pkgs.callPackage ../derivations/monocoque.nix {
      inherit argtable2 simapi;
    };
  in {
    environment.systemPackages = [
      monocoque
      simshmbridge
      
      # Supporting tools
      pkgs.arduino-cli
      pkgs.lua5_4
      pkgs.libconfig
      pkgs.libuv
      pkgs.libserialport
      pkgs.hidapi
      pkgs.libxdg_basedir
      pkgs.pipewire
      pkgs.libpulseaudio
    ];

    # Optional: Add udev rules for USB HID devices (wheels, pedals, etc.)
    services.udev.extraRules = ''
      # Moza R5 and other USB HID racing devices
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16d0", MODE="0666"
      # Generic USB HID devices
      SUBSYSTEMS=="usb", KERNEL=="hiddev*", MODE="0666"
    '';

    # Create systemd service for monocoque daemon (optional)
    systemd.user.services.monocoque = {
      description = "Monocoque device manager daemon";
      after = [ "sound.target" ];
      wantedBy = [ ];  # Don't auto-start, but can be started manually
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${monocoque}/bin/monocoque";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    environment.sessionVariables = {
      MONOCOQUE_CONFIG_DIR = "/home/${username}/.config/monocoque";
    };
  };
}
