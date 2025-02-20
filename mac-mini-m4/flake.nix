{
  description = "Home Manager configuration of amiceli";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ nixpkgs, home-manager, brew-nix, mac-app-util, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."amiceli" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          mac-app-util.homeManagerModules.default
          ({ ... }: {
            nixpkgs.overlays = [ brew-nix.overlays.default ];
          })
          ./home.nix 
        ];
      };
    };
}
