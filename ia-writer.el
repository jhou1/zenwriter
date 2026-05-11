;;; ia-writer.el --- iA Writer zen mode for Emacs -*- lexical-binding: t; -*-

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

;; Companion modes for the ia-writer theme.
;; `ia-writer-mode' transforms the Emacs frame into a distraction-free
;; writing environment.  `ia-writer-focus-mode' dims all text except
;; the active sentence or paragraph.

;;; Code:

(require 'seq)

(defgroup ia-writer nil
  "iA Writer zen mode for Emacs."
  :group 'faces
  :prefix "ia-writer-")

(defcustom ia-writer-font-family "IBM Plex Mono"
  "Font family used by `ia-writer-mode'."
  :type 'string
  :group 'ia-writer)

(defcustom ia-writer-font-size 140
  "Font size in 1/10pt used by `ia-writer-mode'."
  :type 'integer
  :group 'ia-writer)

(defcustom ia-writer-line-spacing 0.5
  "Extra line spacing set by `ia-writer-mode'."
  :type 'number
  :group 'ia-writer)

(defcustom ia-writer-body-width 80
  "Text body width in columns for centering."
  :type 'integer
  :group 'ia-writer)

(defcustom ia-writer-focus-unit 'sentence
  "Unit of focus in `ia-writer-focus-mode'.
Either `sentence' or `paragraph'."
  :type '(choice (const :tag "Sentence" sentence)
                 (const :tag "Paragraph" paragraph))
  :group 'ia-writer)

(defcustom ia-writer-focus-dimmed-color nil
  "Foreground color for dimmed text in focus mode.
When nil, auto-detected from `font-lock-comment-face'."
  :type '(choice (const :tag "Auto-detect" nil)
                 (string :tag "Color hex"))
  :group 'ia-writer)

(defvar ia-writer--saved-state nil
  "Alist of saved settings to restore when `ia-writer-mode' is disabled.")

(defun ia-writer--find-font ()
  "Return the first available font from preferred list."
  (seq-find (lambda (f) (member f (font-family-list)))
            (list ia-writer-font-family "IBM Plex Mono" "Menlo" "Consolas" "Courier New")))

(defun ia-writer--save (key value)
  "Save KEY with VALUE to the saved state alist."
  (setf (alist-get key ia-writer--saved-state) value))

(defun ia-writer--restore (key)
  "Restore and remove KEY from saved state. Returns the saved value."
  (let ((val (alist-get key ia-writer--saved-state)))
    (setf (alist-get key ia-writer--saved-state nil t) nil)
    val))

;;;###autoload
(define-minor-mode ia-writer-mode
  "Global minor mode for iA Writer zen writing experience."
  :global t
  :lighter nil
  (if ia-writer-mode
      (ia-writer--enable)
    (ia-writer--disable)))

(defun ia-writer--enable ()
  "Activate zen writing environment."
  ;; Theme
  (unless (member 'ia-writer custom-enabled-themes)
    (ia-writer--save 'theme t)
    (load-theme 'ia-writer t))
  ;; Font
  (let ((font (ia-writer--find-font)))
    (when font
      (ia-writer--save 'font (face-attribute 'default :family))
      (ia-writer--save 'font-size (face-attribute 'default :height))
      (set-face-attribute 'default nil :family font :height ia-writer-font-size)))
  ;; Line spacing
  (ia-writer--save 'line-spacing (default-value 'line-spacing))
  (setq-default line-spacing ia-writer-line-spacing)
  ;; Mode line
  (ia-writer--save 'mode-line-format (default-value 'mode-line-format))
  (setq-default mode-line-format (list " "))
  ;; UI chrome
  (ia-writer--save 'scroll-bar-mode scroll-bar-mode)
  (ia-writer--save 'tool-bar-mode tool-bar-mode)
  (ia-writer--save 'menu-bar-mode menu-bar-mode)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  ;; Centering
  (if (require 'olivetti nil t)
      (progn
        (ia-writer--save 'olivetti t)
        (setq olivetti-body-width ia-writer-body-width)
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (olivetti-mode 1))))
    (ia-writer--save 'left-margin (default-value 'left-margin-width))
    (ia-writer--save 'right-margin (default-value 'right-margin-width))
    (let ((margin (max 0 (/ (- (window-total-width) ia-writer-body-width) 2))))
      (setq-default left-margin-width margin)
      (setq-default right-margin-width margin)))
  ;; Refresh
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (get-buffer-window buf)
        (set-window-buffer (get-buffer-window buf) buf)))))

(defun ia-writer--disable ()
  "Deactivate zen writing environment, restoring saved state."
  ;; Olivetti
  (when (ia-writer--restore 'olivetti)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (bound-and-true-p olivetti-mode)
          (olivetti-mode -1)))))
  ;; Margins
  (let ((lm (ia-writer--restore 'left-margin))
        (rm (ia-writer--restore 'right-margin)))
    (when lm (setq-default left-margin-width lm))
    (when rm (setq-default right-margin-width rm)))
  ;; UI chrome
  (let ((sb (ia-writer--restore 'scroll-bar-mode))
        (tb (ia-writer--restore 'tool-bar-mode))
        (mb (ia-writer--restore 'menu-bar-mode)))
    (when sb (scroll-bar-mode 1))
    (when tb (tool-bar-mode 1))
    (when mb (menu-bar-mode 1)))
  ;; Mode line
  (let ((ml (ia-writer--restore 'mode-line-format)))
    (when ml (setq-default mode-line-format ml)))
  ;; Line spacing
  (let ((ls (ia-writer--restore 'line-spacing)))
    (setq-default line-spacing ls))
  ;; Font
  (let ((family (ia-writer--restore 'font))
        (size (ia-writer--restore 'font-size)))
    (when family
      (set-face-attribute 'default nil
                          :family family
                          :height (or size ia-writer-font-size))))
  ;; Theme
  (when (ia-writer--restore 'theme)
    (disable-theme 'ia-writer))
  ;; Refresh
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (get-buffer-window buf)
        (set-window-buffer (get-buffer-window buf) buf)))))

(defvar-local ia-writer--focus-before-ov nil
  "Overlay covering text before the active unit.")

(defvar-local ia-writer--focus-after-ov nil
  "Overlay covering text after the active unit.")

(defun ia-writer--focus-dimmed-color ()
  "Return the color to use for dimmed text."
  (or ia-writer-focus-dimmed-color
      (face-foreground 'font-lock-comment-face nil t)
      "#9E9E9E"))

(defun ia-writer--focus-bounds ()
  "Return (BEG . END) of the current focus unit."
  (let ((beg (point))
        (end (point)))
    (save-excursion
      (if (eq ia-writer-focus-unit 'paragraph)
          (progn
            (backward-paragraph)
            (skip-chars-forward "\n\t ")
            (setq beg (point)))
        (condition-case nil
            (progn
              (backward-sentence)
              (setq beg (point)))
          (error (setq beg (line-beginning-position)))))
      (goto-char end)
      (if (eq ia-writer-focus-unit 'paragraph)
          (progn
            (forward-paragraph)
            (skip-chars-backward "\n\t ")
            (setq end (point)))
        (condition-case nil
            (progn
              (forward-sentence)
              (setq end (point)))
          (error (setq end (line-end-position))))))
    (cons beg end)))

(defun ia-writer--focus-update ()
  "Update focus overlays around the current unit."
  (when (and ia-writer-focus-mode
             ia-writer--focus-before-ov
             ia-writer--focus-after-ov)
    (let* ((bounds (ia-writer--focus-bounds))
           (beg (car bounds))
           (end (cdr bounds)))
      (move-overlay ia-writer--focus-before-ov (point-min) beg)
      (move-overlay ia-writer--focus-after-ov end (point-max)))))

;;;###autoload
(define-minor-mode ia-writer-focus-mode
  "Buffer-local minor mode that dims text outside the current sentence."
  :lighter nil
  (if ia-writer-focus-mode
      (let ((dimmed (ia-writer--focus-dimmed-color)))
        (setq ia-writer--focus-before-ov (make-overlay (point-min) (point-min)))
        (setq ia-writer--focus-after-ov (make-overlay (point-max) (point-max)))
        (overlay-put ia-writer--focus-before-ov 'face `(:foreground ,dimmed))
        (overlay-put ia-writer--focus-after-ov 'face `(:foreground ,dimmed))
        (overlay-put ia-writer--focus-before-ov 'priority 100)
        (overlay-put ia-writer--focus-after-ov 'priority 100)
        (add-hook 'post-command-hook #'ia-writer--focus-update nil t)
        (ia-writer--focus-update))
    (remove-hook 'post-command-hook #'ia-writer--focus-update t)
    (when ia-writer--focus-before-ov
      (delete-overlay ia-writer--focus-before-ov)
      (setq ia-writer--focus-before-ov nil))
    (when ia-writer--focus-after-ov
      (delete-overlay ia-writer--focus-after-ov)
      (setq ia-writer--focus-after-ov nil))))

(provide 'ia-writer)

;;; ia-writer.el ends here
