{ 
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    prismlauncher.url = "github:unmojang/prismlauncher/custom-yggdrasil";
    home-manager.url = "github:nix-community/home-manager/release-23.05"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  }; 
  outputs = {nixpkgs, home-manager, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations."hawking" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [./configuration.nix ./hardware-configuration/hawking.nix];
    };

    nixosConfigurations."feynman" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [./configuration.nix ./hardware-configuration/feynman.nix];
    };


    homeConfigurations = (import ./home-manager/default.nix {inherit inputs nixpkgs home-manager;});
  };
}
