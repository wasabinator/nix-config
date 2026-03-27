{ nixpkgs, nixpkgs-old, nixpkgs-unstable, home-manager, agenix, nix-flatpak, inputs, self }:
{ hostname, username, system ? "x86_64-linux", extraModules ? [], homeModules ? [] }:
nixpkgs.lib.nixosSystem {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  specialArgs = {
    inherit inputs hostname username self;
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-old = import nixpkgs-old {
      inherit system;
      config.allowUnfree = true;
    };
  };
  modules = [
    (self + "/hosts/${hostname}/configuration.nix")
    (self + "/users/nixos/${username}.nix")
    { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs hostname username self; };
      home-manager.users.${username} = {
        imports = [
          nix-flatpak.homeManagerModules.nix-flatpak
          (self + "/modules/common/home.nix")
          (self + "/hosts/${hostname}/home.nix")
        ] ++ homeModules;
        home.stateVersion = "25.11";
      };
      home-manager.backupFileExtension = "home-manager-backup";
    }
    agenix.nixosModules.default {
      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.secrets.github = {
        file = self + "/secrets/${hostname}/${username}/github.age";
        mode = "0600";
        owner = username;
      };
    }
  ] ++ extraModules;
}

