{ config, ... }: {
  flake.nixosModules.internet = { pkgs, ... }: {
    home = {
      home.packages = with pkgs; [
        #firefox
        (pkgs.signal-desktop.override {
          commandLineArgs = "--disable-gpu";
        })
      ];

      programs.firefox = {
        enable = true;
        policies = {
          DisableTelemetry = true;
          Preferences = {
            "privacy.fingerprintingProtection" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
          };
        };
      };

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

  flake.modules.darwin.internet = { ... }: {
    homebrew.casks = [
      "firefox"
      "signal"
    ];
  };
}
