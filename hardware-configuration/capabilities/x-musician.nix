{ lib, pkgs, config, musnix, ... }:
with lib;
let cfg = config.services;
in {
  options.services.x-musician = {
    enable = mkEnableOption "custom guitar and midi setup";
  };

  config = mkIf cfg.x-musician.enable {
    musnix = { enable = true; };
    boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
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
    #services.pulseaudio.enable = false;
    # which hands out realtime scheduling priority to user processes on demand.
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      jack.enable = true;
    };

    security.pam.loginLimits = [
      { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
      { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
    ];

    users.users.raf.extraGroups = [ "audio" "rtkit" ];
    services.udev.extraRules = ''
      SUBSYSTEM=="sound", ATTRS{idVendor}=="12ba", ATTRS{idProduct}=="00ff", MODE="0666", GROUP="audio"
      '';


    # Use an appropriate CPU performance governor
    # Often used values: "ondemand", "powersave", "performance"
    powerManagement.cpuFreqGovernor = "performance";

    # JACK configuration
    environment.systemPackages = with pkgs; [
      guitarix
      rosegarden
      ardour
      carla
      protonup-qt # for rockband
      qpwgraph
      rtaudio
      unzip
    ];

  };

}
