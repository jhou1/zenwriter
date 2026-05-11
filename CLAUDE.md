# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

An Emacs color theme that replicates iA Writer's distraction-free writing aesthetic. The goal is zen-mode writing: no title bar, no buttons, no status bar — just background and text.

## Architecture

Two-file Emacs package: `zenwriter-theme.el` (color theme) and `zenwriter-mode.el` (companion modes). Follows Emacs `deftheme` / `custom-theme-set-faces` conventions. Supports both light and dark variants. Pairs with `olivetti-mode` for centered text layout.

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
| TODO                | `#AF5FFF`                    |

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
| Syntax orange       | `#EA9052`                    |

### Focus Mode
- Active sentence/paragraph: full foreground color
- Surrounding text: dimmed to comment-level gray
- The Spacemacs distraction-free-theme uses `#1dafe6` for cursor and `#b3e2f2` for region

### Typography
- Line height / leading: 1.5
- Font: IBM Plex Mono (open source successor to Nitti Light), or iA Writer Quattro/Duo/Mono
- Variable pitch is acceptable for body text in writing modes

## Build & Test

```bash
# Load theme in running Emacs
emacs -Q -l zenwriter-mode.el

# Batch byte-compile (should produce no warnings)
emacs --batch -f batch-byte-compile zenwriter-mode.el

# Lint with package-lint (if installed)
emacs --batch -l package-lint -f package-lint-batch-and-exit zenwriter-mode.el
```

## Conventions

- All faces must specify both `:background` and `:foreground` where applicable, or use `unspecified` to inherit
- Use `deftheme` + `custom-theme-set-faces`, not the legacy `defface` approach
- Support `(load-theme 'zenwriter t)` as the entry point
- Provide light variant as default; dark variant via class-based detection
- Markdown/Org mode faces are first-class citizens — these are writing modes
- Minimize use of bold/underline — the aesthetic is restrained
- The modeline should be ultra-minimal (thin line or invisible) to match iA Writer's chrome-free design
