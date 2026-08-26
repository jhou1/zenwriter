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
(defvar org-mode-hook)
(declare-function olivetti-mode "olivetti")
(declare-function org-bars-mode "org-bars")
(declare-function global-org-modern-mode "org-modern")

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

(defvar-local zenwriter--saved-line-spacing-valid-p nil
  "Non-nil when `zenwriter--saved-line-spacing' holds pre-mode state.")

;;;###autoload
(define-minor-mode zenwriter-mode
  "Buffer-local minor mode for zenwriter distraction-free writing."
  :lighter nil
  (if zenwriter-mode
      (unless zenwriter--saved-line-spacing-valid-p
        (setq zenwriter--saved-line-spacing line-spacing)
        (setq zenwriter--saved-line-spacing-valid-p t)
        (setq line-spacing zenwriter-line-spacing)
        (when (and (require 'olivetti nil t)
                   (not (minibufferp))
                   (not (string-prefix-p " " (buffer-name))))
          (setq olivetti-body-width zenwriter-body-width)
          (olivetti-mode 1)))
    (when zenwriter--saved-line-spacing-valid-p
      (setq line-spacing zenwriter--saved-line-spacing)
      (setq zenwriter--saved-line-spacing nil)
      (setq zenwriter--saved-line-spacing-valid-p nil)
      (when (bound-and-true-p olivetti-mode)
        (olivetti-mode -1)))))

;;; --- global-zenwriter-mode ---

(defvar zenwriter--global-saved-state nil
  "Alist of saved global settings for `global-zenwriter-mode'.")

(defvar zenwriter--toggling nil
  "Non-nil while `global-zenwriter-mode' is being enabled or disabled.")

(defun zenwriter--global-state-value (key)
  "Return the saved global state value for KEY without removing it."
  (alist-get key zenwriter--global-saved-state))

(defun zenwriter--global-capture-state ()
  "Return an immutable snapshot of state changed by the global mode."
  (let ((font (zenwriter--find-font)))
    `((previous-themes . ,(copy-sequence custom-enabled-themes))
      (previous-bg-mode . ,frame-background-mode)
      (font-to-apply . ,font)
      (font-family . ,(and font (face-attribute 'default :family)))
      (mode-line-format . ,(copy-tree (default-value 'mode-line-format)))
      (scroll-bar-mode . ,scroll-bar-mode)
      (tool-bar-mode . ,tool-bar-mode)
      (menu-bar-mode . ,menu-bar-mode)
      (org-bars-available . ,(fboundp 'org-bars-mode))
      (org-bars . ,(and (fboundp 'org-bars-mode)
                        (memq #'org-bars-mode org-mode-hook)
                        t))
      (org-modern-available . ,(fboundp 'global-org-modern-mode))
      (org-modern . ,(and (fboundp 'global-org-modern-mode)
                          (bound-and-true-p global-org-modern-mode)
                          t))
      (ivy-advice . ,(and (fboundp 'ivy--format)
                          (advice-member-p #'zenwriter--ivy-format-copy-cands
                                           'ivy--format)
                          t))
      (appearance-hook-bound . ,(boundp 'ns-system-appearance-change-functions))
      (appearance-hook . ,(and (boundp 'ns-system-appearance-change-functions)
                               (copy-sequence
                                ns-system-appearance-change-functions)))
      (zenwriter-theme . ,(and (memq 'zenwriter custom-enabled-themes) t)))))

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
          (saved-custom-set (get 'global-zenwriter-mode 'custom-set))
          (inhibit-redisplay t))
      ;; Prevent enable-theme → custom-theme-recalc-variable from resetting
      ;; this mode variable via custom-set-minor-mode during theme switches.
      (put 'global-zenwriter-mode 'custom-set #'ignore)
      (unwind-protect
          (if global-zenwriter-mode
              (unless zenwriter--global-saved-state
                (zenwriter--global-enable))
            (when zenwriter--global-saved-state
              (zenwriter--global-disable)))
        (put 'global-zenwriter-mode 'custom-set saved-custom-set)
        (force-mode-line-update t)))))

(defun zenwriter--global-enable ()
  "Activate the full zen writing environment."
  (setq zenwriter--global-saved-state (zenwriter--global-capture-state))
  (condition-case err
      (progn
        ;; Keep existing themes enabled underneath Zenwriter.  Removing the
        ;; top theme can then reveal the exact previous face state directly.
        (let ((desired-bg (when (boundp 'ns-system-appearance)
                            (if (eq ns-system-appearance 'dark) 'dark 'light))))
          (when desired-bg
            (setq frame-background-mode desired-bg))
          (dolist (frame (frame-list))
            (frame-set-background-mode frame))
          (zenwriter--load-theme))
        ;; Font
        (let ((font (zenwriter--global-state-value 'font-to-apply)))
          (when font
            (set-face-attribute 'default nil :family font)))
        ;; Mode line
        (setq-default mode-line-format (list " "))
        ;; UI chrome
        (scroll-bar-mode -1)
        (tool-bar-mode -1)
        (menu-bar-mode -1)
        ;; Disable org-bars-mode if present
        (when (zenwriter--global-state-value 'org-bars-available)
          (remove-hook 'org-mode-hook #'org-bars-mode)
          (dolist (buf (buffer-list))
            (with-current-buffer buf
              (when (bound-and-true-p org-bars-mode)
                (org-bars-mode -1)))))
        ;; Disable org-modern-mode if present
        (when (and (zenwriter--global-state-value 'org-modern-available)
                   (bound-and-true-p global-org-modern-mode))
          (global-org-modern-mode -1))
        ;; Fix ivy face accumulation, without taking ownership of pre-existing
        ;; advice installed by the user.
        (when (and (fboundp 'ivy--format)
                   (not (zenwriter--global-state-value 'ivy-advice)))
          (advice-add 'ivy--format :around #'zenwriter--ivy-format-copy-cands))
        ;; Enable zenwriter-mode in all existing buffers and future ones
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (zenwriter--turn-on)))
        (add-hook 'after-change-major-mode-hook #'zenwriter--turn-on)
        ;; React to macOS light/dark appearance changes
        (when (zenwriter--global-state-value 'appearance-hook-bound)
          (setq ns-system-appearance-change-functions nil)
          (add-hook 'ns-system-appearance-change-functions
                    #'zenwriter--apply-appearance)))
    (error
     ;; Attempt to put the editor back before propagating the enable error.
     (condition-case nil
         (zenwriter--global-disable)
       (error nil))
     (setq global-zenwriter-mode nil)
     (signal (car err) (cdr err)))))

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

(defvar-local zenwriter--focus-before-ov nil
  "Overlay covering text before the active unit.")

(defvar-local zenwriter--focus-after-ov nil
  "Overlay covering text after the active unit.")

(defvar-local zenwriter-focus-mode nil
  "Non-nil when Zenwriter focus mode is enabled in the current buffer.")

(defun zenwriter--focus-refresh ()
  "Refresh focus mode overlay colors for the current theme."
  (let ((dimmed (zenwriter--focus-dimmed-color)))
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (and zenwriter-focus-mode
                   zenwriter--focus-before-ov
                   zenwriter--focus-after-ov)
          (overlay-put zenwriter--focus-before-ov 'face `(:foreground ,dimmed))
          (overlay-put zenwriter--focus-after-ov 'face `(:foreground ,dimmed)))))))

(defun zenwriter--apply-appearance (appearance)
  "Switch zenwriter theme for the new system APPEARANCE (light or dark)."
  (setq frame-background-mode (if (eq appearance 'dark) 'dark 'light))
  (dolist (frame (frame-list))
    (frame-set-background-mode frame))
  (disable-theme 'zenwriter)
  (zenwriter--load-theme)
  (zenwriter--focus-refresh))

(defun zenwriter--global-disable ()
  "Deactivate zen writing environment, restoring saved state."
  ;; Restore critical visible state from the immutable snapshot even if a
  ;; package-specific cleanup above it signals an error.  The snapshot is
  ;; cleared only after the complete restoration succeeds, so a retry remains
  ;; possible after an interrupted disable.
  (unwind-protect
      (progn
        ;; Restore macOS appearance hook exactly, including an original nil.
        (when (zenwriter--global-state-value 'appearance-hook-bound)
          (remove-hook 'ns-system-appearance-change-functions
                       #'zenwriter--apply-appearance)
          (setq ns-system-appearance-change-functions
                (copy-sequence
                 (zenwriter--global-state-value 'appearance-hook))))
        ;; Remove only advice installed by this activation.
        (unless (zenwriter--global-state-value 'ivy-advice)
          (advice-remove 'ivy--format #'zenwriter--ivy-format-copy-cands))
        ;; Disable zenwriter-mode in all buffers
        (remove-hook 'after-change-major-mode-hook #'zenwriter--turn-on)
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (when zenwriter-mode
              (zenwriter-mode -1))))
        ;; Restore org-bars-mode if it was active
        (when (and (zenwriter--global-state-value 'org-bars-available)
                   (zenwriter--global-state-value 'org-bars))
          (add-hook 'org-mode-hook #'org-bars-mode)
          (dolist (buf (buffer-list))
            (with-current-buffer buf
              (when (derived-mode-p 'org-mode)
                (org-bars-mode 1)))))
        ;; Restore org-modern-mode if it was active
        (when (and (zenwriter--global-state-value 'org-modern-available)
                   (zenwriter--global-state-value 'org-modern))
          (global-org-modern-mode 1))
        ;; UI chrome
        (if (zenwriter--global-state-value 'scroll-bar-mode)
            (scroll-bar-mode 1)
          (scroll-bar-mode -1))
        (if (zenwriter--global-state-value 'tool-bar-mode)
            (tool-bar-mode 1)
          (tool-bar-mode -1))
        (if (zenwriter--global-state-value 'menu-bar-mode)
            (menu-bar-mode 1)
          (menu-bar-mode -1)))
    ;; Mode line: nil is valid state, so restore it unconditionally.
    (setq-default mode-line-format
                  (copy-tree
                   (zenwriter--global-state-value 'mode-line-format)))
    ;; Font
    (when (zenwriter--global-state-value 'font-to-apply)
      (set-face-attribute 'default nil :family
                          (zenwriter--global-state-value 'font-family)))
    ;; Theme and background mode.  Existing themes remained enabled, so
    ;; removing our layer reveals their original faces without reloading.
    (unless (zenwriter--global-state-value 'zenwriter-theme)
      (disable-theme 'zenwriter))
    (setq frame-background-mode
          (zenwriter--global-state-value 'previous-bg-mode))
    (dolist (frame (frame-list))
      (frame-set-background-mode frame))
    (force-mode-line-update t))
  (setq zenwriter--global-saved-state nil))

;;; --- zenwriter-focus-mode (buffer-local) ---

(defun zenwriter--focus-dimmed-color ()
  "Return the color to use for dimmed text."
  (or zenwriter-focus-dimmed-color
      (face-foreground 'font-lock-comment-face nil t)
      "#9E9E9E"))

(defun zenwriter--focus-bounds ()
  "Return (BEG . END) of the current visual line."
  (cons (save-excursion (beginning-of-visual-line) (point))
        (save-excursion (end-of-visual-line) (point))))

(defun zenwriter--focus-remove-overlays ()
  "Remove all focus overlays from the current buffer."
  (remove-overlays (point-min) (point-max) 'zenwriter-focus t)
  (setq zenwriter--focus-before-ov nil)
  (setq zenwriter--focus-after-ov nil))

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
        (zenwriter--focus-remove-overlays)
        (setq zenwriter--focus-before-ov (make-overlay (point-min) (point-min)))
        (setq zenwriter--focus-after-ov (make-overlay (point-max) (point-max)))
        (overlay-put zenwriter--focus-before-ov 'face `(:foreground ,dimmed))
        (overlay-put zenwriter--focus-after-ov 'face `(:foreground ,dimmed))
        (overlay-put zenwriter--focus-before-ov 'zenwriter-focus t)
        (overlay-put zenwriter--focus-after-ov 'zenwriter-focus t)
        (overlay-put zenwriter--focus-before-ov 'priority 100)
        (overlay-put zenwriter--focus-after-ov 'priority 100)
        (add-hook 'post-command-hook #'zenwriter--focus-update nil t)
        (zenwriter--focus-update))
    (remove-hook 'post-command-hook #'zenwriter--focus-update t)
    (zenwriter--focus-remove-overlays)))

(defun zenwriter--focus-turn-on ()
  "Turn on `zenwriter-focus-mode' in the current buffer."
  (unless (or (minibufferp)
              (string-prefix-p " " (buffer-name)))
    (zenwriter-focus-mode 1)))

;;;###autoload
(define-minor-mode global-zenwriter-focus-mode
  "Global minor mode that enables `zenwriter-focus-mode' in all buffers."
  :global t
  :lighter nil
  (if global-zenwriter-focus-mode
      (progn
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (zenwriter--focus-turn-on)))
        (add-hook 'after-change-major-mode-hook #'zenwriter--focus-turn-on))
    (remove-hook 'after-change-major-mode-hook #'zenwriter--focus-turn-on)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when zenwriter-focus-mode
          (zenwriter-focus-mode -1))
        (remove-hook 'post-command-hook #'zenwriter--focus-update t)
        (zenwriter--focus-remove-overlays)))))

(provide 'zenwriter-mode)

;;; zenwriter-mode.el ends here
