{ ... }: {
  flake.modules.nixos.gaming = { pkgs, lib, ... }: 
  let
    # Custom wine derivation with explicit wine64 binary for proper 64-bit binary execution
    wineCustom = pkgs.callPackage ../derivations/wine-wow64-custom.nix {};
  in
  {
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
      WINEARCH = "win64";  # Use 64-bit wine architecture
    };

    # System packages for gaming
    environment.systemPackages = with pkgs; [
      # Wine and dependencies - custom derivation with explicit wine64 binary
      wineCustom
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
      
      # Steam Tinker Launch - for SimHub injection and custom commands
      steamtinkerlaunch
    ];

    # Enable gamemode for performance optimization
    programs.gamemode.enable = true;

    # udev rules for gaming hardware (controllers, VR, etc.)
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
  };
}
