{ nixpkgs, home-manager, agenix, inputs, self }:
{ hostname, system ? "x86_64-linux", extraModules ? [], homeModules ? [] }:

nixpkgs.lib.nixosSystem {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  modules = [
    (self + "/hosts/${hostname}/configuration.nix")
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs hostname; };
      home-manager.users.amiceli.imports = [
        (self + "/hosts/common/home.nix")
      ] ++ homeModules;
      home-manager.backupFileExtension = "home-manager-backup";
    }
    agenix.nixosModules.default
    {
      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.secrets.github = {
        file = self + "/secrets/$hostname/github.age";
        mode = "0600";
        owner = "amiceli";
      };
    }
  ] ++ extraModules;
}

