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
      default = ./k8s;
      description = "Path to Kubernetes manifests for Kerberos";
    };
  };

  config = mkIf cfg.enable {
    services.k3s.enable = true;

    environment.systemPackages = with pkgs; [
      kubectl
    ];

    environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    environment.etc."k8s/kerberos".source = cfg.manifestsPath;

		systemd.services."k8s-kerberos-apply" = {
			description = "Apply Kerberos manifests to k3s cluster";
			after = [ "k3s.service" ];
			wants = [ "k3s.service" ];
			serviceConfig = {
				Type = "oneshot";
				Environment = "KUBECONFIG=/etc/rancher/k3s/k3s.yaml";
				ExecStart = "${pkgs.kubectl}/bin/kubectl apply -f /etc/k8s/kerberos/ --recursive";
			};
			wantedBy = [ "multi-user.target" ];
		};
  };
}

