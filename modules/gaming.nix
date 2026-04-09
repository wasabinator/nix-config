{ ... }: {
  flake.modules.nixos.gaming = { pkgs, lib, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      # Proton GE can be added via extraCompatPackages
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    # Environment variables for Proton and Wine
    environment.sessionVariables = {
      PROTON_LOG = "1";
      WINE_CPU_TOPOLOGY = "4:2";
      PROTON_USE_WINED3D = "1";  # Force WINED3D if needed for SimHub
    };

    # System packages for gaming
    environment.systemPackages = with pkgs; [
      # Wine and dependencies
      wine
      wine64
      winetricks

      # .NET Runtime (for applications like SimHub)
      dotnetCorePackages.runtime_8_0

      # Additional gaming utilities
      gamemode
      mangohud
      vkd3d
      dxvk
      openssl
      mono
      glib
      protontricks
    ];

    # Enable gamemode for performance optimization
    programs.gamemode.enable = true;

    # udev rules for gaming hardware (controllers, VR, etc.)
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
  };
}
