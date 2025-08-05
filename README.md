<h2 align="center">
 <img src="./doc/slimline.png" width="100" alt="Slimline logo"/><br/>
 slimline.nvim
</h2>

<!-- panvimdoc-ignore-start -->

[![neovim: v0.10.1+](https://img.shields.io/static/v1?style=flat-square&label=neovim&message=v0.10.1%2b&logo=neovim&color=414b32)](https://neovim.io/)
![code size](https://img.shields.io/github/languages/code-size/sschleemilch/slimline.nvim?style=flat-square)
![license](https://img.shields.io/github/license/sschleemilch/slimline.nvim?style=flat-square)

<!-- panvimdoc-ignore-end -->

Another Neovim statusline written in Lua.

The goal is to provide a visual pleasing and efficient statusline.
It started with writing my own statusline.
Reason for writing was to learn more about the Neovim ecosystem and having exactly what I want, function and aesthetic wise.

In the meantime it is a quite generic and configurable alternative to other popular statuslines.

## Impressions

Here are some screenshots that might be a bit outdated. See [recipes](#recipes) for config examples.

![s1](./doc/screenshots/s1.png)
![s30](./doc/screenshots/s30.png)
![s5](./doc/screenshots/s5.png)
![s17](./doc/screenshots/s17.png)
![s13](./doc/screenshots/s13.png)
![s18](./doc/screenshots/s18.png)
![s20](./doc/screenshots/s20.png)
![s19](./doc/screenshots/s19.png)
![s9](./doc/screenshots/s9.png)
![s21](./doc/screenshots/s21.png)
![s10](./doc/screenshots/s10.png)
![s16](./doc/screenshots/s16.png)
![s6](./doc/screenshots/s6.png)
![s23](./doc/screenshots/s23.png)
![split](./doc/screenshots/split.png)

## Components

| Component      | Description                                                                                                                                                                                                                                                                              |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| mode           | Current mode. Automatically sets `vim.opt.showmode = false`                                                                                                                                                                                                                              |
| path           | Filename and the relative path as well as modified / read-only info. The directory path will be truncated. Can be disabled and configured                                                                                                                                                |
| git            | Branch and Diff infos (requires [gitsigns](https://github.com/lewis6991/gitsigns.nvim), [mini.diff](https://github.com/echasnovski/mini.diff) (diff only) or [vim-fugitive](https://github.com/tpope/vim-fugitive) (branch only). Uses the `git` CLI as fallback to retrieve the branch) |
| diagnostics    | `vim.diagnostic` infos. This component is event driven and will not poll the information on every statusline draw.                                                                                                                                                                       |
| filetype_lsp   | File type and attached LSPs. Attached LSPs are evaluated event driven on LSP attach / detach events. LSP names can be mapped to custom names or disabled using `configs.filetype_lsp.map_lsps`.                                                                                          |
| progress       | File progress in %, overall number of lines as well as the cursor column                                                                                                                                                                                                                 |
| recording      | Register being used when recording a macro                                                                                                                                                                                                                                               |
| searchcount    | Search result occurences                                                                                                                                                                                                                                                                 |
| selectioncount | Visually selected characters/lines or matrix                                                                                                                                                                                                                                             |

Which components to show in which section (`left`, `right`, `center`) can be configured.
The `components` entries accept function calls and strings so that you can create custom comonents.
See [Custom components](#custom-components) for an introduction.

Components have a _flow_ direction which means that components on the left have their primary part on the left side
and components on the right have their primary part on their right side.

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

### [mini.deps](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-deps.md)

```lua
MiniDeps.now(function()
    MiniDeps.add('sschleemilch/slimline.nvim')
    require('slimline').setup({})
end)
```

Optional dependencies:

- [gitsigns](https://github.com/lewis6991/gitsigns.nvim), [mini.diff](https://github.com/echasnovski/mini.diff) (diff only) or [vim-fugitive](https://github.com/tpope/vim-fugitive) (branch only) if you want the `git` component. Otherwise, it will not be rendered
- [mini.icons](https://github.com/echasnovski/mini.icons) if you want filetype icons

You'll also need to have a patched [nerd font](https://www.nerdfonts.com/) for icons and separators.

> [!TIP]
> You can decide whether you would like to have a global statusline or one for each split by setting `vim.opt.laststatus` accordingly
> in your settings.

If you decide to **not** use a global one then you can configure via `components_inactive` what will be rendered in the inactive one.
By default, all `components` will be shown. Inactive components will use the _secondary_ highlighting for primary parts.

![split](./doc/screenshots/split.png) shows an example using default options.

## Configuration

<details>
<summary>Default Options</summary>

```lua
{
  bold = false, -- makes primary parts bold

  -- Global style. Can be overwritten using `configs.<component>.style`
  style = 'bg', -- or "fg"

  -- Component placement
  components = {
    left = {
      'mode',
      'path',
      'git',
    },
    center = {},
    right = {
      'diagnostics',
      'filetype_lsp',
      'progress',
    },
  },

  -- Inactive components
  -- Uses all `components` by default.
  -- E.g. for only showing `path`:
  -- components_inactive = {
  --   left = { 'path' },
  --   right = {},
  -- },
  components_inactive = {},

  -- Component configuration
  -- `<component>.style` can be used to overwrite the global 'style'
  -- `<component>.sep` can be used to overwrite the global 'sep.left' and `sep.right`
  -- `<component>.hl = { primary = ..., secondary = ...}` can be used to overwrite global ones
  -- `<component>.follow` can point to another component name to follow its style (e.g. 'progress' following 'mode' by default). Follow can be disabled by setting it to `false`
  -- `<component>.trunc_width` can be used to hide a component completely once the window width drops below that value
  configs = {
    mode = {
      verbose = false, -- Selects the `verbose` format
      hl = {
        normal = 'Type',
        visual = 'Keyword',
        insert = 'Function',
        replace = 'Statement',
        command = 'String',
        other = 'Function',
      },
      format = {
        ['n'] = { verbose = 'NORMAL', short = 'N' },
        ['v'] = { verbose = 'VISUAL', short = 'V' },
        ['V'] = { verbose = 'V-LINE', short = 'V-L' },
        ['\22'] = { verbose = 'V-BLOCK', short = 'V-B' },
        ['s'] = { verbose = 'SELECT', short = 'S' },
        ['S'] = { verbose = 'S-LINE', short = 'S-L' },
        ['\19'] = { verbose = 'S-BLOCK', short = 'S-B' },
        ['i'] = { verbose = 'INSERT', short = 'I' },
        ['R'] = { verbose = 'REPLACE', short = 'R' },
        ['c'] = { verbose = 'COMMAND', short = 'C' },
        ['r'] = { verbose = 'PROMPT', short = 'P' },
        ['!'] = { verbose = 'SHELL', short = 'S' },
        ['t'] = { verbose = 'TERMINAL', short = 'T' },
        ['U'] = { verbose = 'UNKNOWN', short = 'U' },
      },
    },
    path = {
      trunc_width = 60,
      directory = true, -- Whether to show the directory
      -- truncates the directory path. Can be disabled by setting `truncate = false`
      truncate = {
        chars = 1, -- number of characters for each path component
        full_dirs = 2, -- how many path components to keep unshortened
      },
      icons = {
        folder = ' ',
        modified = '',
        read_only = '',
      },
    },
    git = {
      trunc_width = 120,
      icons = {
        branch = '',
        added = '+',
        modified = '~',
        removed = '-',
      },
    },
    diagnostics = {
      trunc_width = 75,
      workspace = false, -- Whether diagnostics should show workspace diagnostics instead of current buffer
      icons = {
        ERROR = ' ',
        WARN = ' ',
        HINT = ' ',
        INFO = ' ',
      },
      severity = {
        -- vim.diagnostic.SeverityFilter options
        min = vim.diagnostic.severity.HINT,
      },
      hl = {
        error = 'DiagnosticError',
        warn = 'DiagnosticWarn',
        hint = 'DiagnosticHint',
        info = 'DiagnosticInfo',
      },
    },
    filetype_lsp = {
      trunc_width = 95,
      -- Map lsp client names to custom names or ignore them by setting to `false`
      -- E.g. { ['tsserver'] = 'TS', ['pyright'] = 'Python', ['GitHub Copilot'] = false }
      map_lsps = {},
    },
    selectioncount = {
      hl = {
        primary = 'Special',
      },
      icon = '󰈈 ',
    },
    searchcount = {
      hl = {
        primary = 'Special',
      },
      icon = ' ',
      -- Options to be passed to vim.fn.searchcount, see :h searchcount
      options = {
        recompute = true,
      },
    },
    progress = {
      follow = 'mode',
      column = false, -- Enables a secondary section with the cursor column
      icon = ' ',
    },
    recording = {
      icon = ' ',
      hl = {
        primary = 'Special',
      },
    },
  },

  -- Spacing configuration
  spaces = {
    components = ' ', -- string between components
    left = ' ', -- string at the start of the line
    right = ' ', -- string at the end of the line
  },

  -- Seperator configuartion
  sep = {
    hide = {
      first = false, -- hides the first separator of the line
      last = false, -- hides the last separator of the line
    },
    left = '', -- left separator of components
    right = '', -- right separator of components
  },

  -- Global highlights
  hl = {
    base = 'Normal', -- highlight of the background
    primary = 'Normal', -- highlight of primary parts (e.g. filename)
    secondary = 'Comment', -- highlight of secondary parts (e.g. filepath)
  },

  -- Hide statusline on filetypes
  disabled_filetypes = {},
}
```

</details>

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

Instead of specifying the base highlight group in the config you can also tweak target highlight groups directly.
Make sure to do that **before** slimline's `setup()`.

<details>
<summary>Internal highlight groups</summary>

| Highlight Group                      | Description                                                                                      |
| ------------------------------------ | ------------------------------------------------------------------------------------------------ |
| Slimline                             | Background of the line                                                                           |
| SlimlineModeSecondary                | Secondary mode content (mode has no secondary content but progress has, which is following mode) |
| SlimlineModeNormal                   | Normal mode                                                                                      |
| SlimlineModeNormalSep                | Normal mode separator                                                                            |
| SlimlineModeNormalSep2Sec            | Normal mode separator to secondary                                                               |
| SlimlineModeVisual                   | Visual mode                                                                                      |
| SlimlineModeVisualSep                | Visual mode separator                                                                            |
| SlimlineModeVisualSep2Sec            | Visual mode separator to secondary                                                               |
| SlimlineModeInsert                   | Insert mode                                                                                      |
| SlimlineModeInsertSep                | Insert mode separator                                                                            |
| SlimlineModeInsertSep2Sec            | Insert mode separator to secondary                                                               |
| SlimlineModeReplace                  | Replace mode                                                                                     |
| SlimlineModeReplaceSep               | Replace mode separator                                                                           |
| SlimlineModeReplaceSep2Sec           | Replace mode separator to secondary                                                              |
| SlimlineModeCommand                  | Command mode                                                                                     |
| SlimlineModeCommandSep               | Command mode separator                                                                           |
| SlimlineModeCommandSep2Sec           | Command mode separator to secondary                                                              |
| SlimlineModeOther                    | Other mode                                                                                       |
| SlimlineModeOtherSep                 | Other mode separator                                                                             |
| SlimlineModeOtherSep2Sec             | Other mode separator to secondary                                                                |
| SlimlinePathPrimary                  | Path primary                                                                                     |
| SlimlinePathPrimarySep               | Path primary separator                                                                           |
| SlimlinePathPrimarySep2Sec           | Path primary separator to secondary                                                              |
| SlimlinePathSecondary                | Path secondary                                                                                   |
| SlimlinePathSecondarySep             | Path secondary separator                                                                         |
| SlimlineGitPrimary                   | Git primary                                                                                      |
| SlimlineGitPrimarySep                | Git primary separator                                                                            |
| SlimlineGitPrimarySep2Sec            | Git primary separator to secondary                                                               |
| SlimlineGitSecondary                 | Git secondary                                                                                    |
| SlimlineGitSecondarySep              | Git secondary separator                                                                          |
| SlimlineFiletype_lspPrimary          | Filetype lsp primary                                                                             |
| SlimlineFiletype_lspPrimarySep       | Filetype lsp primary separator                                                                   |
| SlimlineFiletype_lspPrimarySep2Sec   | Filetype lsp primary separator to secondary                                                      |
| SlimlineFiletype_lspSecondary        | Filetype lsp secondary                                                                           |
| SlimlineFiletype_lspSecondarySep     | Filetype lsp secondary separator                                                                 |
| SlimlineProgressPrimary              | Progress primary                                                                                 |
| SlimlineProgressPrimarySep           | Progress primary separator                                                                       |
| SlimlineProgressPrimarySep2Sec       | Progress primary separator to secondary                                                          |
| SlimlineProgressSecondary            | Progress secondary                                                                               |
| SlimlineProgressSecondarySep         | Progress secondary separator                                                                     |
| SlimlineRecordingPrimary             | Recording primary                                                                                |
| SlimlineRecordingPrimarySep          | Recording primary separator                                                                      |
| SlimlineRecordingPrimarySep2Sec      | Recording primary separator to secondary                                                         |
| SlimlineRecordingSecondary           | Recording secondary                                                                              |
| SlimlineRecordingSecondarySep        | Recording secondary separator                                                                    |
| SlimlineSearchcountPrimary           | Searchcount primary                                                                              |
| SlimlineSearchcountPrimarySep        | Searchcount primary separator                                                                    |
| SlimlineSearchcountPrimarySep2Sec    | Searchcount primary separator to secondary                                                       |
| SlimlineSearchcountSecondary         | Searchcount secondary                                                                            |
| SlimlineSearchcountSecondarySep      | Searchcount secondary separator                                                                  |
| SlimlineSelectioncountPrimary        | Selectioncount primary                                                                           |
| SlimlineSelectioncountPrimarySep     | Selectioncount primary separator                                                                 |
| SlimlineSelectioncountPrimarySep2Sec | Selectioncount primary separator to secondary                                                    |
| SlimlineSelectioncountSecondary      | Selectioncount secondary                                                                         |
| SlimlineSelectioncountSecondarySep   | Selectioncount secondary separator                                                               |
| SlimlineDiagnosticsHint              | Diagnostic hints                                                                                 |
| SlimlineDiagnosticsHintSep           | Diagnostic hints sep                                                                             |
| SlimlineDiagnosticsInfo              | Diagnostic infos                                                                                 |
| SlimlineDiagnosticsInfoSep           | Diagnostic infos sep                                                                             |
| SlimlineDiagnosticsWarn              | Diagnostic warnings                                                                              |
| SlimlineDiagnosticsWarnSep           | Diagnostic warnings sep                                                                          |
| SlimlineDiagnosticsError             | Diagnostic errors                                                                                |
| SlimlineDiagnosticsErrorSep          | Diagnostic errors sep                                                                            |

</details>

## Recipes

### Pure

![s20](./doc/screenshots/s20.png)
![s21](./doc/screenshots/s21.png)

```lua
opts = {
  style = 'fg',
  bold = true,
  hl = {
    secondary = 'Comment',
  },
  configs = {
    mode = {
      hl = {
        normal = 'Type',
        visual = 'Keyword',
        insert = 'Function',
        replace = 'Statement',
        command = 'String',
        other = 'Function',
      },
    },
    path = {
      hl = {
        primary = 'Label',
      },
    },
    git = {
      hl = {
        primary = 'Function',
      },
    },
    filetype_lsp = {
      hl = {
        primary = 'String',
      },
    },
  },
}
```

### Rainbow

![s23](./doc/screenshots/s23.png)

```lua
opts = {
  style = 'bg',
  configs = {
    path = {
      hl = {
        primary = 'Define',
      },
    },
    git = {
      hl = {
        primary = 'Function',
      },
    },
    filetype_lsp = {
      hl = {
        primary = 'String',
      },
    },
  },
}
```

### Calm format

![s9](./doc/screenshots/s9.png)
![s10](./doc/screenshots/s10.png)

```lua
opts = {
    style = "fg"
}
```

### Slashes format

![s13](./doc/screenshots/s13.png)

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
opts = {
    components = {
        center = {
            function ()
                return "Hello World"
            end
        },
    }
}
```

It will render to something like this (depending on your colorscheme):

![c1](./doc/custom_components/1.png)

If you want to use internal render functionality of a component (here of the `path` component) you can do it like that:

```lua
function(active)
    return Slimline.highlights.hl_component(
        { primary = 'Hello', secondary = 'World' },
        Slimline.highlights.hls.components['path'],
        Slimline.get_sep('path'),
        'right', -- flow direction (on which side the secondary part will be rendered)
        active -- whether the component is active or not
    )
end,
```

> [!WARNING]
> The component to use the highlights and seperator from needs to be configured in your `components` since slimline only creates highlights for used ones.

It will now render to that (depending on the config)

![c4](./doc/custom_components/4.png)

Of course you can use `Slimline*` highlight groups on your own to create your own styled component

The following lua table is required to be passed if you want to use `hl_component()`:

```lua
hl = {
    primary = {
        text = '',
        sep = '',
        sep2sec = '',
    },
    secondary = {
        text = '',
        sep = '',
    }
}
```

## Similar plugins

- [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [echasnovski/mini.statusline](https://github.com/echasnovski/mini.statusline/blob/main/README.md)
