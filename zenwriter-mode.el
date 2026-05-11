;;; zenwriter-mode.el --- Zenwriter distraction-free writing mode -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; Author: jhou
;; Version: 0.2.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: faces, wp
;; URL: https://github.com/jhou1/zenwriter-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Companion modes for the zenwriter theme.
;; `zenwriter-mode' (buffer-local) enables olivetti centering and line spacing.
;; `global-zenwriter-mode' enables the full distraction-free experience globally:
;; theme, font, hidden chrome, and zenwriter-mode in all buffers.
;; `zenwriter-focus-mode' dims all text except the current visual line.

;;; Code:

(require 'seq)

(defvar olivetti-body-width)
(declare-function olivetti-mode "olivetti")

(defgroup zenwriter nil
  "Zenwriter distraction-free writing mode."
  :group 'faces
  :prefix "zenwriter-")

(defcustom zenwriter-font-family "Maple Mono CN"
  "Font family used by `global-zenwriter-mode'."
  :type 'string
  :group 'zenwriter)

(defcustom zenwriter-font-size 200
  "Font size in 1/10pt used by `global-zenwriter-mode'."
  :type 'integer
  :group 'zenwriter)

(defcustom zenwriter-line-spacing 8
  "Extra line spacing in pixels set by `zenwriter-mode'."
  :type 'number
  :group 'zenwriter)

(defcustom zenwriter-body-width 100
  "Text body width in columns for centering."
  :type 'integer
  :group 'zenwriter)

(defcustom zenwriter-focus-dimmed-color nil
  "Foreground color for dimmed text in focus mode.
When nil, auto-detected from `font-lock-comment-face'."
  :type '(choice (const :tag "Auto-detect" nil)
                 (string :tag "Color hex"))
  :group 'zenwriter)

;;; --- zenwriter-mode (buffer-local) ---

(defvar-local zenwriter--saved-line-spacing nil
  "Saved line-spacing to restore when `zenwriter-mode' is disabled.")

;;;###autoload
(define-minor-mode zenwriter-mode
  "Buffer-local minor mode for zenwriter distraction-free writing."
  :lighter nil
  (if zenwriter-mode
      (progn
        (setq zenwriter--saved-line-spacing line-spacing)
        (setq line-spacing zenwriter-line-spacing)
        (when (and (require 'olivetti nil t)
                   (not (minibufferp))
                   (not (string-prefix-p " " (buffer-name))))
          (setq olivetti-body-width zenwriter-body-width)
          (olivetti-mode 1)))
    (setq line-spacing zenwriter--saved-line-spacing)
    (when (bound-and-true-p olivetti-mode)
      (olivetti-mode -1))))

;;; --- global-zenwriter-mode ---

(defvar zenwriter--global-saved-state nil
  "Alist of saved global settings for `global-zenwriter-mode'.")

(defvar zenwriter--toggling nil
  "Non-nil while `global-zenwriter-mode' is being enabled or disabled.")

(defun zenwriter--global-save (key value)
  "Save KEY with VALUE to the global saved state alist."
  (setf (alist-get key zenwriter--global-saved-state) value))

(defun zenwriter--global-restore (key)
  "Restore and remove KEY from global saved state."
  (let ((val (alist-get key zenwriter--global-saved-state)))
    (setf (alist-get key zenwriter--global-saved-state nil t) nil)
    val))

(defun zenwriter--find-font ()
  "Return the first available font from preferred list."
  (seq-find (lambda (f) (member f (font-family-list)))
            (list zenwriter-font-family "Maple Mono CN" "Menlo" "Consolas" "Courier New")))

(defun zenwriter--turn-on ()
  "Turn on `zenwriter-mode' in the current buffer if appropriate."
  (unless (or (minibufferp)
              (string-prefix-p " " (buffer-name)))
    (zenwriter-mode 1)))

;; Ivy face accumulation fix: ivy mutates candidate strings in place,
;; so face properties (like ivy-current-match) persist across display
;; updates, causing previously selected candidates to stay highlighted.
(defun zenwriter--ivy-format-copy-cands (orig-fn cands)
  "Copy candidate strings before formatting to prevent face accumulation."
  (funcall orig-fn (mapcar #'copy-sequence cands)))

;;;###autoload
(define-minor-mode global-zenwriter-mode
  "Global minor mode for the full zenwriter experience."
  :global t
  :lighter nil
  (unless zenwriter--toggling
    (let ((zenwriter--toggling t)
          (saved-custom-set (get 'global-zenwriter-mode 'custom-set)))
      ;; Prevent enable-theme → custom-theme-recalc-variable from resetting
      ;; this mode variable via custom-set-minor-mode during theme switches.
      (put 'global-zenwriter-mode 'custom-set #'ignore)
      (unwind-protect
          (if global-zenwriter-mode
              (zenwriter--global-enable)
            (zenwriter--global-disable))
        (put 'global-zenwriter-mode 'custom-set saved-custom-set)))))

(defun zenwriter--global-enable ()
  "Activate the full zen writing environment."
  (zenwriter--global-save 'previous-themes (copy-sequence custom-enabled-themes))
  (zenwriter--global-save 'previous-bg-mode frame-background-mode)
  (let ((desired-bg (when (boundp 'ns-system-appearance)
                      (if (eq ns-system-appearance 'dark) 'dark 'light))))
    (mapc #'disable-theme custom-enabled-themes)
    ;; Set frame-background-mode AFTER disabling themes — some themes set it
    ;; via custom-theme-set-variables, and disabling them reverts it to nil.
    (when desired-bg
      (setq frame-background-mode desired-bg))
    (dolist (frame (frame-list))
      (frame-set-background-mode frame))
    (zenwriter--load-theme))
  ;; Font
  (let ((font (zenwriter--find-font)))
    (when font
      (zenwriter--global-save 'font (face-attribute 'default :family))
      (set-face-attribute 'default nil :family font)))
  ;; Mode line
  (zenwriter--global-save 'mode-line-format (default-value 'mode-line-format))
  (setq-default mode-line-format (list " "))
  ;; UI chrome
  (zenwriter--global-save 'scroll-bar-mode scroll-bar-mode)
  (zenwriter--global-save 'tool-bar-mode tool-bar-mode)
  (zenwriter--global-save 'menu-bar-mode menu-bar-mode)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  ;; Disable org-bars-mode if present
  (when (fboundp 'org-bars-mode)
    (zenwriter--global-save 'org-bars (member 'org-bars-mode org-mode-hook))
    (remove-hook 'org-mode-hook #'org-bars-mode)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (bound-and-true-p org-bars-mode)
          (org-bars-mode -1)))))
  ;; Disable org-modern-mode if present
  (when (fboundp 'global-org-modern-mode)
    (zenwriter--global-save 'org-modern (bound-and-true-p global-org-modern-mode))
    (when (bound-and-true-p global-org-modern-mode)
      (global-org-modern-mode -1)))
  ;; Fix ivy face accumulation
  (when (fboundp 'ivy--format)
    (advice-add 'ivy--format :around #'zenwriter--ivy-format-copy-cands))
  ;; Enable zenwriter-mode in all existing buffers and future ones
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (zenwriter--turn-on)))
  (add-hook 'after-change-major-mode-hook #'zenwriter--turn-on)
  ;; React to macOS light/dark appearance changes
  (when (boundp 'ns-system-appearance-change-functions)
    (zenwriter--global-save 'appearance-hook
      (copy-sequence (bound-and-true-p ns-system-appearance-change-functions)))
    (setq ns-system-appearance-change-functions nil)
    (add-hook 'ns-system-appearance-change-functions #'zenwriter--apply-appearance)))

(defun zenwriter--load-theme ()
  "Load or re-enable the zenwriter theme.
Temporarily neutralizes custom-set for our mode variables so that
enable-theme -> custom-theme-recalc-variable cannot re-trigger them."
  (let ((saved-mode-cs (get 'global-zenwriter-mode 'custom-set))
        (saved-focus-cs (get 'global-zenwriter-focus-mode 'custom-set)))
    (put 'global-zenwriter-mode 'custom-set #'ignore)
    (put 'global-zenwriter-focus-mode 'custom-set #'ignore)
    (unwind-protect
        (if (memq 'zenwriter custom-known-themes)
            (enable-theme 'zenwriter)
          (load-theme 'zenwriter t))
      (put 'global-zenwriter-mode 'custom-set saved-mode-cs)
      (put 'global-zenwriter-focus-mode 'custom-set saved-focus-cs)))
  (dolist (frame (frame-list))
    (frame-set-background-mode frame)))

(defun zenwriter--apply-appearance (appearance)
  "Switch zenwriter theme for the new system APPEARANCE (light or dark)."
  (setq frame-background-mode (if (eq appearance 'dark) 'dark 'light))
  (dolist (frame (frame-list))
    (frame-set-background-mode frame))
  (disable-theme 'zenwriter)
  (zenwriter--load-theme))

(defun zenwriter--global-disable ()
  "Deactivate zen writing environment, restoring saved state."
  ;; Restore macOS appearance hook
  (when (boundp 'ns-system-appearance-change-functions)
    (remove-hook 'ns-system-appearance-change-functions #'zenwriter--apply-appearance)
    (let ((prev (zenwriter--global-restore 'appearance-hook)))
      (when prev
        (setq ns-system-appearance-change-functions prev))))
  ;; Remove ivy face accumulation fix
  (advice-remove 'ivy--format #'zenwriter--ivy-format-copy-cands)
  ;; Disable zenwriter-mode in all buffers
  (remove-hook 'after-change-major-mode-hook #'zenwriter--turn-on)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when zenwriter-mode
        (zenwriter-mode -1))))
  ;; Restore org-bars-mode if it was active
  (when (and (fboundp 'org-bars-mode) (zenwriter--global-restore 'org-bars))
    (add-hook 'org-mode-hook #'org-bars-mode)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (derived-mode-p 'org-mode)
          (org-bars-mode 1)))))
  ;; Restore org-modern-mode if it was active
  (when (and (fboundp 'global-org-modern-mode) (zenwriter--global-restore 'org-modern))
    (global-org-modern-mode 1))
  ;; UI chrome
  (let ((sb (zenwriter--global-restore 'scroll-bar-mode))
        (tb (zenwriter--global-restore 'tool-bar-mode))
        (mb (zenwriter--global-restore 'menu-bar-mode)))
    (when sb (scroll-bar-mode 1))
    (when tb (tool-bar-mode 1))
    (when mb (menu-bar-mode 1)))
  ;; Mode line
  (let ((ml (zenwriter--global-restore 'mode-line-format)))
    (when ml (setq-default mode-line-format ml)))
  ;; Font
  (let ((family (zenwriter--global-restore 'font)))
    (when family
      (set-face-attribute 'default nil :family family)))
  ;; Theme — restore previous themes and background mode.
  ;; Protect our mode variables from custom-theme-recalc-variable.
  (let ((saved-mode-cs (get 'global-zenwriter-mode 'custom-set))
        (saved-focus-cs (get 'global-zenwriter-focus-mode 'custom-set)))
    (put 'global-zenwriter-mode 'custom-set #'ignore)
    (put 'global-zenwriter-focus-mode 'custom-set #'ignore)
    (unwind-protect
        (progn
          (disable-theme 'zenwriter)
          (setq frame-background-mode (zenwriter--global-restore 'previous-bg-mode))
          (dolist (frame (frame-list))
            (frame-set-background-mode frame))
          (let ((prev (zenwriter--global-restore 'previous-themes)))
            (dolist (theme (reverse prev))
              (load-theme theme t))))
      (put 'global-zenwriter-mode 'custom-set saved-mode-cs)
      (put 'global-zenwriter-focus-mode 'custom-set saved-focus-cs))))

;;; --- zenwriter-focus-mode (buffer-local) ---

(defvar-local zenwriter--focus-before-ov nil
  "Overlay covering text before the active unit.")

(defvar-local zenwriter--focus-after-ov nil
  "Overlay covering text after the active unit.")

(defun zenwriter--focus-dimmed-color ()
  "Return the color to use for dimmed text."
  (or zenwriter-focus-dimmed-color
      (face-foreground 'font-lock-comment-face nil t)
      "#9E9E9E"))

(defun zenwriter--focus-bounds ()
  "Return (BEG . END) of the current visual line."
  (cons (save-excursion (beginning-of-visual-line) (point))
        (save-excursion (end-of-visual-line) (point))))

(defun zenwriter--focus-update ()
  "Update focus overlays around the current unit."
  (when (and zenwriter-focus-mode
             zenwriter--focus-before-ov
             zenwriter--focus-after-ov)
    (let* ((bounds (zenwriter--focus-bounds))
           (beg (car bounds))
           (end (cdr bounds)))
      (move-overlay zenwriter--focus-before-ov (point-min) beg)
      (move-overlay zenwriter--focus-after-ov end (point-max)))))

;;;###autoload
(define-minor-mode zenwriter-focus-mode
  "Buffer-local minor mode that dims text outside the current visual line."
  :lighter nil
  (if zenwriter-focus-mode
      (let ((dimmed (zenwriter--focus-dimmed-color)))
        (setq zenwriter--focus-before-ov (make-overlay (point-min) (point-min)))
        (setq zenwriter--focus-after-ov (make-overlay (point-max) (point-max)))
        (overlay-put zenwriter--focus-before-ov 'face `(:foreground ,dimmed))
        (overlay-put zenwriter--focus-after-ov 'face `(:foreground ,dimmed))
        (overlay-put zenwriter--focus-before-ov 'priority 100)
        (overlay-put zenwriter--focus-after-ov 'priority 100)
        (add-hook 'post-command-hook #'zenwriter--focus-update nil t)
        (zenwriter--focus-update))
    (remove-hook 'post-command-hook #'zenwriter--focus-update t)
    (when zenwriter--focus-before-ov
      (delete-overlay zenwriter--focus-before-ov)
      (setq zenwriter--focus-before-ov nil))
    (when zenwriter--focus-after-ov
      (delete-overlay zenwriter--focus-after-ov)
      (setq zenwriter--focus-after-ov nil))))

(defun zenwriter--focus-turn-on ()
  "Turn on `zenwriter-focus-mode' in the current buffer."
  (unless (or (minibufferp)
              (string-prefix-p " " (buffer-name)))
    (zenwriter-focus-mode 1)))

;;;###autoload
(define-globalized-minor-mode global-zenwriter-focus-mode
  zenwriter-focus-mode
  zenwriter--focus-turn-on)

(provide 'zenwriter-mode)

;;; zenwriter-mode.el ends here
