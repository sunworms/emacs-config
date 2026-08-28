;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; General options
(setq
 inhibit-startup-screen t
 make-backup-files nil
 select-enable-clipboard t
 delete-old-versions t
 version-control t
 create-lockfiles nil)

;; General toggles
(setq-default tab-width 2)
(electric-pair-mode 1)
(setq auto-save-file-name-transforms
      `((".*" ,(temporary-file-directory) t)))

;; Browser and font
(setq browse-url-browser-function 'browse-url-xdg-open)
(set-face-attribute 'default nil :family "D2KodingLigature Nerd Font Mono" :height 110)

(unless (display-graphic-p)
  (set-face-attribute 'default nil :background "unspecified-bg")
  (set-terminal-parameter nil 'background-mode 'dark))

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
(dolist (dir '("~/.config/emacs/themes/" "~/.emacs.d/themes/"))
  (let ((dir (expand-file-name dir)))
    (when (file-directory-p dir)
      (add-to-list 'custom-theme-load-path dir))))

(condition-case nil
    (load-theme 'noctalia t)
  (error (load-theme 'modus-vivendi t)))

(defun reload-noctalia-theme ()
  "Reload the Noctalia generated theme."
  (interactive)
  (disable-theme 'noctalia)
  (load-theme 'noctalia t))

(defun handle-sigusr1-theme-reload ()
  (interactive)
  (reload-noctalia-theme)
  (message "Noctalia theme reloaded"))

(define-key special-event-map [sigusr1] #'handle-sigusr1-theme-reload)

(defun my/open-todo ()
  (interactive)
  (find-file "~/Documents/gdrive/org/todo.org"))

(defun my/open-journal ()
  (interactive)
  (find-file
   (format-time-string "~/Documents/gdrive/org/journal/%Y-%m-%d.org")))

(setq org-todo-keywords
      '((sequence
         "TODO(t)"
				 "IN PROGRESS(i)"
         "|"
         "DONE(d)")))

(setq org-directory "~/Documents/gdrive/org")

(setq org-agenda-files
      '("~/Documents/gdrive/org/todo.org"
        "~/Documents/gdrive/org/inbox.org"
        "~/Documents/gdrive/org/journal"
        "~/Documents/gdrive/org/projects"))

(use-package magit
  :ensure nil
  :defer t
  :bind ("C-x g" . magit-status))

;; Lets the GC threshold stay huge during startup (see early-init.el) but
;; drop back down to something sane once Emacs is idle, instead of paying
;; for giant GC pauses during normal editing.
(use-package gcmh
  :ensure nil
  :defer t
  :hook (after-init . gcmh-mode))

(setq treesit-font-lock-level 4)

(use-package meow-config
  :load-path "lisp/")
(use-package direnv-config
  :load-path "lisp/")
(use-package treesitter-config
  :load-path "lisp/")
(use-package company-config
  :load-path "lisp/")
(use-package lsp-config
  :load-path "lisp/")
(use-package apheleia-config
  :load-path "lisp/")
(use-package languages-config
  :load-path "lisp/")
