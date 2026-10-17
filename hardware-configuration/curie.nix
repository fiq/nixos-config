{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
       ./capabilities/x-audio.nix
       ./capabilities/x-bt.nix
       ./capabilities/x-displaylink.nix
       ./capabilities/x-tiling-desktop.nix
       ./capabilities/x-vrdesktop.nix
    ];

  networking.hostName = "curie";
  hardware.asahi.enable = true;
  hardware.asahi.peripheralFirmwareDirectory = ./apple-silicon-firmware;

  # resolved's own mDNS responder fights avahi on wlan0 -- endless
  # curie -> curie-2 -> curie-3 renaming. Avahi stays sole responder.
  services.resolved.settings.Resolve.MulticastDNS = false;

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
  # blueman tray icon and pairing window, same as hawking
  services.x-bt.enable = true;
  # Targus DV2K dock (DisplayLink); dlm only does work while the dock is plugged in
  services.x-displaylink.enable = true;

  # Pro Audio on the speaker card skips the Asahi speaker DSP and its volume
  # lock (the rules only match HiFi), so pin HiFi instead of trusting saved state.
  services.x-audio = {
    enable = true;
    deviceProfiles."~alsa_card\\.platform-(sound|audio\\..*)" = "HiFi";
  };
  # Setup sway and niri
  services.x-tiling-desktop.enable = true;
  services.x-vrdesktop.enable = true;
  services.x-vrdesktop.enableCuda = false;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
