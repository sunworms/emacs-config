{
  pkgs ? null,
  inputs ? import ./inputs.nix,
}: let
  finalPkgs =
    if pkgs != null
    then pkgs
    else
      import inputs.nixpkgs {
        config.allowUnfree = true;
        overlays = [(import inputs.emacs-overlay)];
      };

  emacs-with-packages = (finalPkgs.callPackage ./package.nix {}).default;

  compiledConfig =
    finalPkgs.runCommand "emacs-config"
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
in
  finalPkgs.symlinkJoin {
    name = "emacs-portable";
    paths = [emacs-with-packages];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/emacs \
        --add-flags "--init-directory=${compiledConfig}"
    '';
    meta.mainProgram = "emacs";
  }
