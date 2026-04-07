{ config, ... }:
let
  owner = config.flake.meta.owner;
  secrets = config.flake.lib.mkUserSecrets {
    username = config.flake.meta.owner.username;
    hosts = [ "rb14" "steambox" "wsl" "air" "mini" ];
  };
  homeModule = {
    home-manager.users.${owner.username} = {
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
      programs.git = {
        enable = true;
        ignores = [ ".DS_Store" ".direnv" ];
        settings.user = {
          email = owner.email;
          name = owner.username;
        };
      };
    };
  };
in {
  flake.nixosModules = secrets // {
    user = {
      users.users.${owner.username} = {
        isNormalUser = true;
        description = owner.username;
        extraGroups = [ "networkmanager" "wheel" ];
      };
    } // homeModule;
  };

  flake.modules.darwin = secrets // {
    user = {
      system.primaryUser = owner.username;
      users.users.${owner.username} = {
        name = owner.username;
        home = "/Users/${owner.username}";
      };
    } // homeModule;
  };
}
