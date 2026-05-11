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

(provide 'ia-writer)

;;; ia-writer.el ends here
