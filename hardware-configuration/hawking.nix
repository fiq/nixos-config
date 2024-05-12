{ config, lib, pkgs, unstable, inputs, musnix, modulesPath, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_8;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  networking.hostName = "hawking";
 
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      ./x-android-dev.nix
      ./x-musician.nix
      ./x-rtl-sdr.nix
      ./x-yubi.nix
    ];

#      ./x-pulseaudio.nix
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" "mt7921e" ];
  boot.extraModulePackages = [ ];
  nixpkgs.config.cudaSupport  = true;

  # Llama
  services.ollama.enable = true;
  services.ollama.acceleration = "cuda";
  services.ollama.package = unstable.ollama;


  fileSystems."/" =
    { device = "/dev/disk/by-label/NixOS";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/Home";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  services.xserver.videoDrivers = [ "nvidia" ];
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
 
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];

  hardware.nvidia = {
    modesetting.enable = true;
    
 #   open = true;
    open = false;
    
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:16:0:0";
    };
  };

  # hawking specific pkgs
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    mumble
  ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Steam
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  # Enable Guitar and midi Kit
  services.x-musician.enable = true;

  # RTL SDR custom module
  services.x-rtl-sdr.enable = true;

  # Setup android and godot dev tools
  services.x-android-dev.enable = true;

  # Enable pulse audio custom module
#  services.x-pulseaudio.enable = true;

  # Enable yubi module
  services.x-yubi.enable = true;

  # Allow ports
  networking.firewall.allowedTCPPorts = [ 22 8090 8400 ];

}
