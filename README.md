# zen-writer-theme for Emacs

A distraction-free writing environment for Emacs, inspired by [iA Writer](https://ia.net/writer). Monochromatic color theme with a signature blue cursor, zen writing modes, and visual-line focus dimming.

## Features

**Color theme** (`zen-writer-theme.el`)
- Light and dark variants, auto-detected from your frame background
- Monochromatic grays for light mode, subtle muted colors for dark mode
- First-class Org mode and Markdown faces — headings are bold, same size as body text
- Subtle link underlines for discoverability without visual noise
- Invisible modeline

**Zen writing mode** (`zen-writer.el`)
- `zen-writer-mode` (buffer-local) — olivetti centering + generous line spacing
- `global-zen-writer-mode` — full zen: loads theme, sets font, hides toolbar/scrollbar/menubar/modeline, disables org-bars and org-modern if present, enables `zen-writer-mode` in all buffers. Toggling off restores your previous themes and settings.

**Focus mode**
- `zen-writer-focus-mode` (buffer-local) — dims all text except the current visual line
- `global-zen-writer-focus-mode` — focus mode in all buffers

## Prerequisites

### Font: Maple Mono CN

The theme uses [Maple Mono CN](https://github.com/subframe7536/maple-font) by default. Install it before using `global-zen-writer-mode`.

**macOS (Homebrew):**

```bash
brew install --cask font-maple-mono-cn
```

**Manual download:**

Download from [Maple Font releases](https://github.com/subframe7536/maple-font/releases) and install the `MapleMono-CN-*.ttf` files to your system fonts directory.

If you prefer a different font, set `zen-writer-font-family` before enabling the mode.

## Installation

### Manual

```bash
git clone https://github.com/jhou1/zen-writer /path/to/zen-writer
```

Add to your `init.el` or `.emacs`:

```elisp
(add-to-list 'custom-theme-load-path "/path/to/zen-writer")
(add-to-list 'load-path "/path/to/zen-writer")
(require 'zen-writer)
```

### straight.el + use-package

```elisp
(use-package zen-writer
  :straight (zen-writer
    :type git
    :host github
    :repo "jhou1/zen-writer"
    :files ("*.el"))
  :commands (zen-writer-mode global-zen-writer-mode
             zen-writer-focus-mode global-zen-writer-focus-mode)
  :init
  (add-to-list 'custom-theme-load-path
               (expand-file-name "straight/repos/zen-writer"
                                 user-emacs-directory)))
```

## Usage

```elisp
;; Just the color theme
(load-theme 'zen-writer t)

;; Zen mode in the current buffer
(zen-writer-mode 1)

;; Full zen experience — all buffers, theme, font, hidden chrome
(global-zen-writer-mode 1)

;; Focus mode — dim everything except the current line
(global-zen-writer-focus-mode 1)
```

Toggle off with the same commands (or pass `-1`). `global-zen-writer-mode` restores your previous themes and UI state when disabled.

## Customization

| Variable | Default | Description |
|----------|---------|-------------|
| `zen-writer-font-family` | `"Maple Mono CN"` | Font set by `global-zen-writer-mode` |
| `zen-writer-line-spacing` | `8` | Extra line spacing in pixels |
| `zen-writer-body-width` | `100` | Text body width in columns (olivetti) |
| `zen-writer-focus-dimmed-color` | `nil` (auto) | Foreground color for dimmed text; when nil, reads from `font-lock-comment-face` |

Example:

```elisp
(setq zen-writer-font-family "Iosevka")
(setq zen-writer-body-width 90)
(setq zen-writer-line-spacing 6)
```

## Optional dependencies

- [olivetti](https://github.com/rnkn/olivetti) — text centering (detected at runtime, falls back to window margins)

## Requirements

- Emacs 26.1+

## License

GPL-3.0
