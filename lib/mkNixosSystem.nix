{ nixpkgs, home-manager, inputs, self }:
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
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.amiceli.imports = [
        (self + "/hosts/common/home.nix")
      ] ++ homeModules;
      home-manager.backupFileExtension = "home-manager-backup";
    }
  ] ++ extraModules;
}
