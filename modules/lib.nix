{ lib, config, inputs, age, ... }: {
  config.flake.lib = {
    mkUserSecrets = { username, hosts, secrets ? [ "github" ] }:
      let
        mkHostSecrets = host: {
          age.secrets = builtins.listToAttrs (map (secret: {
            name = secret;
            value = {
              file = inputs.self + "/secrets/${host}/${username}/${secret}.age";
              mode = "0600";
              owner = username;
            };
          }) secrets);
        };
      in builtins.listToAttrs (map (host: {
        name = "${host}-user-secrets";
        value = mkHostSecrets host;
      }) hosts);
  };
}
