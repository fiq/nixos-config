{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
       ./capabilities/x-audio.nix
       ./capabilities/x-bt.nix
       ./capabilities/x-desktop-base.nix
       ./capabilities/x-displaylink.nix
       ./capabilities/x-genai.nix
       ./capabilities/x-minecraft.nix
       ./capabilities/x-desktop-environments.nix
       ./capabilities/x-tiling-environments.nix
       ./capabilities/x-vrdesktop.nix
    ];

  networking.hostName = "curie";
  # Full desktop: X + SDDM + GUI apps, GNOME + Plasma, tiling (sway/niri/hyprland), Minecraft launchers
  services.x-desktop-base.enable = true;
  services.x-desktop-environments.enable = true;
  services.x-tiling-environments.enable = true;
  # niri is the preferred session; GNOME/Plasma stay selectable in SDDM
  services.displayManager.defaultSession = "niri";
  services.x-minecraft.enable = true;
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

  services.x-genai = {
    enable = true;
    enableCuda = false;
    enableOllama = true;
    enableLlamaCpp = false;
  };

# Pro Audio on the speaker card skips the Asahi speaker DSP and its volume
  # lock (the rules only match HiFi), so pin HiFi instead of trusting saved state.
  services.x-audio = {
    enable = true;
    deviceProfiles."~alsa_card\\.platform-(sound|audio\\..*)" = "HiFi";
  };
  services.x-vrdesktop.enable = true;
  services.x-vrdesktop.enableCuda = false;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
