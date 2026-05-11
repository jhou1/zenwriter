;;; ia-writer-theme.el --- iA Writer inspired theme for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; Author: jhou
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: faces, themes
;; URL: https://github.com/jhou/emacs-writer

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; A color theme replicating iA Writer's distraction-free writing aesthetic.
;; Monochromatic palette with a signature blue cursor accent.
;; Supports both light and dark backgrounds via class-based detection.

;;; Code:

(deftheme ia-writer "iA Writer inspired theme for distraction-free writing.")

(let ((class '((class color) (min-colors 89)))
      ;; Light palette
      (lt-bg      "#F5F6F6")
      (lt-fg      "#424242")
      (lt-cursor  "#00BAFF")
      (lt-region  "#B3E2F2")
      (lt-fringe  "#F5F6F6")
      (lt-linum   "#BCBCBC")
      (lt-ml-fg   "#9E9E9E")
      (lt-ml-bg   "#E4E4E4")
      (lt-prompt  "#00BAFF")
      (lt-hl      "#C1E7F4")
      (lt-search  "#C3E9DB")
      (lt-err     "#FF1493")
      (lt-warn    "#FF5F00")
      (lt-succ    "#87D7AF")
      (lt-comment "#9E9E9E")
      (lt-second  "#6C6C6C")
      (lt-const   "#1C1C1C")
      ;; Dark palette
      (dk-bg      "#1D1F20")
      (dk-fg      "#C5C9C6")
      (dk-cursor  "#15BDEC")
      (dk-region  "#3A4A50")
      (dk-fringe  "#1D1F20")
      (dk-linum   "#525252")
      (dk-ml-fg   "#707070")
      (dk-ml-bg   "#222424")
      (dk-prompt  "#15BDEC")
      (dk-hl      "#2A3A40")
      (dk-search  "#1A3A2A")
      (dk-err     "#F2777A")
      (dk-warn    "#F2B160")
      (dk-succ    "#B1BE5A")
      (dk-comment "#525252")
      (dk-second  "#707070")
      (dk-muted   "#909090"))

  (custom-theme-set-faces
   'ia-writer

   ;; --- Tier 1: Core Emacs faces ---
   `(default ((,class (:background ,lt-bg :foreground ,lt-fg))
              (((background dark)) (:background ,dk-bg :foreground ,dk-fg))))
   `(cursor ((,class (:background ,lt-cursor))
             (((background dark)) (:background ,dk-cursor))))
   `(region ((,class (:background ,lt-region :foreground unspecified))
             (((background dark)) (:background ,dk-region :foreground unspecified))))
   `(fringe ((,class (:background ,lt-fringe :foreground ,lt-linum))
             (((background dark)) (:background ,dk-fringe :foreground ,dk-linum))))
   `(line-number ((,class (:background ,lt-fringe :foreground ,lt-linum))
                  (((background dark)) (:background ,dk-fringe :foreground ,dk-linum))))
   `(line-number-current-line ((,class (:background ,lt-fringe :foreground ,lt-fg :weight bold))
                               (((background dark)) (:background ,dk-fringe :foreground ,dk-fg :weight bold))))
   `(mode-line ((,class (:background ,lt-ml-bg :foreground ,lt-ml-fg :box nil :underline (:color ,lt-ml-bg :style line)))
                (((background dark)) (:background ,dk-ml-bg :foreground ,dk-ml-fg :box nil :underline (:color ,dk-ml-bg :style line)))))
   `(mode-line-inactive ((,class (:background ,lt-bg :foreground ,lt-linum :box nil :underline (:color ,lt-ml-bg :style line)))
                         (((background dark)) (:background ,dk-bg :foreground ,dk-linum :box nil :underline (:color ,dk-ml-bg :style line)))))
   `(minibuffer-prompt ((,class (:foreground ,lt-prompt :weight bold))
                        (((background dark)) (:foreground ,dk-prompt :weight bold))))
   `(highlight ((,class (:background ,lt-hl))
                (((background dark)) (:background ,dk-hl))))
   `(lazy-highlight ((,class (:background ,lt-hl))
                     (((background dark)) (:background ,dk-hl))))
   `(isearch ((,class (:background ,lt-search :foreground ,lt-fg))
              (((background dark)) (:background ,dk-search :foreground ,dk-fg))))
   `(isearch-fail ((,class (:background ,lt-err :foreground ,lt-bg))
                   (((background dark)) (:background ,dk-err :foreground ,dk-bg))))
   `(error ((,class (:foreground ,lt-err))
            (((background dark)) (:foreground ,dk-err))))
   `(warning ((,class (:foreground ,lt-warn))
              (((background dark)) (:foreground ,dk-warn))))
   `(success ((,class (:foreground ,lt-succ))
              (((background dark)) (:foreground ,dk-succ))))
   `(link ((,class (:foreground ,lt-second :underline nil))
           (((background dark)) (:foreground ,dk-muted :underline nil))))
   `(link-visited ((,class (:foreground ,lt-comment :underline nil))
                   (((background dark)) (:foreground ,dk-second :underline nil))))
   `(shadow ((,class (:foreground ,lt-comment))
             (((background dark)) (:foreground ,dk-comment))))
   `(secondary-selection ((,class (:background ,lt-hl))
                          (((background dark)) (:background ,dk-hl))))
   `(trailing-whitespace ((,class (:background ,lt-err))
                          (((background dark)) (:background ,dk-err))))
   `(vertical-border ((,class (:foreground ,lt-ml-bg))
                      (((background dark)) (:foreground ,dk-ml-bg))))
   `(window-divider ((,class (:foreground ,lt-ml-bg))
                     (((background dark)) (:foreground ,dk-ml-bg))))
   `(window-divider-first-pixel ((,class (:foreground ,lt-ml-bg))
                                 (((background dark)) (:foreground ,dk-ml-bg))))
   `(window-divider-last-pixel ((,class (:foreground ,lt-ml-bg))
                                (((background dark)) (:foreground ,dk-ml-bg))))))

(provide-theme 'ia-writer)

;;; ia-writer-theme.el ends here
