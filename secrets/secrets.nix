let
  agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0nndnDRH//JmRH1+CMveQaxHmDHNpbX1ExIyt39OxG agenix";
  air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDWRjW63ETfyuJImyk35c67dPXR+azB52hgcS/+gnj4 root@air";
  mini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZoUdzBwcBuwD9Rbob5sIW370Wm3hCPsvSyZj0wAqu0 root@Tonys-Mac-mini.local";
  rb14 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOX6M0TK0HlreuwtHsA8ByNMBBSlzo3PMt23Nl+E3J6k root@nixos";
in {
  "air/github.age".publicKeys = [ agenix air ];
  "mini/github.age".publicKeys = [ agenix mini ];
  "rb14/github.age".publicKeys = [ agenix rb14 ];
}
