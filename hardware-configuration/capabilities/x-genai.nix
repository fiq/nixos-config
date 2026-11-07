{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.x-genai;
in {
  options.services.x-genai = {
    enable = mkEnableOption "custom GenAI system setup";
    enableCuda = mkOption {
      description = "CUDA-backed local GenAI tooling";
      type = types.bool;
      default = false;
    };
    enableOllama = mkOption {
      description = "Ollama service";
      type = types.bool;
      default = false;
    };

    enableLlamaCpp= mkOption {
      description = "LlamaCpp enabled";
      type = types.bool;
      default = false;
    };
 
  
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        opencode = prev.opencode.overrideAttrs (old: {
          node_modules = old.node_modules.overrideAttrs (_: {
            outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
          });
        });
      })
    ];

    services.ollama = mkIf cfg.enableOllama {
      enable = true;
      package = if cfg.enableCuda then pkgs.ollama-cuda else pkgs.ollama;
    };

    environment.systemPackages =
      (with pkgs; [
        codex
        claude-code
        opencode
        opencode-claude-auth
        opencode-desktop
        claude-agent-acp
        claude-code-router
        claude-monitor
      ])
      ++ optionals cfg.enableLlamaCpp(with pkgs; [
        llama-cpp
      ])
      ++ optionals cfg.enableCuda (with pkgs; [
        cudaPackages.cudatoolkit
      ]);
  };
}
