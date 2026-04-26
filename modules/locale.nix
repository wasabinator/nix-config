{ config, ... }: {
  flake.modules.nixos.locale = { pkgs, ... }: {
    fonts.fontDir.enable = true;
    fonts.fontconfig.enable = true;
    fonts.packages = with pkgs; [
      noto-fonts-cjk-sans
      nerd-fonts.jetbrains-mono
    ];

    i18n.defaultLocale = "en_AU.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };
    i18n.supportedLocales = [ "en_AU.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
      fcitx5.settings = {
        globalOptions = {
          Hotkey = {
            TriggerKeys = "Control+space";
          };
        };
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "au";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-au";
            Layout = "";
          };
          "Groups/0/Items/1" = {
            Name = "mozc";
            Layout = "";
          };
          GroupOrder."0" = "Default";
        };
      };
    };

    time.timeZone = "Australia/Melbourne";

    services.xserver.xkb = {
      layout = "au";
      variant = "";
    };

    home = {
      home.sessionVariables = {
        GTK_IM_MODULE = "wayland";
        QT_IM_MODULE = "fcitx";
        XMODIFIERS = "@im=fcitx";
        SDL_IM_MODULE = "fcitx";
      };
    };
  };

  flake.modules.darwin.locale = { ... }: {
  };
}
