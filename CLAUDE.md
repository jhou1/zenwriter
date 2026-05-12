# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A distraction-free writing environment for Emacs, inspired by iA Writer. Two-file package providing a monochromatic color theme, zen writing modes (olivetti centering, hidden chrome, font/spacing control), and visual-line focus dimming. The goal is zen-mode writing: no title bar, no buttons, no status bar — just background and text.

## Architecture

Two-file Emacs package: `zenwriter-theme.el` (color theme via `deftheme` / `custom-theme-set-faces`) and `zenwriter-mode.el` (companion modes). Supports both light and dark variants via class-based face specs. Pairs with `olivetti-mode` for centered text layout.

Key patterns:
- Both `global-zenwriter-mode` and `global-zenwriter-focus-mode` are hand-written `define-minor-mode :global t` (not `define-globalized-minor-mode`) for explicit buffer iteration on enable/disable
- `global-zenwriter-mode` saves/restores all modified global state (themes, font, chrome, mode-line) via an alist so toggling off is fully reversible
- Theme loading temporarily sets `custom-set` to `#'ignore` on both global mode variables to prevent `custom-theme-recalc-variable` from re-triggering modes during `enable-theme`/`load-theme`
- Focus mode overlays are tagged with `'zenwriter-focus t` property so `remove-overlays` can find and clean up orphaned overlays (e.g. after `kill-all-local-variables` during major mode changes)
- macOS light/dark appearance changes are handled via `ns-system-appearance-change-functions`
- Ivy face accumulation is worked around by copying candidate strings before formatting

## iA Writer Design Reference

### Philosophy
- "A white rectangle" — content over decoration
- No buttons, no popups, no title bar
- Monochromatic palette with a single blue accent (the cursor)
- Focus mode: active sentence in full color, surrounding text dimmed
- Typography drives the experience: monospace/duospace fonts (iA Writer Mono/Duo/Quattro, based on IBM Plex Mono; original was Nitti Light)

### Light Mode Colors (from reverse engineering and community ports)
| Element             | Value                        |
|---------------------|------------------------------|
| Background          | `#F5F6F6`                    |
| Text                | `#424242`                    |
| Cursor              | `#00BAFF` (iA signature blue)|
| Selection           | `#C1E7F4` or `#B3E2F2`      |
| Comments / Dimmed   | `#9E9E9E`                    |
| Secondary text      | `#6C6C6C`                    |
| Constants / Dark    | `#1C1C1C`                    |
| Line numbers        | `#BCBCBC`                    |
| Fringe / Chrome     | `#E4E4E4`                    |
| Search highlight    | `#C1E7F4` (light blue)       |
| Incremental search  | `#C3E9DB` (light green)      |
| Error               | `#FF1493`                    |
| Warning             | `#FF5F00`                    |
| Highlight           | `#E0E0E0`                    |

### Dark Mode Colors (from Sublime/vim ports)
| Element             | Value                        |
|---------------------|------------------------------|
| Background          | `#1D1F20`                    |
| Text                | `#C5C9C6`                    |
| Cursor              | `#15BDEC` (rgba 21,189,236)  |
| Selection           | `rgba(21,189,236,0.2)` → approx `#3A4A50` blend |
| Secondary text      | `#707070`                    |
| Code block bg       | `#222424`                    |
| Muted / links       | `#909090`                    |
| Comments            | `#525252`                    |
| Syntax red          | `#F2777A`                    |
| Syntax blue         | `#7AA4C2`                    |
| Syntax green        | `#B1BE5A`                    |
| Syntax yellow       | `#F2B160`                    |
| Syntax purple       | `#B893BE`                    |
| Highlight           | `#2A2C2D`                    |

### Focus Mode
- Active visual line: full foreground color
- Surrounding text: dimmed to comment-level gray (auto-detected from `font-lock-comment-face`, fallback `#9E9E9E`)

### Typography
- Line spacing: 8px (via `zenwriter-line-spacing`)
- Default font: Maple Mono CN, with fallback chain: Menlo → Consolas → Courier New
- Variable pitch is acceptable for body text in writing modes

## Build & Test

```bash
# Load theme in running Emacs
emacs -Q -l zenwriter-mode.el

# Batch byte-compile (should produce no warnings beyond defvar-local in with-current-buffer)
emacs --batch -f batch-byte-compile zenwriter-mode.el
emacs --batch -f batch-byte-compile zenwriter-theme.el

# Lint with package-lint (if installed)
emacs --batch -l package-lint -f package-lint-batch-and-exit zenwriter-mode.el

# Run ERT test suite (36 tests across theme, modes, focus mode, overlay leak scenarios)
emacs --batch -L . \
  --eval "(add-to-list 'custom-theme-load-path default-directory)" \
  -l ert -l test/zenwriter-mode-test.el \
  -f ert-run-tests-batch-and-exit
```

## Conventions

- All faces must specify both `:background` and `:foreground` where applicable, or use `unspecified` to inherit
- Use `deftheme` + `custom-theme-set-faces`, not the legacy `defface` approach
- Support `(load-theme 'zenwriter t)` as the entry point
- Provide light variant as default; dark variant via class-based detection
- Markdown/Org mode faces are first-class citizens — these are writing modes
- Minimize use of bold/underline — the aesthetic is restrained
- The modeline should be ultra-minimal (thin line or invisible) to match iA Writer's chrome-free design
- Test and verify the features and bug fixes
