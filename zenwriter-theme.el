;;; zenwriter-theme.el --- Zenwriter theme for distraction-free writing -*- lexical-binding: t; no-native-compile: t; -*-

;; Copyright (C) 2026
;; Author: jhou
;; Version: 0.2.4
;; Package-Requires: ((emacs "26.1"))
;; Keywords: faces, themes
;; URL: https://github.com/jhou1/zenwriter-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; Commentary:

;; A color theme replicating iA Writer's distraction-free writing aesthetic.
;; Monochromatic palette with a signature blue cursor accent.
;; Supports both light and dark backgrounds via class-based detection.

;;; Code:

(deftheme zenwriter "Zenwriter theme for distraction-free writing.")

;; --- Tier 1: Core Emacs faces ---
(custom-theme-set-faces
 'zenwriter
 '(default ((((background light)) (:background "#F5F6F6" :foreground "#424242"))
            (((background dark))  (:background "#1D1F20" :foreground "#C5C9C6"))))
 '(cursor ((((background light)) (:background "#00BAFF"))
           (((background dark))  (:background "#15BDEC"))))
 '(region ((((background light)) (:background "#B3E2F2" :foreground unspecified))
           (((background dark))  (:background "#3A4A50" :foreground unspecified))))
 '(fringe ((((background light)) (:background "#F5F6F6" :foreground "#BCBCBC"))
           (((background dark))  (:background "#1D1F20" :foreground "#525252"))))
 '(line-number ((((background light)) (:background "#F5F6F6" :foreground "#BCBCBC"))
                (((background dark))  (:background "#1D1F20" :foreground "#525252"))))
 '(line-number-current-line ((((background light)) (:background "#F5F6F6" :foreground "#424242" :weight bold))
                             (((background dark))  (:background "#1D1F20" :foreground "#C5C9C6" :weight bold))))
 '(mode-line ((((background light)) (:background "#F5F6F6" :foreground "#F5F6F6" :box nil :underline nil :overline nil))
              (((background dark))  (:background "#1D1F20" :foreground "#1D1F20" :box nil :underline nil :overline nil))))
 '(mode-line-inactive ((((background light)) (:background "#F5F6F6" :foreground "#F5F6F6" :box nil :underline nil :overline nil))
                       (((background dark))  (:background "#1D1F20" :foreground "#1D1F20" :box nil :underline nil :overline nil))))
 '(minibuffer-prompt ((((background light)) (:foreground "#00BAFF" :weight bold))
                      (((background dark))  (:foreground "#15BDEC" :weight bold)))))

;; --- Tier 1: Search, status, borders ---
(custom-theme-set-faces
 'zenwriter
 '(highlight ((((background light)) (:background "#E0E0E0" :extend nil))
              (((background dark))  (:background "#2A2C2D" :extend nil))))
 '(match ((((background light)) (:foreground "#424242" :weight bold))
          (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(lazy-highlight ((((background light)) (:background "#C1E7F4"))
                   (((background dark))  (:background "#2A3A40"))))
 '(isearch ((((background light)) (:background "#C3E9DB" :foreground "#424242"))
            (((background dark))  (:background "#1A3A2A" :foreground "#C5C9C6"))))
 '(isearch-fail ((((background light)) (:background "#FF1493" :foreground "#F5F6F6"))
                 (((background dark))  (:background "#F2777A" :foreground "#1D1F20"))))
 '(error ((((background light)) (:foreground "#FF1493"))
          (((background dark))  (:foreground "#F2777A"))))
 '(warning ((((background light)) (:foreground "#FF5F00"))
            (((background dark))  (:foreground "#F2B160"))))
 '(success ((((background light)) (:foreground "#87D7AF"))
            (((background dark))  (:foreground "#B1BE5A"))))
 '(link ((((background light)) (:foreground "#6C6C6C" :underline (:color "#BCBCBC" :style line)))
         (((background dark))  (:foreground "#909090" :underline (:color "#525252" :style line)))))
 '(link-visited ((((background light)) (:foreground "#9E9E9E" :underline (:color "#BCBCBC" :style line)))
                 (((background dark))  (:foreground "#707070" :underline (:color "#525252" :style line)))))
 '(shadow ((((background light)) (:foreground "#9E9E9E"))
           (((background dark))  (:foreground "#525252"))))
 '(secondary-selection ((((background light)) (:background "#C1E7F4"))
                        (((background dark))  (:background "#2A3A40"))))
 '(trailing-whitespace ((((background light)) (:background "#FF1493"))
                        (((background dark))  (:background "#F2777A"))))
 '(vertical-border ((((background light)) (:foreground "#E4E4E4"))
                    (((background dark))  (:foreground "#222424"))))
 '(window-divider ((((background light)) (:foreground "#E4E4E4"))
                   (((background dark))  (:foreground "#222424"))))
 '(window-divider-first-pixel ((((background light)) (:foreground "#E4E4E4"))
                               (((background dark))  (:foreground "#222424"))))
 '(window-divider-last-pixel ((((background light)) (:foreground "#E4E4E4"))
                              (((background dark))  (:foreground "#222424")))))

;; --- Tier 3: Font-lock faces ---
(custom-theme-set-faces
 'zenwriter
 '(font-lock-comment-face ((((background light)) (:foreground "#9E9E9E" :slant italic))
                           (((background dark))  (:foreground "#525252" :slant italic))))
 '(font-lock-comment-delimiter-face ((((background light)) (:foreground "#9E9E9E" :slant italic))
                                     (((background dark))  (:foreground "#525252" :slant italic))))
 '(font-lock-string-face ((((background light)) (:foreground "#6C6C6C"))
                          (((background dark))  (:foreground "#909090"))))
 '(font-lock-keyword-face ((((background light)) (:foreground "#4E4E4E"))
                           (((background dark))  (:foreground "#B893BE"))))
 '(font-lock-function-name-face ((((background light)) (:foreground "#585858"))
                                 (((background dark))  (:foreground "#7AA4C2"))))
 '(font-lock-variable-name-face ((((background light)) (:foreground "#424242"))
                                 (((background dark))  (:foreground "#C5C9C6"))))
 '(font-lock-type-face ((((background light)) (:foreground "#6C6C6C"))
                        (((background dark))  (:foreground "#707070"))))
 '(font-lock-constant-face ((((background light)) (:foreground "#1C1C1C"))
                            (((background dark))  (:foreground "#F2777A"))))
 '(font-lock-builtin-face ((((background light)) (:foreground "#4E4E4E"))
                           (((background dark))  (:foreground "#909090"))))
 '(font-lock-preprocessor-face ((((background light)) (:foreground "#6C6C6C"))
                                (((background dark))  (:foreground "#707070"))))
 '(font-lock-negation-char-face ((((background light)) (:foreground "#1C1C1C"))
                                 (((background dark))  (:foreground "#F2777A"))))
 '(font-lock-warning-face ((((background light)) (:foreground "#FF5F00"))
                           (((background dark))  (:foreground "#F2B160"))))
 '(font-lock-doc-face ((((background light)) (:foreground "#9E9E9E" :slant italic))
                       (((background dark))  (:foreground "#525252" :slant italic)))))

;; --- Tier 2: Markdown mode faces ---
(custom-theme-set-faces
 'zenwriter
 '(markdown-header-face ((((background light)) (:foreground "#424242" :weight bold))
                         (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-face-1 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-face-2 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-face-3 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-face-4 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-face-5 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-face-6 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-header-delimiter-face ((((background light)) (:foreground "#9E9E9E"))
                                   (((background dark))  (:foreground "#525252"))))
 '(markdown-bold-face ((((background light)) (:weight bold :foreground unspecified))
                       (((background dark))  (:weight bold :foreground unspecified))))
 '(markdown-italic-face ((((background light)) (:slant italic :foreground unspecified))
                         (((background dark))  (:slant italic :foreground unspecified))))
 '(markdown-link-face ((((background light)) (:foreground "#6C6C6C" :underline nil))
                       (((background dark))  (:foreground "#909090" :underline nil))))
 '(markdown-url-face ((((background light)) (:foreground "#9E9E9E" :underline nil))
                      (((background dark))  (:foreground "#525252" :underline nil))))
 '(markdown-inline-code-face ((((background light)) (:foreground "#1C1C1C" :background unspecified))
                              (((background dark))  (:foreground "#C5C9C6" :background "#222424"))))
 '(markdown-pre-face ((((background light)) (:foreground "#1C1C1C" :background unspecified))
                      (((background dark))  (:foreground "#C5C9C6" :background "#222424"))))
 '(markdown-code-face ((((background light)) (:foreground "#1C1C1C" :background unspecified))
                       (((background dark))  (:foreground "#C5C9C6" :background "#222424"))))
 '(markdown-blockquote-face ((((background light)) (:foreground "#9E9E9E" :slant italic))
                             (((background dark))  (:foreground "#525252" :slant italic))))
 '(markdown-list-face ((((background light)) (:foreground "#424242" :weight bold))
                       (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(markdown-markup-face ((((background light)) (:foreground "#9E9E9E"))
                         (((background dark))  (:foreground "#525252"))))
 '(markdown-metadata-key-face ((((background light)) (:foreground "#9E9E9E"))
                               (((background dark))  (:foreground "#525252"))))
 '(markdown-metadata-value-face ((((background light)) (:foreground "#6C6C6C"))
                                 (((background dark))  (:foreground "#707070")))))

;; --- Tier 2: Org mode faces ---
(custom-theme-set-faces
 'zenwriter
 '(org-level-1 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-2 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-3 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-4 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-5 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-6 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-7 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-level-8 ((((background light)) (:foreground "#424242" :weight bold))
                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-todo ((((background light)) (:foreground "#424242" :weight bold))
             (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-done ((((background light)) (:foreground "#9E9E9E" :weight bold))
             (((background dark))  (:foreground "#525252" :weight bold))))
 '(org-headline-done ((((background light)) (:foreground "#9E9E9E"))
                      (((background dark))  (:foreground "#525252")))))

;; --- Tier 2: Org mode faces (continued) ---
(custom-theme-set-faces
 'zenwriter
 '(org-link ((((background light)) (:foreground "#6C6C6C" :underline (:color "#BCBCBC" :style line)))
             (((background dark))  (:foreground "#909090" :underline (:color "#525252" :style line)))))
 '(org-date ((((background light)) (:foreground "#6C6C6C"))
             (((background dark))  (:foreground "#707070"))))
 '(org-meta-line ((((background light)) (:foreground "#9E9E9E"))
                  (((background dark))  (:foreground "#525252"))))
 '(org-drawer ((((background light)) (:foreground "#9E9E9E"))
               (((background dark))  (:foreground "#525252"))))
 '(org-tag ((((background light)) (:foreground "#9E9E9E" :weight normal))
            (((background dark))  (:foreground "#525252" :weight normal))))
 '(org-special-keyword ((((background light)) (:foreground "#9E9E9E"))
                        (((background dark))  (:foreground "#525252"))))
 '(org-document-title ((((background light)) (:foreground "#424242" :weight bold))
                       (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(org-document-info ((((background light)) (:foreground "#6C6C6C"))
                      (((background dark))  (:foreground "#707070"))))
 '(org-document-info-keyword ((((background light)) (:foreground "#9E9E9E"))
                              (((background dark))  (:foreground "#525252"))))
 '(org-block ((((background light)) (:foreground "#1C1C1C" :background unspecified))
              (((background dark))  (:foreground "#C5C9C6" :background "#222424"))))
 '(org-block-begin-line ((((background light)) (:foreground "#9E9E9E"))
                         (((background dark))  (:foreground "#525252"))))
 '(org-block-end-line ((((background light)) (:foreground "#9E9E9E"))
                       (((background dark))  (:foreground "#525252"))))
 '(org-code ((((background light)) (:foreground "#1C1C1C"))
             (((background dark))  (:foreground "#C5C9C6" :background "#222424"))))
 '(org-verbatim ((((background light)) (:foreground "#1C1C1C"))
                 (((background dark))  (:foreground "#C5C9C6" :background "#222424"))))
 '(org-table ((((background light)) (:foreground "#424242"))
              (((background dark))  (:foreground "#C5C9C6"))))
 '(org-checkbox ((((background light)) (:foreground "#424242" :weight bold))
                 (((background dark))  (:foreground "#C5C9C6" :weight bold)))))

;; --- Completion frameworks ---
(custom-theme-set-faces
 'zenwriter
 '(completions-highlight ((((background light)) (:background "#B3E2F2" :extend t))
                          (((background dark))  (:background "#3A4A50" :extend t))))
 '(completions-common-part ((((background light)) (:foreground "#424242"))
                            (((background dark))  (:foreground "#C5C9C6"))))
 '(completions-first-difference ((((background light)) (:foreground "#424242" :weight bold))
                                 (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(vertico-current ((((background light)) (:background "#B3E2F2" :extend t))
                    (((background dark))  (:background "#3A4A50" :extend t))))
 '(orderless-match-face-0 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(orderless-match-face-1 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(orderless-match-face-2 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(orderless-match-face-3 ((((background light)) (:foreground "#424242" :weight bold))
                           (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 ;; --- Ivy / Counsel ---
 '(ivy-current-match ((((background light)) (:background "#B3E2F2" :foreground "#424242" :extend t))
                      (((background dark))  (:background "#3A4A50" :foreground "#C5C9C6" :extend t))))
 '(ivy-minibuffer-match-face-1 ((((background light)) (:foreground "#424242"))
                                (((background dark))  (:foreground "#C5C9C6"))))
 '(ivy-minibuffer-match-face-2 ((((background light)) (:foreground "#424242" :weight bold))
                                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(ivy-minibuffer-match-face-3 ((((background light)) (:foreground "#424242" :weight bold))
                                (((background dark))  (:foreground "#C5C9C6" :weight bold))))
 '(ivy-minibuffer-match-face-4 ((((background light)) (:foreground "#424242" :weight bold))
                                (((background dark))  (:foreground "#C5C9C6" :weight bold)))))

(provide-theme 'zenwriter)

;;; zenwriter-theme.el ends here

