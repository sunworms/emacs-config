;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; General options
(setq
 inhibit-startup-screen t
 make-backup-files nil
 delete-old-versions t
 version-control t
 create-lockfiles nil
 treesit-font-lock-level 4)

(setq-default major-mode 'prog-mode)

;; Clipboard
(defun my/wl-copy (text &optional _push)
  "Copy text using wl-copy if running under Wayland."
  (when (getenv "WAYLAND_DISPLAY")
    (let ((proc (make-process
                 :name "wl-copy"
                 :command '("wl-copy" "-n")
                 :connection-type 'pipe
                 :noquery t)))
      (process-send-string proc text)
      (process-send-eof proc))))

(defun my/wl-paste ()
  "Paste text using wl-paste if running under Wayland."
  (when (getenv "WAYLAND_DISPLAY")
    (let ((output (shell-command-to-string "wl-paste -n 2>/dev/null")))
      (unless (string-empty-p output)
        output))))

;; Assign unconditionally during daemon init
(setq interprogram-cut-function #'my/wl-copy)
(setq interprogram-paste-function #'my/wl-paste)

;; General toggles
(setq-default tab-width 2)
(electric-pair-mode 1)
(setq auto-save-file-name-transforms
      `((".*" ,(temporary-file-directory) t)))

;; Browser and font
(setq browse-url-browser-function 'browse-url-xdg-open)
(set-face-attribute 'default nil :family "D2KodingLigature Nerd Font Mono" :height 110)

(set-frame-parameter nil 'alpha-background 85) ; For current frame
(add-to-list 'default-frame-alist '(alpha-background . 85)) ; For all new frames henceforth

;; Line numbers
(add-hook 'after-init-hook #'global-display-line-numbers-mode)
(defun display-line-numbers--turn-on ()
  "Turn on `display-line-numbers-mode'."
  (unless (or (minibufferp) (eq major-mode 'pdf-view-mode))
    (display-line-numbers-mode)))
(add-hook 'after-init-hook #'column-number-mode)

;; Themes
(require 'catppuccin-theme)
(load-theme 'catppuccin :no-confirm)

(defun sunny/terminal-transparent (frame)
  (unless (display-graphic-p frame)
    (set-face-background 'default "unspecified-bg" frame)
    (set-face-attribute 'line-number frame :background "unspecified-bg")
    (set-face-attribute 'line-number-current-line
                        frame :background "unspecified-bg")))

(defun sunny/server-setup-frame ()
  (catppuccin-reload)
  (sunny/terminal-transparent (selected-frame)))

(add-hook 'server-after-make-frame-hook #'sunny/server-setup-frame)

(unless (daemonp)
  (add-hook 'window-setup-hook
            (lambda ()
              (sunny/terminal-transparent (selected-frame)))))

(add-hook 'after-make-frame-functions #'sunny/terminal-transparent)

(use-package gcmh
  :ensure nil
  :defer t
  :hook (after-init . gcmh-mode))

(use-package nerd-icons
	:ensure nil)

(use-package nerd-icons-completion
	:ensure nil
	:defer t
	:after global-company-mode)

(use-package nerd-icons-dired
	:ensure nil
	:defer t
	:hook (dired-mode . nerd-icons-dired-mode))

(use-package tree-sitter
  :ensure nil
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package direnv-config
  :load-path "lisp/")
(use-package company-config
  :load-path "lisp/")
(use-package lsp-config
  :load-path "lisp/")
(use-package apheleia-config
  :load-path "lisp/")
(use-package languages-config
  :load-path "lisp/")
