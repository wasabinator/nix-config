{ config, pkgs, lib, inputs, self, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (self + "/modules/nixos/locale.nix")
    (self + "/modules/nixos/fonts.nix")
    (self + "/modules/nixos/networking.nix")
    (self + "/modules/nixos/desktop.nix")
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
    powerManagement.enable = true;
    dynamicBoost.enable = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  system.stateVersion = "25.11";
}

