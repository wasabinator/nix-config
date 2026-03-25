let
  hostKeys = {
    agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0nndnDRH//JmRH1+CMveQaxHmDHNpbX1ExIyt39OxG agenix";
    air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDWRjW63ETfyuJImyk35c67dPXR+azB52hgcS/+gnj4 root@air";
    mini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZoUdzBwcBuwD9Rbob5sIW370Wm3hCPsvSyZj0wAqu0 root@Tonys-Mac-mini.local";
    rb14 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX6M0TK0HlreuwtHsA8ByNMBBSlzo3PMt23Nl+E3J6k root@nixos";
    simrig = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyDWKgL4AD3uzguKls4saI+DrO0vkSrZJUQaqQiZbVr root@simrig";
    steambox = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz2G62TD8cxlLJzEjG2523T4YOHWo11YPEeyWixjcIc root@nixos";
  };
  agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0nndnDRH//JmRH1+CMveQaxHmDHNpbX1ExIyt39OxG agenix";
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

