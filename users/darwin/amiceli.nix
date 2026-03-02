{ ... }:
{
  users.users.amiceli = {
    name = "amiceli";
    home = "/Users/amiceli";
  };

  home-manager.users.amiceli.programs.git = {
    enable = true;
    ignores = [ ".DS_Store" ".direnv" ];
    settings.user = {
      email = "6946957+wasabinator@users.noreply.github.com";
      name = "Tony Miceli";
    };
  };
}
