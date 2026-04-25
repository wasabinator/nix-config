{ ... }: 
let
  shared = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.gc.automatic = true;
  };
in {
  flake.modules.nixos.system = { ... }: shared // {
    services.angrr.enable = true;
  };

  flake.modules.darwin.system = { ... }: shared // {
    services.angrr.enable = true;
  };
}
