{ home-manager, nixpkgs, inputs, ... }:

let
  initUserConfig = user: homePath: {
    home.username = user;
    home.homeDirectory = "${homePath}/${user}";
  };
in {
  "raf" = let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    homeConfig = initUserConfig "raf" "/home";
  in home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ ./home.nix homeConfig ];
  };

  "innovation" = let
    system = "darwin-aarch64";
    pkgs = nixpkgs.legacyPackages.${system};
  in home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    homeDirectory = "/Users/innovation";
    username = "innovation";
    extraModules = [ ./home.nix ];
  };
}
