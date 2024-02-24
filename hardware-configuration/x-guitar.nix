{ lib, pkgs, config, musnix, ... }:
with lib;
let cfg = config.services;
in {
  options.services.x-guitar = {
    enable = mkEnableOption "custom guitar setup";
  };

  config = mkIf cfg.x-guitar.enable {
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
    hardware.pulseaudio.enable = false;
    # which hands out realtime scheduling priority to user processes on demand.
    security.rtkit.enable = true;

    # Use an appropriate CPU performance governor
    # Often used values: "ondemand", "powersave", "performance"
    powerManagement.cpuFreqGovernor = "performance";

    # JACK configuration
    environment.systemPackages = with pkgs; [
#      libjack2
##      jack2
#      qjackctl
##      jack2Full
#     jack_capture
      guitarix
    ];

  };

}
