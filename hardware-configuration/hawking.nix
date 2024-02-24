{ config, lib, pkgs, inputs, musnix, modulesPath, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_6_5;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  networking.hostName = "hawking";
 
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      ./x-android-dev.nix
#      ./x-guitar.nix
      ./x-pulseaudio.nix
      ./x-rtl-sdr.nix
      ./x-yubi.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  #boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "mt7921e" "snd-seq" "snd-rawmidi" ];
#  boot.kernelModules = [ "kvm-amd" "mt7921e" ];
  boot.extraModulePackages = [ ];
  nixpkgs.config.cudaSupport  = true;

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
    cudaPackages.cudatoolkit
    yuzu-early-access
  ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Steam
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  # Enable Guitar Kit
#  services.x-guitar.enable = true;

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

    musnix = {
      enable = true;
      # Not using any of Musnix' inbuilt optimisations, because they depend on a
      # realtime kernel, which is
      # a) not required for sufficient responsiveness
      # b) incompatible with running VMs via Virtualbox.
#      kernel = {
#        optimize = false;
#        realtime = false;
        # Confirm _actual_ latest available kernel at:
        # https://github.com/musnix/musnix/blob/master/modules/kernel.nix
        #packages = pkgs.linuxPackages_5_9_rt;
#      };
    };

    # Kernel configuration
    # Do it the hard way, because Musnix assumes the RT kernel is wanted
    nixpkgs.overlays = [
      (self: super: {
        linuxDAW = pkgs.linuxPackagesFor (pkgs.linux_daw.override {
          structuredExtraConfig = with pkgs.lib.kernel; {
            PREEMPT = yes;
            HPET_TIMER = yes;
          };
          #ignoreConfigErrors = true;
        });
      })
   ];
    # As-yet unused, but potentially useful kernel configs:
    #          #IOSCHED_DEADLINE y
    #          MQ_IOSCHED_DEADLINE y
    #          CONFIG_1000_HZ y   # Seems to be obsolete; was explicitly ignored last I tried it.

    #boot.kernelPackages = pkgs.linuxPackages_5_10;

    # Enable user `raf` to use realtime audio
    users.users.raf.extraGroups = [ "audio" ];

    # Enable the RealtimeKit system service,
    # which hands out realtime scheduling priority to user processes on demand.
    security.rtkit.enable = true;

    # Use an appropriate CPU performance governor
    # Often used values: "ondemand", "powersave", "performance"
    powerManagement.cpuFreqGovernor = "performance";

    # System limits for Ardour, esp. realtime scheduling.
    # Seems obsolete as at 2020/03/28, but keeping this here for reference in case I was wrong.
    #systemd.extraConfig = "DefaultLimitNOFILE=4096\nDefaultLimitMEMLOCK=4G:16G\nDefaultLimitRTPRIO=40";
    #systemd.extraConfig = "DefaultLimitNOFILE=4096\nDefaultLimitMEMLOCK=24G:16G\nDefaultLimitRTPRIO=40";

    # JACK configuration
    #boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
    hardware.pulseaudio.package =
      pkgs.pulseaudio.override { jackaudioSupport = true; };
    hardware.pulseaudio.enable = true;

}
