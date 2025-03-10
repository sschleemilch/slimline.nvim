# slimline.nvim

<!-- panvimdoc-ignore-start -->

[![neovim: v0.10.1+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.10.1%2b&logo=neovim&color=414b32)](https://neovim.io/)
![code size](https://img.shields.io/github/languages/code-size/sschleemilch/slimline.nvim?style=flat-square)
![license](https://img.shields.io/github/license/sschleemilch/slimline.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

A minimal Neovim statusline written in Lua.
Do we need another statusline? Probably not, do we have one? Yep

It started with doing my own statusline implementation.
Reason for writing it was mainly just 4 fun and having exactly what I want, function and aesthetic wise.

## Screenshots

Here are some screenshots. See [recipes](#recipes) for config examples.

![s1](./doc/screenshots/s1.png)
![s3](./doc/screenshots/s3.png)
![s5](./doc/screenshots/s5.png)
![s17](./doc/screenshots/s17.png)
![s11](./doc/screenshots/s11.png)
![s12](./doc/screenshots/s12.png)
![s13](./doc/screenshots/s13.png)
![s18](./doc/screenshots/s18.png)
![s19](./doc/screenshots/s19.png)
![s9](./doc/screenshots/s9.png)
![s10](./doc/screenshots/s10.png)
![s14](./doc/screenshots/s14.png)
![s15](./doc/screenshots/s15.png)
![s16](./doc/screenshots/s16.png)
![s6](./doc/screenshots/s6.png)
![s7](./doc/screenshots/s7.png)
![s8](./doc/screenshots/s8.png)

## Components

Available components:

- `mode`, well, you know what it is
- `path`, shows the filename and the relative path + modified / read-only info
- `git`, shows the git branch + file diff infos (added, modified and removed lines) (requires [gitsigns](https://github.com/lewis6991/gitsigns.nvim))
- `diagnostics`, shows `vim.diagnostic` infos
- `filetype_lsp`, shows the filetype and attached LSPs
- `progress`, shows the file progress in % and the overall number of lines
- `recording`, shows the register being used for recording (not enabled by default)

Which components to show in which section (`left`, `right`, `center`) can be configured.
Components can be configured more than once if desired.
The components configuration accepts function calls and strings so that you can hook custom content into the line.
See [Custom components](#custom-components) for an introduction.

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
  mode_follow_style = true, -- Whether the mode color components should follow the style option
  workspace_diagnostics = false, -- Whether diagnostics should show workspace diagnostics instead of current buffer
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
    recording = ' ',
    buffer = {
      modified = '',
      read_only = '',
    },
  },
}
```

## Highlights

Slimline creates highlight groups with the base highlights chosen in the `hl` section of the config.
The default ones should be a safe choice to work well with most colorschemes but of course you can adapt
them to your liking. Depending on the chosen `style` (fg or bg) the color will be used as a foreground
or as a background color.

> [!NOTE]
> When using a transparent colorscheme and using `style=bg` it means that the actual
> background will be used as a foreground color for text. Since a transparent theme has
> no background color, Slimline will fall back to `#000000` for dark themes and to `#ffffff`
> for white themes

## Commands

A `Slimline` command is available with the following sub commands:

- `switch`: Accepts only one parameter until now: `style`. Will switch the style for the current session

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

### Bubble chain

![s17](./doc/screenshots/s17.png)

```lua
opts = {
    spaces = {
        components = "─",
        left = "─",
        right = "─",
    },
},
```

And adding fillchars `stl` nvim setting:

```lua
vim.opt.fillchars = {
	stl = "─",
}
```

## Custom components

The `components` part of the config accepts function calls.
This opens the door extending Slimline with your own content.

> [!WARNING]
> This section uses internal APIs. Since I am not committing
> to stable internal APIs yet, it can change!
> Be carfeul when using it. The section will be updated accordingly
> when interfaces change though.

Let's create a center component using a function like this directly in the config:

```lua
center = {
    function ()
        return "Hello World"
    end
},
```

It will render to something like this (depending on your colorscheme):

![c1](./doc/custom_components/1.png)

If you want to use internal render functionality of a component you can do it like that:

```lua
function ()
    local h = require("slimline.highlights")
    local c = require("slimline").config
    return h.hl_component({primary = "Hello", secondary = "World"}, h.hls.component, c.sep)
end
```

It will now render to that (depending on the config)

![c4](./doc/custom_components/4.png)

Of course you can use `Slimline*` highlight groups on your own to create your own styled component
