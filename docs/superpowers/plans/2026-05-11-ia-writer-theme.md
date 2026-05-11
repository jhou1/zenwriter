# iA Writer Emacs Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an Emacs color theme and companion minor modes that replicate iA Writer's distraction-free zen writing experience.

**Architecture:** Two files — `ia-writer-theme.el` (a standard `deftheme` with class-based light/dark auto-detection) and `ia-writer.el` (provides `ia-writer-mode` for zen setup and `ia-writer-focus-mode` for sentence-level dimming). Zero external dependencies; olivetti integration is optional runtime detection.

**Tech Stack:** Emacs Lisp, `deftheme` / `custom-theme-set-faces`, `define-minor-mode`, `define-globalized-minor-mode`, overlays.

**Spec:** `docs/superpowers/specs/2026-05-11-ia-writer-theme-design.md`

---

## File Structure

| File | Responsibility |
|------|---------------|
| `ia-writer-theme.el` | Color theme: `deftheme` with all face definitions for light and dark modes. Tier 1 (core Emacs), Tier 2 (Markdown/Org), Tier 3 (font-lock). No side effects. |
| `ia-writer.el` | Companion package: `ia-writer-mode` (global minor mode for zen setup), `ia-writer-focus-mode` (buffer-local minor mode for sentence dimming), all `defcustom` variables. |

---

### Task 1: Theme Skeleton — `deftheme` with Core Faces (Tier 1)

**Files:**
- Create: `ia-writer-theme.el`

- [ ] **Step 1: Create `ia-writer-theme.el` with package header, `deftheme`, and core faces**

```elisp
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
```

- [ ] **Step 2: Byte-compile to verify no errors**

Run: `emacs --batch -f batch-byte-compile ia-writer-theme.el`
Expected: Compiles with no warnings or errors. Produces `ia-writer-theme.elc`.

- [ ] **Step 3: Smoke-test the theme loads**

Run: `emacs --batch -l ia-writer-theme.el --eval "(progn (load-theme 'ia-writer t) (message \"Theme loaded OK\"))" 2>&1`
Expected: Prints "Theme loaded OK" with no errors.

- [ ] **Step 4: Clean up compiled file and commit**

```bash
rm -f ia-writer-theme.elc
git init
git add ia-writer-theme.el
git commit -m "feat: ia-writer theme skeleton with Tier 1 core faces"
```

---

### Task 2: Theme — Font-Lock Faces (Tier 3)

**Files:**
- Modify: `ia-writer-theme.el` (add faces inside the existing `custom-theme-set-faces` call, before the closing `))``)

- [ ] **Step 1: Add font-lock faces before the closing parens of `custom-theme-set-faces`**

Insert the following face definitions after the `window-divider-last-pixel` face and before the closing `))`:

```elisp
   ;; --- Tier 3: Font-lock faces ---
   `(font-lock-comment-face ((,class (:foreground ,lt-comment :slant italic))
                             (((background dark)) (:foreground ,dk-comment :slant italic))))
   `(font-lock-comment-delimiter-face ((,class (:foreground ,lt-comment :slant italic))
                                       (((background dark)) (:foreground ,dk-comment :slant italic))))
   `(font-lock-string-face ((,class (:foreground ,lt-second))
                            (((background dark)) (:foreground ,dk-muted))))
   `(font-lock-keyword-face ((,class (:foreground "#4E4E4E"))
                             (((background dark)) (:foreground "#B893BE"))))
   `(font-lock-function-name-face ((,class (:foreground "#585858"))
                                   (((background dark)) (:foreground "#7AA4C2"))))
   `(font-lock-variable-name-face ((,class (:foreground ,lt-fg))
                                   (((background dark)) (:foreground ,dk-fg))))
   `(font-lock-type-face ((,class (:foreground ,lt-second))
                          (((background dark)) (:foreground ,dk-second))))
   `(font-lock-constant-face ((,class (:foreground ,lt-const))
                              (((background dark)) (:foreground ,dk-err))))
   `(font-lock-builtin-face ((,class (:foreground "#4E4E4E"))
                             (((background dark)) (:foreground ,dk-muted))))
   `(font-lock-preprocessor-face ((,class (:foreground ,lt-second))
                                  (((background dark)) (:foreground ,dk-second))))
   `(font-lock-negation-char-face ((,class (:foreground ,lt-const))
                                   (((background dark)) (:foreground ,dk-err))))
   `(font-lock-warning-face ((,class (:foreground ,lt-warn))
                             (((background dark)) (:foreground ,dk-warn))))
   `(font-lock-doc-face ((,class (:foreground ,lt-comment :slant italic))
                         (((background dark)) (:foreground ,dk-comment :slant italic))))
```

- [ ] **Step 2: Byte-compile to verify no errors**

Run: `emacs --batch -f batch-byte-compile ia-writer-theme.el`
Expected: Compiles with no warnings or errors.

- [ ] **Step 3: Smoke-test theme still loads**

Run: `emacs --batch -l ia-writer-theme.el --eval "(progn (load-theme 'ia-writer t) (message \"Theme loaded OK\"))" 2>&1`
Expected: Prints "Theme loaded OK" with no errors.

- [ ] **Step 4: Commit**

```bash
rm -f ia-writer-theme.elc
git add ia-writer-theme.el
git commit -m "feat: add font-lock faces (Tier 3) to ia-writer theme"
```

---

### Task 3: Theme — Markdown & Org Faces (Tier 2)

**Files:**
- Modify: `ia-writer-theme.el` (add faces inside `custom-theme-set-faces`, after font-lock faces)

- [ ] **Step 1: Add Markdown and Org mode faces**

Insert after the font-lock faces, before the closing `))`:

```elisp
   ;; --- Tier 2: Markdown mode faces ---
   `(markdown-header-face ((,class (:foreground ,lt-fg :weight bold))
                           (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(markdown-header-face-1 ((,class (:foreground ,lt-fg :weight bold :height 1.3))
                             (((background dark)) (:foreground ,dk-fg :weight bold :height 1.3))))
   `(markdown-header-face-2 ((,class (:foreground ,lt-fg :weight bold :height 1.2))
                             (((background dark)) (:foreground ,dk-fg :weight bold :height 1.2))))
   `(markdown-header-face-3 ((,class (:foreground ,lt-fg :weight bold :height 1.1))
                             (((background dark)) (:foreground ,dk-fg :weight bold :height 1.1))))
   `(markdown-header-face-4 ((,class (:foreground ,lt-fg :weight bold))
                             (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(markdown-header-face-5 ((,class (:foreground ,lt-fg :weight bold))
                             (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(markdown-header-face-6 ((,class (:foreground ,lt-fg :weight bold))
                             (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(markdown-header-delimiter-face ((,class (:foreground ,lt-comment))
                                     (((background dark)) (:foreground ,dk-comment))))
   `(markdown-bold-face ((,class (:weight bold :foreground unspecified))
                         (((background dark)) (:weight bold :foreground unspecified))))
   `(markdown-italic-face ((,class (:slant italic :foreground unspecified))
                           (((background dark)) (:slant italic :foreground unspecified))))
   `(markdown-link-face ((,class (:foreground ,lt-second :underline nil))
                         (((background dark)) (:foreground ,dk-muted :underline nil))))
   `(markdown-url-face ((,class (:foreground ,lt-comment :underline nil))
                        (((background dark)) (:foreground ,dk-comment :underline nil))))
   `(markdown-inline-code-face ((,class (:foreground ,lt-const :background unspecified))
                                (((background dark)) (:foreground ,dk-fg :background ,dk-ml-bg))))
   `(markdown-pre-face ((,class (:foreground ,lt-const :background unspecified))
                        (((background dark)) (:foreground ,dk-fg :background ,dk-ml-bg))))
   `(markdown-code-face ((,class (:foreground ,lt-const :background unspecified))
                         (((background dark)) (:foreground ,dk-fg :background ,dk-ml-bg))))
   `(markdown-blockquote-face ((,class (:foreground ,lt-comment :slant italic))
                               (((background dark)) (:foreground ,dk-comment :slant italic))))
   `(markdown-list-face ((,class (:foreground ,lt-fg :weight bold))
                         (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(markdown-markup-face ((,class (:foreground ,lt-comment))
                           (((background dark)) (:foreground ,dk-comment))))
   `(markdown-metadata-key-face ((,class (:foreground ,lt-comment))
                                 (((background dark)) (:foreground ,dk-comment))))
   `(markdown-metadata-value-face ((,class (:foreground ,lt-second))
                                   (((background dark)) (:foreground ,dk-second))))

   ;; --- Tier 2: Org mode faces ---
   `(org-level-1 ((,class (:foreground ,lt-fg :weight bold :height 1.3))
                  (((background dark)) (:foreground ,dk-fg :weight bold :height 1.3))))
   `(org-level-2 ((,class (:foreground ,lt-fg :weight bold :height 1.2))
                  (((background dark)) (:foreground ,dk-fg :weight bold :height 1.2))))
   `(org-level-3 ((,class (:foreground ,lt-fg :weight bold :height 1.1))
                  (((background dark)) (:foreground ,dk-fg :weight bold :height 1.1))))
   `(org-level-4 ((,class (:foreground ,lt-fg :weight bold))
                  (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(org-level-5 ((,class (:foreground ,lt-fg :weight bold))
                  (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(org-level-6 ((,class (:foreground ,lt-fg :weight bold))
                  (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(org-level-7 ((,class (:foreground ,lt-fg :weight bold))
                  (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(org-level-8 ((,class (:foreground ,lt-fg :weight bold))
                  (((background dark)) (:foreground ,dk-fg :weight bold))))
   `(org-todo ((,class (:foreground "#AF5FFF" :weight bold))
               (((background dark)) (:foreground "#B893BE" :weight bold))))
   `(org-done ((,class (:foreground ,lt-succ :weight bold))
               (((background dark)) (:foreground ,dk-succ :weight bold))))
   `(org-headline-done ((,class (:foreground ,lt-comment))
                        (((background dark)) (:foreground ,dk-comment))))
   `(org-link ((,class (:foreground ,lt-second :underline nil))
               (((background dark)) (:foreground ,dk-muted :underline nil))))
   `(org-date ((,class (:foreground ,lt-second))
               (((background dark)) (:foreground ,dk-second))))
   `(org-meta-line ((,class (:foreground ,lt-comment))
                    (((background dark)) (:foreground ,dk-comment))))
   `(org-drawer ((,class (:foreground ,lt-comment))
                 (((background dark)) (:foreground ,dk-comment))))
   `(org-tag ((,class (:foreground ,lt-comment :weight normal))
              (((background dark)) (:foreground ,dk-comment :weight normal))))
   `(org-special-keyword ((,class (:foreground ,lt-comment))
                          (((background dark)) (:foreground ,dk-comment))))
   `(org-document-title ((,class (:foreground ,lt-fg :weight bold :height 1.4))
                         (((background dark)) (:foreground ,dk-fg :weight bold :height 1.4))))
   `(org-document-info ((,class (:foreground ,lt-second))
                        (((background dark)) (:foreground ,dk-second))))
   `(org-document-info-keyword ((,class (:foreground ,lt-comment))
                                (((background dark)) (:foreground ,dk-comment))))
   `(org-block ((,class (:foreground ,lt-const :background unspecified))
                (((background dark)) (:foreground ,dk-fg :background ,dk-ml-bg))))
   `(org-block-begin-line ((,class (:foreground ,lt-comment))
                           (((background dark)) (:foreground ,dk-comment))))
   `(org-block-end-line ((,class (:foreground ,lt-comment))
                         (((background dark)) (:foreground ,dk-comment))))
   `(org-code ((,class (:foreground ,lt-const))
               (((background dark)) (:foreground ,dk-fg :background ,dk-ml-bg))))
   `(org-verbatim ((,class (:foreground ,lt-const))
                   (((background dark)) (:foreground ,dk-fg :background ,dk-ml-bg))))
   `(org-table ((,class (:foreground ,lt-fg))
                (((background dark)) (:foreground ,dk-fg))))
   `(org-checkbox ((,class (:foreground ,lt-fg :weight bold))
                   (((background dark)) (:foreground ,dk-fg :weight bold))))
```

- [ ] **Step 2: Byte-compile to verify no errors**

Run: `emacs --batch -f batch-byte-compile ia-writer-theme.el`
Expected: No warnings or errors.

- [ ] **Step 3: Smoke-test theme loads**

Run: `emacs --batch -l ia-writer-theme.el --eval "(progn (load-theme 'ia-writer t) (message \"Theme loaded OK\"))" 2>&1`
Expected: Prints "Theme loaded OK".

- [ ] **Step 4: Commit**

```bash
rm -f ia-writer-theme.elc
git add ia-writer-theme.el
git commit -m "feat: add Markdown and Org mode faces (Tier 2)"
```

---

### Task 4: Companion Package Skeleton — `ia-writer.el` with Defcustoms

**Files:**
- Create: `ia-writer.el`

- [ ] **Step 1: Create `ia-writer.el` with package header and defcustom variables**

```elisp
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

(provide 'ia-writer)

;;; ia-writer.el ends here
```

- [ ] **Step 2: Byte-compile to verify no errors**

Run: `emacs --batch -f batch-byte-compile ia-writer.el`
Expected: No warnings or errors.

- [ ] **Step 3: Commit**

```bash
rm -f ia-writer.elc
git add ia-writer.el
git commit -m "feat: ia-writer.el skeleton with defcustom variables"
```

---

### Task 5: Implement `ia-writer-mode` (Global Minor Mode)

**Files:**
- Modify: `ia-writer.el` (add the mode definition before `(provide 'ia-writer)`)

- [ ] **Step 1: Add state storage variables and helper functions**

Insert before `(provide 'ia-writer)`:

```elisp
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
```

- [ ] **Step 2: Add the `ia-writer-mode` definition**

Insert after the helper functions:

```elisp
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
```

- [ ] **Step 3: Byte-compile to verify no errors**

Run: `emacs --batch -f batch-byte-compile ia-writer.el`
Expected: No warnings or errors.

- [ ] **Step 4: Smoke-test mode activation**

Run: `emacs --batch -l ia-writer-theme.el -l ia-writer.el --eval "(progn (ia-writer-mode 1) (message \"ia-writer-mode: %s\" ia-writer-mode) (ia-writer-mode -1) (message \"Disabled OK\"))" 2>&1`
Expected: Prints "ia-writer-mode: t" then "Disabled OK".

- [ ] **Step 5: Commit**

```bash
rm -f ia-writer.elc
git add ia-writer.el
git commit -m "feat: implement ia-writer-mode global minor mode"
```

---

### Task 6: Implement `ia-writer-focus-mode` (Buffer-Local Minor Mode)

**Files:**
- Modify: `ia-writer.el` (add focus mode before `(provide 'ia-writer)`)

- [ ] **Step 1: Add overlay variables and the dimmed color helper**

Insert after `ia-writer--disable` and before `(provide 'ia-writer)`:

```elisp
(defvar-local ia-writer--focus-before-ov nil
  "Overlay covering text before the active unit.")

(defvar-local ia-writer--focus-after-ov nil
  "Overlay covering text after the active unit.")

(defun ia-writer--focus-dimmed-color ()
  "Return the color to use for dimmed text."
  (or ia-writer-focus-dimmed-color
      (face-foreground 'font-lock-comment-face nil t)
      "#9E9E9E"))
```

- [ ] **Step 2: Add the sentence/paragraph boundary detection function**

```elisp
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
```

- [ ] **Step 3: Add the overlay update function**

```elisp
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
```

- [ ] **Step 4: Add the minor mode definition**

```elisp
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
```

- [ ] **Step 5: Byte-compile to verify no errors**

Run: `emacs --batch -f batch-byte-compile ia-writer.el`
Expected: No warnings or errors.

- [ ] **Step 6: Smoke-test focus mode**

Run:
```bash
emacs --batch -l ia-writer.el --eval "
(progn
  (with-temp-buffer
    (insert \"First sentence. Second sentence. Third sentence.\")
    (goto-char 20)
    (ia-writer-focus-mode 1)
    (message \"Focus mode: %s\" ia-writer-focus-mode)
    (message \"Before ov: %s-%s\" (overlay-start ia-writer--focus-before-ov) (overlay-end ia-writer--focus-before-ov))
    (message \"After ov: %s-%s\" (overlay-start ia-writer--focus-after-ov) (overlay-end ia-writer--focus-after-ov))
    (ia-writer-focus-mode -1)
    (message \"Disabled OK\")))" 2>&1
```
Expected: Prints focus mode status, overlay positions covering text before and after the second sentence, and "Disabled OK".

- [ ] **Step 7: Commit**

```bash
rm -f ia-writer.elc
git add ia-writer.el
git commit -m "feat: implement ia-writer-focus-mode with sentence/paragraph dimming"
```

---

### Task 7: Integration Test — Full Zen Experience

**Files:**
- No new files. Testing the two files together.

- [ ] **Step 1: Run a combined load test**

Run:
```bash
emacs --batch -l ia-writer-theme.el -l ia-writer.el --eval "
(progn
  (load-theme 'ia-writer t)
  (message \"Theme faces: default bg=%s fg=%s\"
           (face-attribute 'default :background)
           (face-attribute 'default :foreground))
  (message \"Cursor: %s\" (face-attribute 'cursor :background))
  (message \"Region: %s\" (face-attribute 'region :background))
  (message \"Comment: %s\" (face-attribute 'font-lock-comment-face :foreground))
  (with-temp-buffer
    (insert \"Hello world. This is a test. Focus here.\")
    (goto-char 25)
    (ia-writer-focus-mode 1)
    (let ((b-start (overlay-start ia-writer--focus-before-ov))
          (b-end (overlay-end ia-writer--focus-before-ov))
          (a-start (overlay-start ia-writer--focus-after-ov))
          (a-end (overlay-end ia-writer--focus-after-ov)))
      (message \"Focus bounds: dimmed [%s-%s] active [%s-%s] dimmed [%s-%s]\"
               b-start b-end b-end a-start a-start a-end))
    (ia-writer-focus-mode -1))
  (message \"All tests passed\"))" 2>&1
```
Expected: Prints face attributes matching the light mode palette, correct focus overlay bounds around the second sentence, and "All tests passed".

- [ ] **Step 2: Verify both files byte-compile cleanly together**

Run:
```bash
emacs --batch -f batch-byte-compile ia-writer-theme.el ia-writer.el 2>&1
```
Expected: No warnings or errors.

- [ ] **Step 3: Clean up and commit**

```bash
rm -f ia-writer-theme.elc ia-writer.elc
git add -A
git commit -m "test: verify full zen experience integration"
```

---

### Task 8: Add `require` for `seq` and Autoload Cookies

**Files:**
- Modify: `ia-writer.el` (add `require` and ensure autoloads are correct)

- [ ] **Step 1: Add `(require 'seq)` at the top of `ia-writer.el`**

Insert after `;;; Code:`:

```elisp
(require 'seq)
```

This is needed for `seq-find` used in `ia-writer--find-font`.

- [ ] **Step 2: Verify autoload cookies are present**

Confirm these lines exist (they should from Tasks 5 and 6):
- `;;;###autoload` before `(define-minor-mode ia-writer-mode`
- `;;;###autoload` before `(define-minor-mode ia-writer-focus-mode`

- [ ] **Step 3: Byte-compile and test**

Run: `emacs --batch -f batch-byte-compile ia-writer.el 2>&1`
Expected: No warnings.

- [ ] **Step 4: Commit**

```bash
rm -f ia-writer.elc
git add ia-writer.el
git commit -m "chore: add seq require and verify autoload cookies"
```
