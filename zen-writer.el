;;; zen-writer.el --- Zen Writer zen mode for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; Author: jhou
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: faces, wp
;; URL: https://github.com/jhou/emacs-writer

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; Companion modes for the zen-writer theme.
;; `zen-writer-mode' (buffer-local) enables olivetti centering and line spacing.
;; `global-zen-writer-mode' enables the full zen experience globally:
;; theme, font, hidden chrome, and zen-writer-mode in all buffers.
;; `zen-writer-focus-mode' dims all text except the current visual line.

;;; Code:

(require 'seq)

(defgroup zen-writer nil
  "Zen Writer zen mode for Emacs."
  :group 'faces
  :prefix "zen-writer-")

(defcustom zen-writer-font-family "Maple Mono CN"
  "Font family used by `global-zen-writer-mode'."
  :type 'string
  :group 'zen-writer)

(defcustom zen-writer-font-size 200
  "Font size in 1/10pt used by `global-zen-writer-mode'."
  :type 'integer
  :group 'zen-writer)

(defcustom zen-writer-line-spacing 8
  "Extra line spacing in pixels set by `zen-writer-mode'."
  :type 'number
  :group 'zen-writer)

(defcustom zen-writer-body-width 100
  "Text body width in columns for centering."
  :type 'integer
  :group 'zen-writer)

(defcustom zen-writer-focus-dimmed-color nil
  "Foreground color for dimmed text in focus mode.
When nil, auto-detected from `font-lock-comment-face'."
  :type '(choice (const :tag "Auto-detect" nil)
                 (string :tag "Color hex"))
  :group 'zen-writer)

;;; --- zen-writer-mode (buffer-local) ---

(defvar-local zen-writer--saved-line-spacing nil
  "Saved line-spacing to restore when `zen-writer-mode' is disabled.")

;;;###autoload
(define-minor-mode zen-writer-mode
  "Buffer-local minor mode for Zen Writer zen writing."
  :lighter nil
  (if zen-writer-mode
      (progn
        (setq zen-writer--saved-line-spacing line-spacing)
        (setq line-spacing zen-writer-line-spacing)
        (when (and (require 'olivetti nil t)
                   (not (minibufferp))
                   (not (string-prefix-p " " (buffer-name))))
          (setq olivetti-body-width zen-writer-body-width)
          (olivetti-mode 1)))
    (setq line-spacing zen-writer--saved-line-spacing)
    (when (bound-and-true-p olivetti-mode)
      (olivetti-mode -1))))

;;; --- global-zen-writer-mode ---

(defvar zen-writer--global-saved-state nil
  "Alist of saved global settings for `global-zen-writer-mode'.")

(defun zen-writer--global-save (key value)
  "Save KEY with VALUE to the global saved state alist."
  (setf (alist-get key zen-writer--global-saved-state) value))

(defun zen-writer--global-restore (key)
  "Restore and remove KEY from global saved state."
  (let ((val (alist-get key zen-writer--global-saved-state)))
    (setf (alist-get key zen-writer--global-saved-state nil t) nil)
    val))

(defun zen-writer--find-font ()
  "Return the first available font from preferred list."
  (seq-find (lambda (f) (member f (font-family-list)))
            (list zen-writer-font-family "Maple Mono CN" "Menlo" "Consolas" "Courier New")))

(defun zen-writer--turn-on ()
  "Turn on `zen-writer-mode' in the current buffer if appropriate."
  (unless (or (minibufferp)
              (string-prefix-p " " (buffer-name)))
    (zen-writer-mode 1)))

;;;###autoload
(define-minor-mode global-zen-writer-mode
  "Global minor mode for the full Zen Writer zen experience."
  :global t
  :lighter nil
  (if global-zen-writer-mode
      (zen-writer--global-enable)
    (zen-writer--global-disable)))

(defun zen-writer--global-enable ()
  "Activate the full zen writing environment."
  ;; Theme — disable all other themes, then load zen-writer
  (zen-writer--global-save 'previous-themes (copy-sequence custom-enabled-themes))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'zen-writer t)
  ;; Font
  (let ((font (zen-writer--find-font)))
    (when font
      (zen-writer--global-save 'font (face-attribute 'default :family))
      (set-face-attribute 'default nil :family font)))
  ;; Mode line
  (zen-writer--global-save 'mode-line-format (default-value 'mode-line-format))
  (setq-default mode-line-format (list " "))
  ;; UI chrome
  (zen-writer--global-save 'scroll-bar-mode scroll-bar-mode)
  (zen-writer--global-save 'tool-bar-mode tool-bar-mode)
  (zen-writer--global-save 'menu-bar-mode menu-bar-mode)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  ;; Disable org-bars-mode if present
  (when (fboundp 'org-bars-mode)
    (zen-writer--global-save 'org-bars (member 'org-bars-mode org-mode-hook))
    (remove-hook 'org-mode-hook #'org-bars-mode)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (bound-and-true-p org-bars-mode)
          (org-bars-mode -1)))))
  ;; Disable org-modern-mode if present
  (when (fboundp 'global-org-modern-mode)
    (zen-writer--global-save 'org-modern (bound-and-true-p global-org-modern-mode))
    (when (bound-and-true-p global-org-modern-mode)
      (global-org-modern-mode -1)))
  ;; Enable zen-writer-mode in all existing buffers and future ones
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (zen-writer--turn-on)))
  (add-hook 'after-change-major-mode-hook #'zen-writer--turn-on))

(defun zen-writer--global-disable ()
  "Deactivate zen writing environment, restoring saved state."
  ;; Disable zen-writer-mode in all buffers
  (remove-hook 'after-change-major-mode-hook #'zen-writer--turn-on)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when zen-writer-mode
        (zen-writer-mode -1))))
  ;; Restore org-bars-mode if it was active
  (when (and (fboundp 'org-bars-mode) (zen-writer--global-restore 'org-bars))
    (add-hook 'org-mode-hook #'org-bars-mode)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (derived-mode-p 'org-mode)
          (org-bars-mode 1)))))
  ;; Restore org-modern-mode if it was active
  (when (and (fboundp 'global-org-modern-mode) (zen-writer--global-restore 'org-modern))
    (global-org-modern-mode 1))
  ;; UI chrome
  (let ((sb (zen-writer--global-restore 'scroll-bar-mode))
        (tb (zen-writer--global-restore 'tool-bar-mode))
        (mb (zen-writer--global-restore 'menu-bar-mode)))
    (when sb (scroll-bar-mode 1))
    (when tb (tool-bar-mode 1))
    (when mb (menu-bar-mode 1)))
  ;; Mode line
  (let ((ml (zen-writer--global-restore 'mode-line-format)))
    (when ml (setq-default mode-line-format ml)))
  ;; Font
  (let ((family (zen-writer--global-restore 'font)))
    (when family
      (set-face-attribute 'default nil :family family)))
  ;; Theme — restore previous themes
  (disable-theme 'zen-writer)
  (let ((prev (zen-writer--global-restore 'previous-themes)))
    (dolist (theme (reverse prev))
      (load-theme theme t))))

;;; --- zen-writer-focus-mode (buffer-local) ---

(defvar-local zen-writer--focus-before-ov nil
  "Overlay covering text before the active unit.")

(defvar-local zen-writer--focus-after-ov nil
  "Overlay covering text after the active unit.")

(defun zen-writer--focus-dimmed-color ()
  "Return the color to use for dimmed text."
  (or zen-writer-focus-dimmed-color
      (face-foreground 'font-lock-comment-face nil t)
      "#9E9E9E"))

(defun zen-writer--focus-bounds ()
  "Return (BEG . END) of the current visual line."
  (cons (save-excursion (beginning-of-visual-line) (point))
        (save-excursion (end-of-visual-line) (point))))

(defun zen-writer--focus-update ()
  "Update focus overlays around the current unit."
  (when (and zen-writer-focus-mode
             zen-writer--focus-before-ov
             zen-writer--focus-after-ov)
    (let* ((bounds (zen-writer--focus-bounds))
           (beg (car bounds))
           (end (cdr bounds)))
      (move-overlay zen-writer--focus-before-ov (point-min) beg)
      (move-overlay zen-writer--focus-after-ov end (point-max)))))

;;;###autoload
(define-minor-mode zen-writer-focus-mode
  "Buffer-local minor mode that dims text outside the current visual line."
  :lighter nil
  (if zen-writer-focus-mode
      (let ((dimmed (zen-writer--focus-dimmed-color)))
        (setq zen-writer--focus-before-ov (make-overlay (point-min) (point-min)))
        (setq zen-writer--focus-after-ov (make-overlay (point-max) (point-max)))
        (overlay-put zen-writer--focus-before-ov 'face `(:foreground ,dimmed))
        (overlay-put zen-writer--focus-after-ov 'face `(:foreground ,dimmed))
        (overlay-put zen-writer--focus-before-ov 'priority 100)
        (overlay-put zen-writer--focus-after-ov 'priority 100)
        (add-hook 'post-command-hook #'zen-writer--focus-update nil t)
        (zen-writer--focus-update))
    (remove-hook 'post-command-hook #'zen-writer--focus-update t)
    (when zen-writer--focus-before-ov
      (delete-overlay zen-writer--focus-before-ov)
      (setq zen-writer--focus-before-ov nil))
    (when zen-writer--focus-after-ov
      (delete-overlay zen-writer--focus-after-ov)
      (setq zen-writer--focus-after-ov nil))))

;;;###autoload
(define-globalized-minor-mode global-zen-writer-focus-mode
  zen-writer-focus-mode
  (lambda () (zen-writer-focus-mode 1)))

(provide 'zen-writer)

;;; zen-writer.el ends here
