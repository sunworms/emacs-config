;;; lsp-config.el --- Emacs configuration -*- lexical-binding: t; -*-

(use-package lsp-mode
  :ensure nil
  :defer t
  :hook ((rust-mode
          typst-ts-mode
          LaTeX-mode
          tex-mode
          go-mode
          nix-ts-mode) . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-enable-on-type-formatting nil
        lsp-enable-indentation nil)
  :config
  (require 'lsp-lens)
  (require 'lsp-modeline)
  (require 'flycheck)
  (flycheck-mode)
  (setq lsp-idle-delay 0.1
        lsp-completion-provider :capf
        lsp-headerline-breadcrumb-enable nil
        lsp-modeline-diagnostics-enable nil
        lsp-signature-auto-activate nil
        lsp-log-io nil)

  (setq lsp-disabled-clients '((nix-mode . (nixd-lsp nix-nil))
                                (nix-ts-mode . (nixd-lsp nix-nil))))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "nixd")
    :major-modes '(nix-mode nix-ts-mode)
    :server-id 'nixd
    :priority 1))

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "nil")
    :major-modes '(nix-mode nix-ts-mode)
    :server-id 'nil-ls
    :add-on? t
    :priority 0)))

(use-package lsp-ui
  :ensure nil
  :defer t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor nil
        lsp-ui-doc-show-with-mouse nil
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-sideline-show-hover nil))

(use-package lsp-java
  :ensure nil
  :defer t
  :hook (java-mode . lsp-deferred))

(provide 'lsp-config)
