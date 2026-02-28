let
  hostKeys = {
    air = "ssh-ed25519 ...";
    mini = "ssh-ed25519 ...";
    rb14 = "ssh-ed25519 ...";
  };
  agenix = "ssh-ed25519 ...";
  users = [ "amiceli" ];
  hosts = builtins.attrNames hostKeys;
in
builtins.listToAttrs (
  builtins.concatMap (host:
    map (user: {
      name = "${host}/${user}/github.age";
      value = { publicKeys = [ agenix hostKeys.${host} ]; };
    }) users
  ) hosts
)

