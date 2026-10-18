{ config, lib, pkgs, unstable, inputs, musnix, modulesPath, ... }:

{
  nixpkgs.config.allowBroken = true;
  networking.hostName = "feynman";
  # Tiling only (sway/niri/hyprland), SDDM logs in to niri; no Plasma/GNOME, no Minecraft
  services.x-desktop-base.enable = true;
  services.x-tiling-environments.enable = true;
  services.displayManager.defaultSession = "niri";
  imports =
    [ 
      "${builtins.fetchGit {
        url = "https://github.com/NixOS/nixos-hardware.git";
        ref = "master";
        rev =  "d6645c340ef7d821602fd2cd199e8d1eed10afbc";
       }}/dell/xps/13-9370"
       ./capabilities/x-android-dev.nix
       ./capabilities/x-audio.nix
       ./capabilities/x-desktop-base.nix
       ./capabilities/x-home-assistant.nix
       ./capabilities/x-kerberos.nix
       ./capabilities/x-network-storage.nix
       ./capabilities/x-rtl-sdr.nix
       ./capabilities/x-tiling-environments.nix
       ./capabilities/x-yubi.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
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

  # Media/backup folders are copied over from ada by hand into /mnt/backups
  # minidlna group (setgid) gets write access so raf can manage the media
  users.users.raf.extraGroups = [ "minidlna" ];
  systemd.tmpfiles.rules = [
    "d /mnt/backups 2775 minidlna minidlna -"
    "d /home/minidlna 2775 minidlna minidlna -"
    "L /home/minidlna/external - - - - /mnt/backups"
  ];

  swapDevices = [ ];
  services.upower.enable = true;
  
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = true;
  boot.loader.grub.useOSProber = true;

  # Predictable audio defaults (feynman has no host-specific device rules yet)
  services.x-audio.enable = true;

  # RTL SDR custom module
  services.x-rtl-sdr.enable = false;

  # Setup android dev
  services.x-android-dev.enable = false;

  # Enable yubi module
  services.x-yubi.enable = true;

  environment.systemPackages = with pkgs; [
    grafana
    spotify
    python3
  ];

  # Server services inherited from ada
  services.x-home-assistant.enable = true;
  services.x-network-storage.enable = true;
  services.x-kerberos.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 9999 8765 8080 3000 5173 ];
}
