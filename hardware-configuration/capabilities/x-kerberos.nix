{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.x-kerberos;

  # Build a local lightweight image for Kinect / webcams
  baseKinectImage = pkgs.dockerTools.buildImage {
    name = "kinect-webcam";
    tag = "latest";

    contents = with pkgs; [
      alpine
      bash
      ffmpeg
      v4l-utils
      libusb
      libfreenect
    ];

    config = {
      Cmd = [ "/bin/bash" ];
      Entrypoint = [ "/bin/bash" ];
    };
  };
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
      ffmpeg
      jq
      kubectl
      v4l-utils
    ];

    environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    # Expose Kubernetes manifests to /etc/k8s/kerberos
    environment.etc."k8s/kerberos".source = cfg.manifestsPath;

    # Systemd service: import local Kinect/Webcam image into k3s
    systemd.services."k8s-kinect-images" = {
      description = "Load local Kinect/Webcam images into k3s";
      after = [ "k3s.service" ];
      wants = [ "k3s.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          echo "Importing Kinect/Webcam images into k3s..."
          ${pkgs.containerd}/bin/ctr -n k8s.io images import ${baseKinectImage}
        '';
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Systemd service: apply all Kerberos manifests
    systemd.services."k8s-kerberos-apply" = {
      description = "Apply Kerberos manifests to local k3s cluster";
      after = [ "k3s.service" ];
      wants = [ "k3s.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "KUBECONFIG=/etc/rancher/k3s/k3s.yaml";
        ExecStart = ''
          echo "Waiting for K3s API to be ready..."
          for i in $(seq 1 30); do
            kubectl get nodes &>/dev/null && break
            sleep 2
          done
          echo "Applying Kerberos manifests..."
          kubectl apply -f /etc/k8s/kerberos --recursive
        '';
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}

