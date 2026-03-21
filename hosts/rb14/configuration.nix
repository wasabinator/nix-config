{ config, pkgs, lib, inputs, self, ... }:
{
imports = [
  ./hardware-configuration.nix
  (self + "/modules/nixos/locale.nix")
  (self + "/modules/nixos/networking.nix")
  (self + "/modules/nixos/system.nix")
  (self + "/modules/nixos/laptop.nix")
];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_18; # linuxPackages_latest won't work with latest nvidia driver (ref: https://github.com/nixos/nixpkgs/issues/489947)
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  boot.extraModprobeConfig = ''
    options nvidia NVreg_DynamicPowerManagement=2
    options nvidia NVreg_DynamicPowerManagementVideoMemoryThreshold=0
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    options nvidia NVreg_EnableS0ixPowerManagement=1
    options nvidia NVreg_S0ixPowerManagementVideoMemoryThreshold=0
  '';
  boot.initrd.prepend = lib.mkOrder 0 [
    "${(pkgs.callPackage ./custom-dsdt.nix {})}/dsdt.cpio"
  ];

  networking.hostName = "rb14";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.fwupd.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" "nvidia" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.initrd.enable = true;
  hardware.enableRedistributableFirmware = true;

  hardware.nvidia = {
    open = false;
    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  specialisation = {
    battery.configuration = {
      system.nixos.tags = [ "battery" ];
      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;
      hardware.nvidia.powerManagement.finegrained = lib.mkForce false;
      hardware.nvidia.powerManagement.enable = lib.mkForce false;
      hardware.nvidia.modesetting.enable = lib.mkForce false;
      boot.blacklistedKernelModules = [ "nvidia" "nvidia_drm" "nvidia_modeset" "nvidia_uvm" ];
      services.udev.extraRules = lib.mkForce ''
        SUBSYSTEM=="drm", DEVPATH=="*/0000:04:00.0/drm/card*", TAG+="mutter-device-preferred-primary"
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
      '';
      systemd.services.disable-dgpu = {
        description = "Remove dGPU from PCI bus";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-udev-settle.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove'";
        };
      };
      systemd.services.disable-dgpu-resume = {
        description = "Remove dGPU from PCI bus after resume";
        after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove'";
        };
      };
    };
  };

  systemd.services.nvidia-resume.enable = true;
  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-hibernate.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="drm", DEVPATH=="*/0000:04:00.0/drm/card*", TAG+="mutter-device-preferred-primary"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
  '';

  environment.sessionVariables = {
    ELECTRON_EXTRA_LAUNCH_ARGS = "--disable-gpu";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "nvidia-run" ''
      sudo ${pkgs.kmod}/bin/modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia
      sudo ${pkgs.kmod}/bin/modprobe nvidia
      nvidia-offload "$@"
    '')
  ];

  system.stateVersion = "25.11";
}

