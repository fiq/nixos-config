{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.services.x-kerberos;
in
{
  options.services.x-kerberos = {
    enable = mkEnableOption "Kerberos.io surveillance (K8s-based)";
    manifestsPath = mkOption {
      type = types.path;
      default = ./../../../k8s;
      description = "Path to Kubernetes manifests for Kerberos";
    };
  };

  config = mkIf cfg.enable {
    services.k3s = {
      enable = true;
      server = {
        enable = true;
        extraArgs = [ "--no-deploy=traefik" ]; # optional
      };
    };

    environment.systemPackages = with pkgs; [
      kubectl
    ];

    environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    environment.etc."k8s/kerberos".source = cfg.manifestsPath;
  };
}

