{ config, ... }:
{
  flake.modules.darwin.ollama = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ollama  # Ollama CLI and server
    ];
    launchd.user.agents.ollama = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.ollama}/bin/ollama" "serve" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/ollama.log";
        StandardErrorPath = "/tmp/ollama.error.log";
      };
    };
    home = {
      xdg.configFile."zed/settings.json".text = builtins.toJSON {
        language_models.ollama.api_url = "http://localhost:11434";
        agent.default_model = {
          provider = "ollama";
          model = "qwen2.5-coder:14b";
        };
        edit_predictions = {
          provider = "ollama";
          model = "qwen2.5-coder:14b";
        };
      };
    };
  };
}
