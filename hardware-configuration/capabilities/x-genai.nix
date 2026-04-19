{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.x-genai;
in {
  options.services.x-genai = {
    enable = mkEnableOption "custom GenAI system setup";
    cuda.enable = mkEnableOption "CUDA-backed local GenAI tooling";
    ollama.enable = mkEnableOption "Ollama service";
  };

  config = mkIf cfg.enable {
    services.ollama = mkIf cfg.ollama.enable {
      enable = true;
      package = if cfg.cuda.enable then pkgs.ollama-cuda else pkgs.ollama;
    };

    environment.systemPackages =
      (with pkgs; [
        claude-code
        claude-agent-acp
        claude-code-router
        claude-monitor
        llama-cpp
      ])
      ++ optionals cfg.cuda.enable (with pkgs; [
        cudaPackages.cudatoolkit
      ]);
  };
}
