{ config, inputs, lib, ... }:
let
  #pkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
  pkgs = import inputs.nixpkgs {
    system = "aarch64-darwin";
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        direnv = prev.direnv.overrideAttrs (old: {
          doCheck = false;
        });
      })
    ];
  };
in {
  flake.darwinConfigurations.air = inputs.nix-darwin.lib.darwinSystem {
    inherit pkgs;
    modules = [
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
      inputs.nix-homebrew.darwinModules.nix-homebrew {
        nix-homebrew = {
          enable = true;
          user = config.flake.meta.owner.username;
        };
      }
      config.flake.modules.darwin.user-home
      config.flake.modules.darwin.agenix
      config.flake.modules.darwin.user
      config.flake.modules.darwin.air-user-secrets
      config.flake.modules.darwin.locale
      config.flake.modules.darwin.shell
      config.flake.modules.darwin.desktop
      config.flake.modules.darwin.laptop
      {
        # Let Determinate Nix handle Nix configuration
        nix.enable = false;
        system.configurationRevision = inputs.nix-darwin.rev or inputs.nix-darwin.dirtyRev or null;
        system.stateVersion = 5;
        nixpkgs.hostPlatform = "aarch64-darwin";
        networking.hostName = "air";
      }
    ];
  };
}
