{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
       ./capabilities/x-tiling-desktop.nix
    ];

  networking.hostName = "curie";
  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./apple-silicon-firmware;

  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.efi.efiSysMountPoint = lib.mkForce "/boot";
  boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/0529293f-418f-486a-82e6-a7d3c5fd8e8b";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BECF-1B23";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ ];

  services.upower.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.useDHCP = lib.mkDefault true;
  # Setup sway and niri
  services.x-tiling-desktop.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
