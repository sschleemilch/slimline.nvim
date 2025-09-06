# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Next (minor)

### Added

- `filetype_lsp`: Added configuration option for separator between attached LSPs `lsp_sep`
- `progress`: Added virtual column, using default statusline format `%c%V`

### Fixed

- `progress`: Spacing when `icon` configured to be empty

## [2.5.4] - 2025-08-10

### Fixed

- Highlight of `SlimlineDiagnosticInfoSep` (typo)

## [2.5.3] - 2025-08-10

### Fixed

- Reduced spacing between `primary` and `secondary` part of components when in `style="fg"`. Was 2 spaces, is now 1. Enables a more compact line.

## [2.5.2] - 2025-08-03

### Fixed

- Made diagnostics highlights more consistent and better integrated when being inactive and in `bg` mode

## [2.5.1] - 2025-07-30

### Fixed

- `diagnostics`: wrong highlight names and double sections when `style=bg`

## [2.5.0] - 2025-07-29

### Changed

- `diagnostics`: Respecting `active` state - rendering using secondary highlights just as the other components

## [2.4.0] - 2025-07-20

### Added

- `searchcount` component
- `selectioncount` component
- [mini.diff](https://github.com/echasnovski/mini.diff) and [vim-fugitive](https://github.com/tpope/vim-fugitive) as `git` sources and the `git` CLI as fallback

### Changed

- `recording` primary highlight group to `Special` to make it a bit more eye catching by default

## [2.3.0] - 2025-07-11

### Added

- `mode`: Added `format` option to let users format the mode string (verbose and short)
- `trunc_width` option for components. Will be hidden once the window width drops below that value
- Defined statusline overflow truncation point after left components

### Fixed

- `mode`: Improved short format to distinguish visual, visual line and visual block modes

## [2.2.0] - 2025-07-03

### Added

- `path`: fish like `truncate`. Enabled by default with `chars = 1` and `full_dirs = 2`
- `filetype_lsp`: `map_lsps` option to disable LSPs or change their display name

## [2.1.0] - 2025-06-29

### Added

- `disabled_filetypes` option

## [2.0.1] - 2025-06-27

### Fixed

- Not using `"fg"` for referencing the `Normal` foreground. Can fail if `Normal` has no `fg` set.

## [2.0.0] - 2025-06-21

### Breaking

- Removed `Slimline` user command. Not really in use.
- Removed `diagnostics.placeholders`.

### Added

- Support for `vim.opt.laststatus` not being `3`, meaning having a line for each window
- Concept of inactive components configurable using `components_inactive`
- Highlighting of inactive components using the `secondary` hl

### Changed

- `diagnostics`
  - `workspace` enables both buffer and workspace diagnostics combined
  - event driven. Does not poll information on every statusline redraw but on diagnostic change
- `filetype_lsp`: Attached LSPs are event driven using `LspAttach` and `LspDetach` auto commands
- `mode`: Setting `vim.opt.showmode` only when `mode` component is configured
- `path`: Hiding secondary component when file is in root dir

## [1.7.1] - 2025-06-12

### Fixed

- `hl_component()` respecting the seperator highlight group. Only relevant for custom components

## [1.7.0] - 2025-06-12

### Changed

- Components can overwrite `left` / `right` separators
- New option for diagnostics: `placeholders`. Will always render all parts on `bg` style
- Render empty secondary part separator on `bg` style

## [1.6.0] - 2025-05-19

### Changed

- `diagnostics` is now colorful using `Diagnostic*` highlights instead of primary

## [1.5.2] - 2025-05-19

### Fixed

- diagnostic highlights when DiagnosticVirtualText\* has no bg

## [1.5.1] - 2025-05-17

### Fixed

- `diagnostics` severity components respecting `config.spaces.components`

## [1.5.0] - 2025-05-17

### Changed

- Improved `diagnostics` rendering in `style: bg` by using `DiagnosticVirtualText*` highlight groups and separating severities

### Fixed

- `Slimline switch style` command functionality

## [1.4.3] - 2025-04-27

### Fixed

- Optimized startup time by delaying highlights generation to first `render()`
- Changed default `base` highlight group to `Normal` since `Comment` does not define a `bg` and therefore had no effect

## [1.4.2] - 2025-04-01

### Fixed

- Mode highlights respecting `hl.base`

## [1.4.1] - 2025-04-01

### Fixed

- Mode switch not changing the highlight

## [1.4.0] - 2025-04-01

### Added

- `progress.column` option to show the cursor column in the secondary section

### Fixed

- Being able to use secondary section when following `mode`

## [1.3.0] - 2025-03-31

### Changed

- Added component configuration table `configs` to configure style and features of components.
  - `verbose_mode` -> `configs.mode.verbose`
  - `mode_follow_style` -> `configs.mode.style`
  - `workspace_diagnostics` -> `configs.diagnostics.workspace`
  - `hl.modes` -> `configs.mode.hl`
  - `icons.*` -> `configs.<component>.icon` or `configs.<component>.icons`

- Component configs can overwrite the global style using `configs.<component>.style`
- Component configs can overwrite the global highlights using `configs.<component>.hl` with `{ primary = ..., secondary = ...}`
- Component configs can follow the `style` and `hl` of another component using `configs.<component>.follow` with the name of the component to follow. E.g. `progress` has `follow = 'mode'` by default

- Added `vim.notify()` warning for deprecated options
- Automatically migrating deprecated options into new locations
- Added possibility to configure `git` icons

## [1.2.0] - 2024-12-19

### Added

- `diagnostics`: config option `workspace_diagnostics` to show workspace diagnostics instead of buffer only (#33)

## [1.1.0] - 2024-12-09

### Added

- `path` icons on read only / modified instead of text

## [1.0.0] - 2024-11-08

### Added

Everything (Baseline)
