{ 
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    prismlauncher.url = "github:unmojang/prismlauncher/custom-yggdrasil";
    home-manager.url = "github:nix-community/home-manager/release-23.05"; 
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  }; 
  outputs = {nixpkgs, home-manager, ...} @ inputs: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    "raf" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home-manager/users/raf/home.nix ];
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
