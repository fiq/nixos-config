{ config, lib, pkgs, unstable, inputs, musnix, modulesPath, ... }:

{
  networking.hostName = "galileo";
  imports =
    [ 
       ./x-btrfs.nix
       ./x-yubi.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NixOS";
      options = [ "subvol=@" "compress=zstd:1" "noatime" ]; 
      fsType = "btrfs";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/NixOS";
      options = [ "subvol=@home" "compress=zstd:1" "noatime" ]; 
      fsType = "btrfs";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };


  fileSystems."/var" =
    { device = "/dev/disk/by-label/NixOS";
      options = [ "subvol=@var" "compress=zstd:1" "noatime" ]; 
      fsType = "btrfs";
    };

  services.btrfs.autoScrub.enable = true;

  swapDevices = [ ];

  environment.systemPackages = with pkgs; [
     home-assistant
     home-assistant-cli
     grafana
     spotify
     spotify-cli
     python3 
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.loader.grub.useOSProber = true;
}
