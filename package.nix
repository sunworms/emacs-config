{pkgs, ...}: let
  emacsPackagesCustom = pkgs.emacs-gtk.pkgs;

  treesitGrammars = emacsPackagesCustom.treesit-grammars.with-all-grammars;

  emacs-with-packages = emacsPackagesCustom.withPackages (
    epkgs:
      with epkgs; [
        catppuccin-theme
        treesitGrammars
        tree-sitter
        gcmh
        apheleia
        company
        company-auctex
        company-bibtex
        eglot
        eglotx
        eglot-java
        nix-ts-mode
        pdf-tools
        auctex
        auctex-latexmk
        cdlatex
        xenops
        typst-ts-mode
        typst-preview
        rustic
        direnv
        go-mode
        nerd-icons
        nerd-icons-dired
        nerd-icons-completion
      ]
  );
in {
  default = emacs-with-packages;
}
