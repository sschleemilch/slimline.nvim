# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
