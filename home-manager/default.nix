{ nixpkgs, home-manager, inputs, ... }:
let
  # Destructure the inputs you need from the flake
  inherit (inputs) nixpkgs home-manager nix-vscode-extensions;

  makeHomeManagerConfig = name: value:
    let
      system = value.system;
      # Desktop weight for this config; see the role block at the top of home.nix.
      # Free choice per entry, not tied to a machine or to any NixOS option.
      role = value.role or "full-desktop";
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
    assert nixpkgs.lib.assertMsg (builtins.elem role [ "full-desktop" "tiling" "server" ])
      "home-manager config ${name}: role must be full-desktop, tiling or server (got ${role})";
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
      extraSpecialArgs = { inherit inputs unstable isArm isDarwin isAsahi role; };
    };

in
# One line per config. role is optional: "full-desktop" (default) | "tiling" | "server".
# The name is just a label: any machine can switch to any entry, e.g.
#   home-manager switch --flake .#raf@feynman   (tiling)
#   home-manager switch --flake .#raf            (full-desktop)
builtins.mapAttrs makeHomeManagerConfig {
  "raf" = { user = "raf"; homePath = "/home"; system = "x86_64-linux"; };
#  "raf@curie" = { user = "raf"; homePath = "/Users"; system = "aarch64-darwin"; };
  "raf@curie.mac" = { user = "raf"; homePath = "/Users"; system = "aarch64-darwin"; };
  "raf@curie.linux" = { user = "raf"; homePath = "/home"; system = "aarch64-linux"; };
  "raf@feynman" = { user = "raf"; homePath = "/home"; system = "x86_64-linux"; role = "tiling"; };
  "raf@ada" = { user = "raf"; homePath = "/home"; system = "x86_64-linux"; role = "server"; };
}

