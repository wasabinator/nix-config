{ ... }: 
let
  shared = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
in {
  flake.modules.nixos.system = { pkgs, ... }: shared // {
    nix.gc.automatic = true;
    services.angrr.enable = true;

    environment.systemPackages = with pkgs; [
      appimage-run
    ];
  };

  flake.modules.darwin.system = { ... }: shared // {
  };
}
