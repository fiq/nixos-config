{ config, lib, pkgs, modulesPath, ... }:

{
  networking.hostName = "feynman";
  imports =
    [ 
      "${builtins.fetchGit {
        url = "https://github.com/NixOS/nixos-hardware.git";
        ref = "master";
        rev =  "47dca15d86fdd2eabcf434d7cc0b5baa8d1a463c";
       }}/dell/xps/13-9370"
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
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

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.loader.grub.useOSProber = true;

  # I use RTL-SDR on both hawking and feynman but may not do on other boxes
  hardware.rtl-sdr.enable = true;
}
