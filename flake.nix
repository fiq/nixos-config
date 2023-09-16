{ 
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    prismlauncher.url = "github:unmojang/prismlauncher/custom-yggdrasil";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager.url = "github:nix-community/home-manager/release-23.05"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  }; 
  outputs = {nixpkgs, unstablepkgs, home-manager, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    
    unstable = import unstablepkgs { system = "${system}"; config.allowUnfree = true; };
  in {
    nixosConfigurations."hawking" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable;};
      modules = [./configuration.nix ./hardware-configuration/hawking.nix];
    };

    nixosConfigurations."feynman" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable;};
      modules = [./configuration.nix ./hardware-configuration/feynman.nix];
    };

    homeConfigurations = (import ./home-manager/default.nix {inherit inputs nixpkgs home-manager;});
  };
}
