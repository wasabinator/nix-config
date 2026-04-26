{ config, lib, ... }:
let
  homeConfig = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

      mutableExtensionsDir = true;  # allows installing extensions manually too

      extensions = with pkgs.vscode-extensions; [
        # direnv integration - picks up devenv/direnv environments automatically
        mkhl.direnv

        # Nix
        jnoortheen.nix-ide

        # Rust
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb        # debugging

        # General
        usernamehw.errorlens       # inline errors
        gruntfuggly.todo-tree
        eamodio.gitlens
      ];

      userSettings = {
        "editor.formatOnSave"          = true;
        "editor.rulers"                = [ 100 ];
        "editor.minimap.enabled"       = false;
        "files.trimTrailingWhitespace" = true;

        # Nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath"           = "nil";

        # Rust - let rust-analyzer come from direnv/devenv rather than globally
        "rust-analyzer.server.extraEnv" = {};
        "[rust]"."editor.defaultFormatter" = "rust-lang.rust-analyzer";

        # direnv - automatically apply environment when opening a project
        "direnv.restart.automatic" = true;

        # Terminal inherits the direnv environment
        "terminal.integrated.defaultProfile.linux" = "bash";
      };
    };

    # nil and direnv need to be in PATH for the extensions to find them
    home.packages = with pkgs; [
      nil
      direnv
      nix-direnv
    ];
  };
in
{
  flake.modules.nixos.vscode = { pkgs, ... }: {
    home = lib.recursiveUpdate (homeConfig { inherit pkgs; }) {};
  };
  flake.modules.darwin.vscode = { pkgs, ... }: {
    home = lib.recursiveUpdate (homeConfig { inherit pkgs; }) {};
  };
}
