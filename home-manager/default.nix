{ nixpkgs, home-manager, inputs, ... }:
let
  # Destructure the inputs you need from the flake
  inherit (inputs) nixpkgs home-manager nix-vscode-extensions;

  makeHomeManagerConfig = name: value:
    let
      system = value.system;
      # Correctly instantiate pkgs for the targeted system with your overlay
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nix-vscode-extensions.overlays.default
        ];
      };

      # Optional: If you use the unstable channel inside home.nix
      unstable = import inputs.unstablepkgs {
        inherit system;
        config.allowUnfree = true;
      };

      isArm = nixpkgs.lib.hasPrefix "aarch64-" system;
      isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
      isAsahi = system == "aarch64-linux";

    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix  # Ensure this relative path correctly points to your home.nix
        {
          home.username = value.user;
          home.homeDirectory = "${value.homePath}/${value.user}";
        }
      ];
      # Pass inputs and system-specific unstable pkgs down to modules
      extraSpecialArgs = { inherit inputs unstable isArm isDarwin isAsahi; };
    };

in
builtins.mapAttrs makeHomeManagerConfig {
  "raf" = { user = "raf"; homePath = "/home"; system = "x86_64-linux"; };
#  "raf@curie" = { user = "raf"; homePath = "/Users"; system = "aarch64-darwin"; };
  "raf@curie.mac" = { user = "raf"; homePath = "/Users"; system = "aarch64-darwin"; };
  "raf@curie.linux" = { user = "raf"; homePath = "/home"; system = "aarch64-linux"; };
}

