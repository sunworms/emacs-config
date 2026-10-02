{
  description = "Sunny's Emacs config";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "";
    };
  };

  outputs = {
    self,
    nixpkgs,
    emacs-overlay,
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems f;

    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          emacs-overlay.overlays.default
        ];
      };
  in {
    packages = forAllSystems (system: let
      emacs = import ./. {
        pkgs = pkgsFor system;
        inputs = {inherit nixpkgs emacs-overlay;};
      };
    in {
      inherit emacs;
      default = emacs;
    });

    devShells = forAllSystems (system: {
      default = (pkgsFor system).mkShellNoCC {
        packages = [self.packages.${system}.default];
      };
    });
  };
}
