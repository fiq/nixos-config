{ 
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # default to unstable
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-home-assistant.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # always pegged to unstable
    hyprland.url = "github:hyprwm/Hyprland";
    musnix.url = "github:musnix/musnix";    
    home-manager.url = "github:nix-community/home-manager/master"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fjordlauncher.url = "github:unmojang/FjordLauncher";
    fjordlauncher.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  }; 
  outputs = {nixpkgs, unstablepkgs, home-manager, musnix, ...} @ inputs: let
    system = "x86_64-linux";
#    pkgs = nixpkgs.legacyPackages.${system};

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.nix-vscode-extensions.overlays.default
      ];
    };
    
    unstable = import unstablepkgs { system = "${system}"; config.allowUnfree = true; };
  in {
    nixosConfigurations."hawking" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable musnix;};
      modules = [./configuration.nix ./hardware-configuration/hawking.nix inputs.musnix.nixosModules.musnix];
    };

    nixosConfigurations."feynman" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable musnix;};
      modules = [./configuration.nix ./hardware-configuration/feynman.nix inputs.musnix.nixosModules.musnix];
    };

    nixosConfigurations."ada" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs unstable musnix;};
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            (final: prev: {
              home-assistant = inputs.nixpkgs-home-assistant.legacyPackages.${final.system}.home-assistant;
            })
          ];
        })
        ./configuration.nix ./hardware-configuration/ada.nix];
    };


    homeConfigurations = (import ./home-manager/default.nix {inherit inputs nixpkgs unstablepkgs home-manager;});
  };
}
