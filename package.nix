{pkgs, ...}: let
  emacsPackagesCustom = pkgs.emacs-unstable-pgtk.pkgs;

  treesitGrammars = emacsPackagesCustom.treesit-grammars.with-all-grammars;

  emacs-with-packages = emacsPackagesCustom.withPackages (
    epkgs:
      with epkgs; [
        treesitGrammars
        treesit-auto
        magit
        meow
        gcmh
        apheleia
        company
        company-auctex
        company-bibtex
        nix-ts-mode
        pdf-tools
        auctex
        auctex-latexmk
        cdlatex
        xenops
        typst-ts-mode
        typst-preview
        rustic
        lsp-mode
        lsp-ui
        lsp-java
        direnv
        go-mode
      ]
  );
in {
  default = emacs-with-packages;
}
