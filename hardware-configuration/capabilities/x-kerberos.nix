{ lib, pkgs, config, ... }:

with lib;

let
  cfg = config.services.x-kerberos;

  # Build a local lightweight image for Kinect/webcams
  baseKinectImage = pkgs.dockerTools.buildImage {
    name = "kinect-webcam";
    tag = "latest";

    # Minimal userland + packages needed for webcams and Kinect
    copyToRoot = pkgs.buildEnv {
      name = "kinect-webcam-packages";
      paths = with pkgs; [
        coreutils
        bash
        ffmpeg
        v4l-utils
        libusb1
        freenect    # Kinect support
      ];
    };

    # Idle placeholder process; runs as a non-root numeric user (runAsNonRoot)
    config = {
      Cmd = [ "/bin/sleep" "infinity" ];
      User = "65534";
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
      bash
    ];

    environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

    # Expose Kubernetes manifests to /etc/k8s/kerberos
    environment.etc."k8s/kerberos".source = cfg.manifestsPath;

    # Load the local Kinect/Webcam image into k3s deterministically
    systemd.services."k8s-kinect-images" = {
      description = "Load local Kinect/Webcam images into k3s";
      after = [ "k3s.service" ];
      wants = [ "k3s.service" ];
      restartTriggers = [ baseKinectImage ];
      path = [ config.services.k3s.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        echo "Waiting for k3s containerd to be ready..."
        for _ in $(seq 1 30); do
          k3s ctr version &>/dev/null && break
          sleep 2
        done
        echo "Importing Kinect/Webcam images into k3s..."
        k3s ctr -n k8s.io images import ${baseKinectImage}
      '';
      wantedBy = [ "multi-user.target" ];
    };

    # Apply all Kerberos manifests to the cluster
    systemd.services."k8s-kerberos-apply" = {
      description = "Apply Kerberos manifests to local k3s cluster";
      after = [ "k3s.service" "k8s-kinect-images.service" ];
      wants = [ "k3s.service" "k8s-kinect-images.service" ];
      restartTriggers = [ cfg.manifestsPath ];
      path = [ pkgs.kubectl ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "KUBECONFIG=/etc/rancher/k3s/k3s.yaml";
      };
      script = ''
        echo "Waiting for K3s API to be ready..."
        for _ in $(seq 1 30); do
          kubectl get nodes &>/dev/null && break
          sleep 2
        done
        echo "Applying Kerberos manifests..."
        kubectl apply -f /etc/k8s/kerberos --recursive
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}

