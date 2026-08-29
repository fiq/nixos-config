{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.x-vrdesktop;
in {
  options.services.x-vrdesktop = {
    enable = mkEnableOption "custom vr desktop setup";
    enableCuda = mkOption {
      description = "setup wivern with cuda";
      type = types.bool;
      default = false;
    };
   };
  config = mkIf cfg.enable {
    services.wivrn = {
     enable = true;
      openFirewall = true;
      autoStart = true;
      package = pkgs.wivrn.override { cudaSupport = cfg.enableCuda; }; 
      steam.enable = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
    };

    environment.systemPackages = with pkgs; [
      wayvr
    ];

    # WayVR needs UINPUT to inject keyboard/mouse into niri,
    # because niri does not implement zwp_virtual_keyboard (WayVR's WL_VIRTUAL mode).
    services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660"
    '';
    # Merge 'input' group into raf's groups (defined in configuration.nix).
    users.users.raf.extraGroups = [ "input" ];
  };
}
