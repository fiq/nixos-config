{ 
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # default to unstable
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    hyprland.url = "github:hyprwm/Hyprland";
    musnix.url = "github:musnix/musnix";    
    home-manager.url = "github:nix-community/home-manager"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fjordlauncher.url = "github:unmojang/FjordLauncher";
    fjordlauncher.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
  }; 
  outputs = {nixpkgs, home-manager, musnix, ...} @ inputs: let
     system = "x86_64-linux";
   
  in {
    nixosConfigurations."hawking" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs musnix;};
      modules = [./configuration.nix ./hardware-configuration/hawking.nix inputs.musnix.nixosModules.musnix];
    };

    nixosConfigurations."feynman" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs musnix;};
      modules = [
        ./configuration.nix ./hardware-configuration/feynman.nix inputs.musnix.nixosModules.musnix];
    };

    nixosConfigurations."curie" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs musnix;};
      modules = [./configuration.nix ./hardware-configuration/curie.nix inputs.nixos-apple-silicon.nixosModules.default inputs.musnix.nixosModules.musnix];
    };


    # DEPRECATED: ada is being retired; its services now live on feynman.
    nixosConfigurations."ada" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs musnix;};
      modules = [
        ./configuration.nix ./hardware-configuration/ada.nix];
    };


    homeConfigurations = import ./home-manager/default.nix {inherit inputs nixpkgs home-manager;};
  };
}
