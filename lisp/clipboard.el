;;; clipboard.el --- Emacs configuration -*- lexical-binding: t; -*-

(defun sunny--systemd-user-environment (variable)
  (let ((systemctl "/run/current-system/sw/bin/systemctl"))
    (when (file-executable-p systemctl)
      (with-temp-buffer
        (when (zerop
               (call-process
                systemctl nil t nil
                "--user" "show-environment"))
          (goto-char (point-min))
          (when-let* ((value
                       (and (re-search-forward
                             (concat "^"
                                     (regexp-quote variable)
                                     "=\\(.*\\)$")
                             nil t)
                            (match-string 1))))
            value))))))

(defun sunny--wayland-environment ()
  (let* ((display
          (sunny--systemd-user-environment "WAYLAND_DISPLAY"))
         (runtime
          (or (sunny--systemd-user-environment "XDG_RUNTIME_DIR")
              (getenv "XDG_RUNTIME_DIR")))
         (socket
          (and display
               runtime
               (expand-file-name display runtime))))
    (when-let* ((wayland
                 (and display
											runtime
											(file-exists-p socket)))
								(_ wayland))
      (list display runtime))))

(setq interprogram-cut-function
      (lambda (text &optional _push)
        (when-let* ((wayland (sunny--wayland-environment)))
          (let ((process-environment (copy-sequence process-environment)))
            (setenv "WAYLAND_DISPLAY" (nth 0 wayland))
            (setenv "XDG_RUNTIME_DIR" (nth 1 wayland))
            (let ((proc
                   (make-process
                    :name "wl-copy"
                    :command '("wl-copy" "-n")
                    :connection-type 'pipe
                    :noquery t)))
              (process-send-string proc text)
              (process-send-eof proc))))))

(setq interprogram-paste-function
      (lambda ()
        (when-let* ((wayland (sunny--wayland-environment)))
          (let ((process-environment (copy-sequence process-environment)))
            (setenv "WAYLAND_DISPLAY" (nth 0 wayland))
            (setenv "XDG_RUNTIME_DIR" (nth 1 wayland))
            (with-temp-buffer
              (when (zerop
                     (call-process
                      "wl-paste" nil t nil "-n"))
                (let ((output (buffer-string)))
                  (unless (string-empty-p output)
                    output))))))))

(provide 'clipboard)
