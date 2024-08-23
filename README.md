# slimline.nvim

<!-- panvimdoc-ignore-start -->

![license](https://img.shields.io/github/license/sschleemilch/slimline.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

A minimal Neovim statusline written in Lua.

It started with doing my own statusline implementation.
Therefore, configuration options are quite limited and the design is very
opinionated at this moment.
Reason for writing it was mainly fun and to know more about the Neovim ecosystem.

## Screenshots

Here are some screenshots (might be out of date)

![s1](./doc/screenshots/s1.png)
![s2](./doc/screenshots/s2.png)
![s3](./doc/screenshots/s3.png)
![s4](./doc/screenshots/s4.png)

## Contributing

Feel free to create an issue/PR if you want to see anything else implemented.

<!-- panvimdoc-ignore-start -->

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "sschleemilch/slimline.nvim",
    dependencies = {
        "lewis6991/gitsigns.nvim",
        "echasnovski/mini.icons",
    },
    opts = {}
},
```

You'll also need to have a patched font if you want icons.

`gitsigns` is obviously used for providing the git branch and diff infos.
`mini.icons` as a provider for the file icons in the filetype component.


#### Default configuration


```lua
require('slimline').setup {
  bold = false,
  verbose_mode = false,
  component_spacing = " ",
  sep = {
    left = "",
    right = ""
  },
  hl = {
    modes = {
      normal = "Type",
      insert = "Function",
      pending = "Boolean",
      visual = "Keyword",
      command = "String",
    },
    base = "Normal",
    primary = "Normal",
    secondary = "Comment",
  },
  icons = {
    diagnostics = {
      ERROR = " ",
      WARN  = " ",
      HINT  = " ",
      INFO  = " ",
    },
    git = {
      branch = '',
    },
    folder = " ",
    lines = " ",
  }
}
```
