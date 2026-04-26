{ config, inputs, ... }: {
  flake.modules.nixos.agenix = {
    imports = [ inputs.agenix.nixosModules.default ];
    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    home = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "github.com" = {
            user = "git";
            identityFile = "/run/agenix/github";
          };
        };
      };
    };
  };

  flake.modules.darwin.agenix = {
    imports = [ inputs.agenix.darwinModules.default ];
    age.identityPaths = [ "/private/var/root/.ssh/id_ed25519" ];
    home = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "github.com" = {
            user = "git";
            identityFile = "/private/var/run/agenix/github";
          };
        };
      };
    };
  };
}
