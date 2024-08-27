# slimline.nvim

<!-- panvimdoc-ignore-start -->

![license](https://img.shields.io/github/license/sschleemilch/slimline.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

> [!WARNING]
> The project is new, does not have releases and is a Work in Progress. Therefore interfaces can change frequently

A minimal Neovim statusline written in Lua.
Do we need another statusline? Probably not, do we have one? Yep

It started with doing my own statusline implementation.
Reason for writing it was mainly just 4 fun and having exactly what I want, function and aesthetic wise.

Those components are available out of the box:

- `mode`, well, you know what it is
- `path`, shows the filename and the relative path + modified / read-only info
- `git`, shows the git branch + file diff infos (added, modified and removed lines) (requires [gitsigns](https://github.com/lewis6991/gitsigns.nvim))
- `diagnostics`, shows `vim.diagnostic` infos
- `filetype_lsp`, shows the filetype and attached LSPs
- `progress`, shows the file progress in % and the overall number of lines

Regarding some wording: Some components have a `primary` and a `secondary` part. The primary part contains the main
information of interest (e.g. the filename of the `path` component). The secondary
part additional infos (e.g. the path to the file of the `path` component).
Those are the colors that are currently configurable through the config.

Which components to show in which section (`left`, `right`, `center`) can be configured.
Components can be configured more than once if desired.
The components configuration accepts function calls and strings so that you can hook custom content into the line.

## Highlights

Slimline creates highlight groups from given highlight groups in the config.
The default configuration uses highlight groups that are set by every colorscheme out there.
Therefore it supports every colorscheme out of the box and should look quite good with defaults.
That means that the colorscheme does not need to support this line explicitly.
Of course you can tweak that however you want using the `hl` part of the config options.
If you want to write custom components you probably want to use the created highlight groups.
You can find them e.g. by running `:hi` in your nvim session that has slimline loaded and searching for `Slimline`.

## Screenshots

Here are some screenshots. See [recipes](#recipes) for config examples.

![s1](./doc/screenshots/s1.png)
![s2](./doc/screenshots/s2.png)
![s3](./doc/screenshots/s3.png)
![s4](./doc/screenshots/s4.png)
![s5](./doc/screenshots/s5.png)
![s11](./doc/screenshots/s11.png)
![s12](./doc/screenshots/s12.png)
![s13](./doc/screenshots/s13.png)
![s9](./doc/screenshots/s9.png)
![s10](./doc/screenshots/s10.png)
![s14](./doc/screenshots/s14.png)
![s15](./doc/screenshots/s15.png)
![s16](./doc/screenshots/s16.png)
![s6](./doc/screenshots/s6.png)
![s7](./doc/screenshots/s7.png)
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
  components = { -- Choose components and their location
    left = {
      "mode",
      "path",
      "git"
    },
    center = {},
    right = {
      "diagnostics",
      "filetype_lsp",
      "progress"
    }
  },
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

## Recipes

### Calm format

![s9](./doc/screenshots/s9.png)
![s10](./doc/screenshots/s10.png)

```lua
opts = {
    style = "fg"
}
```


### Slashes format

![s11](./doc/screenshots/s11.png)

```lua
opts = {
    spaces = {
        components = "",
        left = "",
        right = "",
    },
    sep = {
        hide = {
            first = true,
            last = true,
        },
        left = "",
        right = "",
    },
}
```

### Custom component

```lua
opts = {
    components = {
        center = {
            function()
                local sep_left = vim.g.slimline_config.sep.left
                local sep_right = vim.g.slimline_config.sep.right
                local result = "%#SlimlinePrimarySep#" .. sep_left
                result = result .. "%#SlimlinePrimary#" .. " FOO "
                result = result .. "%#SlimlinePrimarySep#" .. sep_right
                result = result .. "%#Slimline#"
                return result
            end,
        },
    },
}
```
