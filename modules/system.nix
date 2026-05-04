{ ... }: 
let
  shared = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
in {
  flake.modules.nixos.system = { ... }: shared // {
    nix.gc.automatic = true;
    services.angrr.enable = true;
  };

  flake.modules.darwin.system = { ... }: shared // {
  };
}
