{ config, pkgs, lib, inputs, username, self, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (self + "/modules/nixos/locale.nix")
    (self + "/modules/nixos/networking.nix")
    (self + "/modules/nixos/system.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_18; # linuxPackages_latest won't work with latest nvidia driver (ref: https://github.com/nixos/nixpkgs/issues/489947)

  networking.hostName = "steambox";

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    dynamicBoost.enable = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
    };
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # community Proton with extra patches
    ];
  };

  systemd.services.nvidia-powerd.enable = false;

  system.stateVersion = "25.11";
}

