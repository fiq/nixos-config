{ home-manager, nixpkgs, inputs, ... }:

{
 "raf" = let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ./home.nix
      {
        home = {
          username = "raf";
          homeDirectory = "/home/raf";
        };
      }
    ];
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
