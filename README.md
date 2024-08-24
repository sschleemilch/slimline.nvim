# slimline.nvim

<!-- panvimdoc-ignore-start -->

![license](https://img.shields.io/github/license/sschleemilch/slimline.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

A minimal Neovim statusline written in Lua.

It started with doing my own statusline implementation.
Therefore, configuration options are quite limited and the design is very
opinionated at this moment.
Reason for writing it was mainly fun and to know more about the Neovim ecosystem.

Currently only those components are available that cannot be reordered or switched off:
- Mode
- Filename + Path
- Git Branch + File added, modified and removed lines
- Filetype and attached LSPs
- File progress and overall number of lines

Slimline creates highlight groups from given highlight groups in the config.
The default configuration uses highlight groups that are set by ever colorscheme there is.
Therefore it supports every colorscheme by design and should look quite good with defaults.
Of course you can tweak that however you want.

## Screenshots

Here are some screenshots and their options changed

Normal mode (rose-pine moon), `bold=true`, `verbose_mode=true`
![s1](./doc/screenshots/s1.png)
Normal mode (rose-pine moon), triangle seps, `bold=true`
![s2](./doc/screenshots/s2.png)
Insert Mode (rose-pine moon), default
![s3](./doc/screenshots/s3.png)
Command Mode (kanagawa), default
![s4](./doc/screenshots/s4.png)
Normal Mode (tokyonight moon), `component_spacing = "─"` + `vim.opt.fillchars.stl = "─"`
![s5](./doc/screenshots/s5.png)

## Contributing

Feel free to create an issue/PR if you want to see anything else implemented.

<!-- panvimdoc-ignore-start -->

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "sschleemilch/slimline.nvim",
    dependencies = {
        "lewis6991/gitsigns.nvim", --- Optional
        "echasnovski/mini.icons", --- Optional
    },
    opts = {}
},
```

You'll also need to have a patched font if you want icons.

Optional dependencies:

- [gitsigns](https://github.com/lewis6991/gitsigns.nvim) if you want the `git` component. Otherwise it will just not be shown
- [mini.icons](https://github.com/echasnovski/mini.icons) if you want filetype icons next to the filetype


#### Default configuration

```lua
require('slimline').setup {
  bold = false,
  verbose_mode = false,
  component_spacing = ' ',
  sep = {
    left = '',
    right = '',
  },
  hl = {
    modes = {
      normal = 'Type',
      insert = 'Function',
      pending = 'Boolean',
      visual = 'Keyword',
      command = 'String',
    },
    base = 'Comment',
    primary = 'Normal',
    secondary = 'Comment',
  },
  icons = {
    diagnostics = {
      ERROR = ' ',
      WARN = ' ',
      HINT = ' ',
      INFO = ' ',
    },
    git = {
      branch = '',
    },
    folder = ' ',
    lines = ' ',
  },
}
```
