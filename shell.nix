let
  inputs = import ./_sources/generated.nix {
    fetchurl = null;
    fetchgit = null;
    fetchFromGitHub = null;
    dockerTools = null;
  };

  pkgs = import inputs.nixpkgs.src {
    config.allowUnfree = true;
    overlays = [
      (import inputs.emacs-overlay.src)
    ];
  };

  emacs-with-packages = (pkgs.callPackage ./package.nix {}).default;

  compiledConfig =
    pkgs.runCommand "emacs-config"
    {
      nativeBuildInputs = [emacs-with-packages];
    }
    ''
      mkdir -p $out/lisp
      cp ${./init.el} $out/init.el
      cp ${./early-init.el} $out/early-init.el
      cp ${./lisp}/*.el $out/lisp/
      cd $out
      emacs --batch --init-directory="$out" -L lisp -f batch-byte-compile early-init.el init.el lisp/*.el
      rm early-init.el init.el lisp/*.el
    '';

  emacs-portable = pkgs.symlinkJoin {
    name = "emacs-portable";
    paths = [emacs-with-packages];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/emacs \
        --add-flags "--init-directory=${compiledConfig}"
    '';
  };
in
pkgs.mkShell {
	packages = [
		emacs-portable
	];
}
