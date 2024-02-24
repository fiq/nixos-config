{ lib, config, pkgs, ... }:
with lib;
  let cfg = config.services.x-guitar;
in {
  options.services.x-guitar = {
    enable = mkEnableOption "custom guitar setup";
  };
 
  config = mkIf cfg.enable {
	  imports = [
	    <musnix>                      # Channel
	    ];

	  musnix = {
	    enable = true;
	    # Not using any of Musnix' inbuilt optimisations, because they depend on a
	    # realtime kernel, which is
	    # a) not required for sufficient responsiveness
	    # b) incompatible with running VMs via Virtualbox.
	    kernel = {
	      optimize = false;
	      realtime = false;
	      # Confirm _actual_ latest available kernel at:
	      # https://github.com/musnix/musnix/blob/master/modules/kernel.nix
	      #packages = pkgs.linuxPackages_5_9_rt;
	    };
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
	  boot.kernelModules=["snd-seq" "snd-rawmidi" ];
	  hardware.pulseaudio.package = pkgs.pulseaudio.override { jackaudioSupport = true; };
	  hardware.pulseaudio.enable = true;  
	};
}
