{ ... }:
{
  users.users.amiceli = {
    isNormalUser = true;
    description = "amiceli";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.users.amiceli = {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Tony Miceli";
        email = "6946957+wasabinator@users.noreply.github.com";
      };
    };
  };
}

