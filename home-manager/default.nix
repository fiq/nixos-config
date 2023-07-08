{ home-manager, nixpkgs, inputs, ... }:

let makeHomeManagerConfig = name: value: let
    system = "${value.system}";
    pkgs = nixpkgs.legacyPackages.${system};
  in home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ./home.nix
      {
        home.username = "${name}";
        home.homeDirectory = "${value.homePath}/${name}";
      }
    ];
    extraSpecialArgs = {inherit inputs;};
  };  

in builtins.mapAttrs (makeHomeManagerConfig) {
  "raf" = { homePath = "/home"; system = "x86_64-linux"; };
  "innovation" = { homePath = "/Users"; system = "aarch64-darwin"; };
}
