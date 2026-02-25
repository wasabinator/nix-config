# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];
  boot.extraModprobeConfig = ''
    options nvidia NVreg_DynamicPowerManagement=2
    options nvidia NVreg_DynamicPowerManagementVideoMemoryThreshold=0
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    options nvidia NVreg_EnableS0ixPowerManagement=1
    options nvidia NVreg_S0ixPowerManagementVideoMemoryThreshold=0
  '';

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_18; 
  #linuxPackages_latest; will not currently work with latest nvidia driver (ref: https://github.com/nixos/nixpkgs/issues/489947)

  networking.hostName = "rb14"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  services.fwupd.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu" "nvidia"];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.initrd.enable = true;
  hardware.enableRedistributableFirmware = true;
  
  hardware.nvidia = {
    #package = config.boot.kernelPackages.nvidiaPackages.beta;
    open = true;
    nvidiaSettings = true;

    modesetting.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:4:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    
    powerManagement.enable = true;
    powerManagement.finegrained = true;  # turns off GPU when not in use
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

  #systemd.services.supergfxd-mode = {
  #  description = "Enforce supergfxd mode on boot";
  #  after = [ "supergfxd.service" ];
  #  wants = [ "supergfxd.service" ];
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig = {
  #    Type = "oneshot";
  #    ExecStart = "${pkgs.supergfxctl}/bin/supergfxctl -m Integrated";
  #  };
  #};

  # Tell Mutter to use the AMD iGPU as the primary display device.
  # Remove the NVIDIA HDA audio device from the PCI bus to prevent 
  # it from holding a reference that keeps the dGPU awake at idle.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", DEVPATH=="*/0000:04:00.0/drm/card*", TAG+="mutter-device-preferred-primary"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
  '';

  #services.supergfxd.enable = true;

  environment.sessionVariables = {
    "ELECTRON_EXTRA_LAUNCH_ARGS" = "--disable-gpu";
    "__EGL_VENDOR_LIBRARY_FILENAMES" = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  #services.desktopManager.plasma6.enable = true;
  #services.displayManager.sddm = {
  #  enable = true;
  
    # To use Wayland (Experimental for SDDM)
  #  wayland.enable = true;
  #};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amiceli = {
    isNormalUser = true;
    description = "amiceli";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    # This sidesteps an nvidia offload bug by manually waking the gpu prior to offloading
    (pkgs.writeShellScriptBin "nvidia-run" ''
      sudo ${pkgs.kmod}/bin/modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia
      sudo ${pkgs.kmod}/bin/modprobe nvidia
      nvidia-offload "$@"
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
