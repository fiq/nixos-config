{ 
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    prismlauncher.url = "github:unmojang/prismlauncher/custom-yggdrasil";
    hyprland.url = "github:hyprwm/Hyprland";
    musnix.url = "github:musnix/musnix";    
    home-manager.url = "github:nix-community/home-manager/release-23.11"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  }; 
  outputs = {nixpkgs, unstablepkgs, home-manager, musnix, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    
    unstable = import unstablepkgs { system = "${system}"; config.allowUnfree = true; };
  in {
    nixosConfigurations."hawking" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable musnix;};
      modules = [./configuration.nix ./hardware-configuration/hawking.nix inputs.musnix.nixosModules.musnix];
    };

    nixosConfigurations."feynman" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable musnix;};
      modules = [./configuration.nix ./hardware-configuration/feynman.nix];
    };

    homeConfigurations = (import ./home-manager/default.nix {inherit inputs nixpkgs home-manager;});
  };
}
