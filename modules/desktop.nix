{ config, ... }:
let
  gnome = config.flake.nixosModules.gnome;
  internet = config.flake.nixosModules.internet;
  multimedia = config.flake.nixosModules.multimedia;
in {
  flake.nixosModules.desktop = { pkgs, ... }: {
    imports = [ gnome internet multimedia ];
    
    # Sound
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Printing
    services.printing.enable = true;
    services.printing.browsing = true;
    services.printing.browsedConf = ''
      BrowseDNSSDSubTypes _cups,_print
      BrowseLocalProtocols all
      BrowseRemoteProtocols all
      CreateIPPPrinterQueues All
      BrowseProtocols all
    '';
    services.printing.drivers = with pkgs; [
      cnijfilter2
    ];

    # Japanese IME
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc ];
    };

    # Needed primarily for AppImages used
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        webkitgtk_4_1
      ];
    };

    # Switch to sudo-rs
    security.sudo-rs.enable = true;
  
    # Flatpak
    services.flatpak.enable = true;
    services.flatpak.packages = [
      "com.github.tchx84.Flatseal"
    ];

    # Samba
    services.samba.winbindd.enable = true;
    services.samba.nmbd.enable = true;

    # .local name resolution
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
  
    home = {
      home.packages = with pkgs; [
        bambu-studio
        plex-desktop
        plexamp
        protonvpn-gui
        synology-drive-client
      ];

      # Flatpak
      #services.flatpak = {
      #  enable = true;
      #  packages = [
      #    "com.github.tchx84.Flatseal"
      #  ];
      #};
    };
  };
}

