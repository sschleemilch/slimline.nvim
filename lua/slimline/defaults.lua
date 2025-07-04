local M = {
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

  components_inactive = {},

  -- Component configuration
  -- `<component>.style` can be used to overwrite the global 'style'
  -- `<component>.sep` can be used to overwrite the global 'sep.left' and `sep.right`
  -- `<component>.hl = { primary = ..., secondary = ...}` can be used to overwrite global ones
  -- `<component>.follow` can point to another component name to follow its style (e.g. 'progress' following 'mode' by default). Follow can be disabled by setting it to `false`
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
      directory = true, -- Whether to show the directory
      truncate = {
        chars = 1,
        full_dirs = 2,
      },
      icons = {
        folder = ' ',
        modified = '',
        read_only = '',
      },
    },
    git = {
      icons = {
        branch = '',
        added = '+',
        modified = '~',
        removed = '-',
      },
    },
    diagnostics = {
      workspace = false, -- Whether diagnostics should show workspace diagnostics instead of current buffer
      icons = {
        ERROR = ' ',
        WARN = ' ',
        HINT = ' ',
        INFO = ' ',
      },
    },
    filetype_lsp = {
      -- Map lsp client names to custom names or ignore them by setting to `false`
      -- E.g. { ['tsserver'] = 'TS', ['pyright'] = 'Python', ['GitHub Copilot'] = false }
      map_lsps = {},
    },
    progress = {
      follow = 'mode',
      column = false, -- Enables a secondary section with the cursor column
      icon = ' ',
    },
    recording = {
      icon = ' ',
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

return M
