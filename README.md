# slimline.nvim

<!-- panvimdoc-ignore-start -->

![license](https://img.shields.io/github/license/sschleemilch/slimline.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

A minimal Neovim statusline written in Lua.
Do we need another statusline? Probably not, do we have one? Yep

It started with doing my own statusline implementation.
Therefore, configuration options are quite limited and the design is very
opinionated at this moment.
Reason for writing it was mainly just 4 fun and having exactly what I want, function and aesthetic wise.

Currently only those components are available that cannot be reordered or switched off.
Configuration options are mainly about changing the style:

- Mode
- Filename + Path
- Git Branch + File added, modified and removed lines (requires [gitsigns](https://github.com/lewis6991/gitsigns.nvim))
- Filetype and attached LSPs
- File progress and overall number of lines

Slimline creates highlight groups from given highlight groups in the config.
The default configuration uses highlight groups that are set by every colorscheme out there.
Therefore it supports every colorscheme out of the box and should look quite good with defaults.
Of course you can tweak that however you want using the `hl` part of the config options.

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
Normal Mode (tokyonight moon), `spaces.components = "─"` + `vim.opt.fillchars.stl = "─"`
![s5](./doc/screenshots/s5.png)
Normal Mode (tokyonight moon), `bold=true`, `verbose_mode=true`, `style="fg"`
![s6](./doc/screenshots/s6.png)
Normal Mode (tokyonight day), `bold=true`, `verbose_mode=true`
![s7](./doc/screenshots/s7.png)
Insert Mode (rose-pine dawn),

```lua
opts = {
    bold = true,
    verbose_mode = true,
    spaces = {
        components = "",
        left = "",
        right  = ""
    },
    sep = {
        hide = {
            first = true,
            last = true,
        },
        left = "",
        right = ""
    }
},
```

![s8](./doc/screenshots/s8.png)

## Contributing

Feel free to create an issue/PR if you want to see anything else implemented.

<!-- panvimdoc-ignore-start -->

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    -- Calls `require('slimline').setup({})`
    "sschleemilch/slimline.nvim",
    opts = {}
},
```

Optional dependencies:

- [gitsigns](https://github.com/lewis6991/gitsigns.nvim) if you want the `git` component. Otherwise it will just not be shown
- [mini.icons](https://github.com/echasnovski/mini.icons) if you want icons next to the filetype

You'll also need to have a patched [nerd font](https://www.nerdfonts.com/) if you want icons and separators.

#### Default configuration

```lua
require('slimline').setup {
  bold = false, -- makes primary parts and mode bold
  verbose_mode = false, -- Mode as single letter or as a word
  style = 'bg', -- or "fg". Whether highlights should be applied to bg or fg of components
  spaces = {
    components = ' ', -- string between components
    left = ' ', -- string at the start of the line
    right = ' ', -- string at the end of the line
  },
  sep = {
    hide = {
      first = false, -- hides the first separator
      last = false, -- hides the last separator
    },
    left = '', -- left separator of components
    right = '', -- right separator of components
  },
  hl = {
    modes = {
      normal = 'Type', -- highlight base of modes
      insert = 'Function',
      pending = 'Boolean',
      visual = 'Keyword',
      command = 'String',
    },
    base = 'Comment', -- highlight of everything in in between components
    primary = 'Normal', -- highlight of primary parts (e.g. filename)
    secondary = 'Comment', -- highlight of secondary parts (e.g. filepath)
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
