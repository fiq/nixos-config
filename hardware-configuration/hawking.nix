{ config, lib, pkgs, unstable, inputs, musnix, modulesPath, ... }:

{
  #boot.kernelPackages = pkgs.linuxPackages_6_8;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  networking.hostName = "hawking";
  # FIXME - bump raf for tcpdump
  users.extraGroups.root.members = [ "raf" ];
  users.extraGroups.docker.members = [ "raf" ];
 
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      ./capabilities/x-authoring.nix
      ./capabilities/x-android-dev.nix
      ./capabilities/x-bt.nix
      ./capabilities/x-btrfs.nix
      ./capabilities/x-musician.nix
      ./capabilities/x-printing.nix
      ./capabilities/x-rtl-sdr.nix
      ./capabilities/x-security-dev.nix
      ./capabilities/x-yubi.nix
    ];

#      ./x-pulseaudio.nix
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" "mt7921e" ];
  boot.extraModulePackages = [ ];
  nixpkgs.config.cudaSupport  = true;
  boot.loader.systemd-boot.extraEntries = {
    "freebsd.conf" = ''
      title FreeBSD
      efi /efi/FreeBSD/loader.efi
      sort-key z_freebsd
    '';
  };

  # Llama
  services.ollama.enable = true;
  services.ollama.acceleration = "cuda";

  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "ext4";
  };

#  fileSystems."/home" = {
#    device = "/dev/disk/by-label/Home";
#    fsType = "ext4";
#  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/ExtendedMounts";
    options = [ "subvol=@home" "compress=zstd:3" ];
    fsType = "btrfs";
  };


  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  fileSystems."/mnt/ml-data" = {
    device = "/dev/disk/by-label/MINION";
    fsType = "vfat";
    options = [
      "users"
      "nofail"
     ];
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

  # Docker and nvidia container support
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    enableNvidia = true;
    rootless = {
      enable = true;
      setSocketVariable = false;
      daemon.settings = {
        runtimes = {
          nvidia.path = "${pkgs.nvidia-docker}/bin/nvidia-container-runtime";
        };
      };
    };
  };
  hardware.nvidia-container-toolkit.enable = true;

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
    libcap 
    llama-cpp
    mumble
    sidequest
  ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Steam
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  # Enable authoring and writing tools
  services.x-authoring.enable = true;


  # Enable bluetooth tools
  services.x-bt.enable = true;

  # Enable btrfs tools
  services.x-btrfs.enable = true;


  # Enable Guitar and midi Kit
  services.x-musician.enable = true;

  # RTL SDR custom module
  services.x-rtl-sdr.enable = true;

  # Setup android and godot dev tools
  services.x-android-dev.enable = true;

  # Enable pulse audio custom module
#  services.x-pulseaudio.enable = true;

  # Enable cups
  services.x-printing.enable = true;


  # Enable yubi module
  services.x-yubi.enable = true;


  # Setup android and godot dev tools
  services.x-security-dev.enable = true;

  # Allow ports: ssh 
  # To audit: 8090, 8400
  networking.firewall.allowedTCPPorts = [ 22 ];

}
