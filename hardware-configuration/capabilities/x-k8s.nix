{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.x-k8s;
  # DO NOT ENABLE with native k3s
in {
  options.services.x-k8s = {
    enable = mkEnableOption "custom k8s system setup";
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = !config.services.k3s.enable;
      message = "services.x-k8s and services.k3s both bind on 6443 - pick one";
    }];
    
    environment.systemPackages =
      (with pkgs; [
        k3d
        kubectl
        helm
        # for local client
        argocd
      ]);
  };
};
