let
  agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0nndnDRH//JmRH1+CMveQaxHmDHNpbX1ExIyt39OxG agenix";
  air = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDWRjW63ETfyuJImyk35c67dPXR+azB52hgcS/+gnj4 root@air";
in {
  "air/github.age".publicKeys = [ agenix air ];
}
