{ pkgs, ... }:
{
  # GNOME
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enable = true;

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

  # Firefox
  programs.firefox.enable = true;

  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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
}

