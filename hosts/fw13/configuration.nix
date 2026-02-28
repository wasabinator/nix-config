{ config, pkgs, lib, self, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (self + "/modules/nixos/locale.nix")
    (self + "/modules/nixos/fonts.nix")
    (self + "/modules/nixos/networking.nix")
    (self + "/modules/nixos/system.nix")
    (self + "/modules/nixos/laptop.nix")
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_pmf.disable=1"
    "amdgpu.dcdebugmask=0x412"
    "amdgpu.sg_display=0"
    "mem_sleep_default=deep"
  ];
  boot.initrd.luks.devices."luks-4386fb32-c937-4460-8f81-8d0477ac5364".device = "/dev/disk/by-uuid/4386fb32-c937-4460-8f81-8d0477ac5364";

  networking.hostName = "fw13";

  services.fwupd.enable = true;
  hardware.framework.amd-7040.preventWakeOnAC = true;

  system.stateVersion = "24.11";
}

