{ config, lib, pkgs, modulesPath, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_5;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  networking.hostName = "hawking";
 
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      ./x-rtl-sdr.nix
      ./x-android-dev.nix
      ./x-pulseaudio.nix
      ./x-yubi.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "mt7921e" ];
  boot.extraModulePackages = [ ];

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

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];

  hardware.nvidia = {
    modesetting.enable = true;
    
    open = true;
    
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
    yuzu-early-access
  ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Steam
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  # RTL SDR custom module
  services.x-rtl-sdr.enable = true;

  # Setup android and godot dev tools
  services.x-android-dev.enable = true;

  # Enable pulse audio custom module
  services.x-pulseaudio.enable = true;

  # Enable yubi module
  services.x-yubi.enable = true;

  # Allow ports
  networking.firewall.allowedTCPPorts = [ 22 8090 8400 ];
}
