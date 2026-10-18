{ lib, pkgs, config, inputs, ... }:
with lib;
let cfg = config.services.x-minecraft;
in {
  options.services.x-minecraft = {
    enable = mkEnableOption "minecraft launchers (Fjord, Prism)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      inputs.fjordlauncher.packages.${pkgs.stdenv.hostPlatform.system}.fjordlauncher
      pkgs.prismlauncher
    ];
  };
}
