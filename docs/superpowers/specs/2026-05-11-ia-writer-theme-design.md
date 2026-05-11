# iA Writer Emacs Theme — Design Spec

## Overview

An Emacs color theme and companion minor modes that replicate iA Writer's distraction-free zen writing experience. Two files, zero external dependencies.

## Files

### `ia-writer-theme.el` — Color Theme

A standard `deftheme` loaded via `(load-theme 'ia-writer t)`. Uses class-based specs `((background light))` / `((background dark))` to auto-detect and adapt. No side effects beyond face definitions.

### `ia-writer.el` — Companion Modes

Provides two minor modes:

- **`ia-writer-mode`** (global) — transforms the frame into a zen writing environment
- **`ia-writer-focus-mode`** (buffer-local) — dims all text except the active sentence/paragraph

## Color Palette

### Light Mode

| Face / Element        | Value       | Notes                          |
|-----------------------|-------------|--------------------------------|
| Background            | `#F5F6F6`   | Warm off-white                 |
| Foreground (text)     | `#424242`   | Soft black                     |
| Cursor                | `#00BAFF`   | iA signature blue              |
| Region (selection)    | `#B3E2F2`   | Light blue                     |
| Fringe                | `#F5F6F6`   | Same as background (invisible) |
| Line numbers          | `#BCBCBC`   | Very subtle                    |
| Mode-line fg          | `#9E9E9E`   | Muted gray                     |
| Mode-line bg          | `#E4E4E4`   | One shade off background       |
| Mode-line-inactive bg | `#F5F6F6`   | Same as background             |
| Minibuffer prompt     | `#00BAFF`   | Blue accent                    |
| Highlight             | `#C1E7F4`   | Light blue                     |
| isearch               | `#C3E9DB`   | Light green tint               |
| lazy-highlight        | `#C1E7F4`   | Light blue                     |
| Error                 | `#FF1493`   | Hot pink                       |
| Warning               | `#FF5F00`   | Orange                         |
| Success               | `#87D7AF`   | Muted green                    |
| Comment color         | `#9E9E9E`   | Gray                           |
| Secondary text        | `#6C6C6C`   | Medium gray                    |
| Constants / emphasis  | `#1C1C1C`   | Near-black                     |

### Dark Mode

| Face / Element        | Value       | Notes                          |
|-----------------------|-------------|--------------------------------|
| Background            | `#1D1F20`   | Dark charcoal                  |
| Foreground (text)     | `#C5C9C6`   | Warm light gray                |
| Cursor                | `#15BDEC`   | iA signature blue (lighter)    |
| Region (selection)    | `#3A4A50`   | Dark teal                      |
| Fringe                | `#1D1F20`   | Same as background             |
| Line numbers          | `#525252`   | Subtle                         |
| Mode-line fg          | `#707070`   | Muted                          |
| Mode-line bg          | `#222424`   | One shade lighter              |
| Mode-line-inactive bg | `#1D1F20`   | Same as background             |
| Minibuffer prompt     | `#15BDEC`   | Blue accent                    |
| Highlight             | `#2A3A40`   | Subtle dark blue               |
| isearch               | `#1A3A2A`   | Subtle dark green              |
| lazy-highlight        | `#2A3A40`   | Subtle dark blue               |
| Error                 | `#F2777A`   | Soft red                       |
| Warning               | `#F2B160`   | Warm yellow                    |
| Success               | `#B1BE5A`   | Olive green                    |
| Comment color         | `#525252`   | Dark gray                      |
| Secondary text        | `#707070`   | Medium gray                    |
| Muted / links         | `#909090`   | Light gray                     |

### Dark Mode Syntax Colors (for code blocks / programming)

| Face                        | Value       |
|-----------------------------|-------------|
| font-lock-keyword-face      | `#B893BE`   |
| font-lock-function-name-face| `#7AA4C2`   |
| font-lock-string-face       | `#909090`   |
| font-lock-constant-face     | `#F2777A`   |
| font-lock-type-face         | `#707070`   |
| font-lock-comment-face      | `#525252`   |

### Light Mode Syntax Colors (monochromatic grays)

| Face                        | Value       |
|-----------------------------|-------------|
| font-lock-keyword-face      | `#4E4E4E`   |
| font-lock-function-name-face| `#585858`   |
| font-lock-string-face       | `#6C6C6C`   |
| font-lock-constant-face     | `#1C1C1C`   |
| font-lock-type-face         | `#6C6C6C`   |
| font-lock-comment-face      | `#9E9E9E`   |

## Face Tiers

### Tier 1 — Core Emacs

`default`, `cursor`, `region`, `fringe`, `line-number`, `line-number-current-line`, `mode-line`, `mode-line-inactive`, `minibuffer-prompt`, `highlight`, `lazy-highlight`, `isearch`, `isearch-fail`, `error`, `warning`, `success`, `link`, `link-visited`, `shadow`, `secondary-selection`, `trailing-whitespace`, `vertical-border`, `window-divider`.

### Tier 2 — Writing Modes (Markdown & Org)

**Headings:** Same foreground as body text, bold weight. No color differentiation between levels — iA Writer is monochromatic.

**Bold / Italic:** Inherit font-style only, no color change.

**Links:** Secondary text color (`#6C6C6C` / `#909090`). No underline in the buffer.

**Inline code / verbatim:** Slightly darker fg in light mode (`#1C1C1C`), same fg in dark mode. Subtle background tint for code blocks.

**Blockquotes:** Dimmed to comment color.

**List markers:** Bold, same color as body text.

**Org TODO/DONE:** Purple `#AF5FFF` / `#B893BE` for TODO, muted green for DONE.

**Org meta lines, drawers, tags:** Comment color (dimmed).

### Tier 3 — Basic Font-Lock

Monochromatic grays in light mode. Subtle muted colors in dark mode (see syntax color tables above). All `font-lock-variable-name-face` inherits body text color (no highlight). `font-lock-comment-face` is italic.

## `ia-writer-mode` (Global Minor Mode)

### Activation

1. Load theme `ia-writer` if not already active
2. Set frame font to IBM Plex Mono (fall back to Menlo, then default monospace)
3. Set `line-spacing` to 0.5
4. Hide modeline — store original `mode-line-format`, replace with a single space using a face that has a 1-pixel `:underline` matching the fringe color, creating a subtle divider line
5. Disable `scroll-bar-mode`, `tool-bar-mode`, `menu-bar-mode` (store originals)
6. Enable olivetti-mode with body width 80 if olivetti is available
7. If no olivetti, set `left-margin-width` and `right-margin-width` as fallback centering

### Deactivation

Restore all stored original values: mode-line-format, UI chrome modes, line-spacing, font, margins. Disable olivetti if it was enabled by us. Unload theme.

### Defcustom Variables

| Variable                  | Default            | Type    |
|---------------------------|--------------------|---------|
| `ia-writer-font-family`   | `"IBM Plex Mono"`  | string  |
| `ia-writer-font-size`     | `140`              | integer |
| `ia-writer-line-spacing`  | `0.5`              | number  |
| `ia-writer-body-width`    | `80`               | integer |

## `ia-writer-focus-mode` (Buffer-Local Minor Mode)

### Mechanism

Two persistent overlays:

- **Before-overlay:** covers `(point-min)` to start of active sentence
- **After-overlay:** covers end of active sentence to `(point-max)`

Both overlays have a `face` property setting foreground to the dimmed color (`#9E9E9E` light / `#525252` dark, auto-detected from `font-lock-comment-face`).

### Sentence Detection

Uses `forward-sentence` / `backward-sentence` (Emacs built-ins). In Markdown/Org, respects paragraph boundaries — a heading or blank line also acts as a boundary.

### Update Cycle

`post-command-hook` calls a lightweight function that:

1. Finds sentence boundaries via `save-excursion` + `backward-sentence` / `forward-sentence`
2. Calls `move-overlay` on the two persistent overlays (no create/destroy churn)

### Defcustom Variables

| Variable                      | Default      | Type          |
|-------------------------------|--------------|---------------|
| `ia-writer-focus-unit`        | `'sentence`  | symbol        |
| `ia-writer-focus-dimmed-color`| `nil`        | string or nil |

When `ia-writer-focus-unit` is `'paragraph`, uses `forward-paragraph` / `backward-paragraph` instead.

When `ia-writer-focus-dimmed-color` is nil, reads the foreground from `font-lock-comment-face` at runtime.

### Overlay Priority

Overlays use a high `priority` value (e.g., 100) to ensure they render on top of font-lock faces but below `isearch` overlays.

## Package Metadata

- `Package-Requires: ((emacs "26.1"))`
- No external dependencies (olivetti is optional runtime detection)
- License: GPL-3.0
- `ia-writer.el` provides `ia-writer`, autoloads `ia-writer-mode` and `ia-writer-focus-mode`
- `ia-writer-theme.el` follows standard `custom-theme-load-path` convention
