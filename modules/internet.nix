{ config, ... }: {
  flake.nixosModules.internet = { pkgs, ... }: {
    home = {
      home.packages = with pkgs; [
        firefox
        (pkgs.signal-desktop.override {
          commandLineArgs = "--disable-gpu";
        })
      ];
      xdg.mimeApps.defaultApplications = builtins.listToAttrs (
        map (mime: { name = mime; value = "firefox.desktop"; }) [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ]
      );
    };
  };

  flake.darwinModules.signal = { ... }: {
    homebrew.casks = [
      "firefox"
      "signal"
    ];
  };
}
