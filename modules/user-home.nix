{ config, lib, ... }:
let
  username = config.flake.meta.owner.username;
in {
  flake.nixosModules.user-home = { config, lib, ... }: {
    options.home = lib.mkOption {
      type = lib.types.deferredModule;
      default = {};
    };
    config.home-manager.users.${username} = config.home;
  };

  flake.darwinModules.user-home = { config, lib, ... }: {
    options.home = lib.mkOption {
      type = lib.types.deferredModule;
      default = {};
    };
    config.home-manager.users.${username} = config.home;
  };
}
