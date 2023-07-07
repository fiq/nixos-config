{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    prismlauncher.url = "github:unmojang/prismlauncher/custom-yggdrasil";
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations."hawking" = let
      system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [./configuration.nix ./hardware-configuration.nix <home-manager/nixos>];
    };
  };
}
