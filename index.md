---
title: zenwriter-mode
description: A distraction-free writing environment for Emacs, inspired by iA Writer
---

# zenwriter-mode

A distraction-free writing environment for Emacs, inspired by [iA Writer](https://ia.net/writer).

Monochromatic color theme with a signature blue cursor, zen writing modes, and visual-line focus dimming.

![Light mode](light.png)
![Dark mode](dark.png)

## Features

- **Light and dark themes** — auto-detected from system appearance, switches live on macOS
- **Zen writing mode** — olivetti centering, generous line spacing, hidden chrome
- **Focus mode** — dims all text except the current visual line
- **First-class Org and Markdown faces** — headings are bold, same size as body text
- **One command** — `global-zenwriter-mode` enables everything; toggling off restores your previous setup

## Quick start

```elisp
;; Load the theme only
(load-theme 'zenwriter t)

;; Full zen experience — theme, font, hidden chrome, all buffers
(global-zenwriter-mode 1)
```

## Installation

### straight.el + use-package

```elisp
(use-package zenwriter-mode
  :straight (zenwriter-mode
    :type git
    :host github
    :repo "jhou1/zenwriter-mode"
    :files ("*.el"))
  :commands (zenwriter-mode global-zenwriter-mode
             zenwriter-focus-mode global-zenwriter-focus-mode)
  :init
  (add-to-list 'custom-theme-load-path
               (expand-file-name "straight/repos/zenwriter-mode"
                                 user-emacs-directory)))
```

### Manual

```bash
git clone https://github.com/jhou1/zenwriter-mode ~/.emacs.d/zenwriter-mode
```

```elisp
(add-to-list 'custom-theme-load-path "~/.emacs.d/zenwriter-mode")
(add-to-list 'load-path "~/.emacs.d/zenwriter-mode")
(require 'zenwriter-mode)
```

## Customization

| Variable | Default | Description |
|----------|---------|-------------|
| `zenwriter-font-family` | `"Maple Mono CN"` | Font set by `global-zenwriter-mode` |
| `zenwriter-line-spacing` | `8` | Extra line spacing in pixels |
| `zenwriter-body-width` | `100` | Text body width in columns |
| `zenwriter-focus-dimmed-color` | `nil` (auto) | Color for dimmed text in focus mode |

## Requirements

- Emacs 26.1+
- [Maple Mono CN](https://github.com/subframe7536/maple-font) font (or set `zenwriter-font-family` to your preferred font)
- Optional: [olivetti](https://github.com/rnkn/olivetti) for text centering

## License

[GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html)
