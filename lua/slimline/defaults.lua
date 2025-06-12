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

  -- Component configuration
  -- `<component>.style` can be used to overwrite the global 'style'
  -- `<component>.sep` can be used to overwrite the global 'sep.left' and `sep.right`
  -- `<component>.hl = { primary = ..., secondary = ...}` can be used to overwrite global ones
  -- `<component>.follow` can point to another component name to follow its style (e.g. 'progress' following 'mode' by default). Follow can be disabled by setting it to `false`
  configs = {
    mode = {
      verbose = false, -- Mode as single letter or as a word
      hl = {
        normal = 'Type',
        insert = 'Function',
        pending = 'Boolean',
        visual = 'Keyword',
        command = 'String',
      },
    },
    path = {
      directory = true, -- Whether to show the directory
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
      placeholders = false, -- Whether to show empty boxes for zero values. Only relevant if `style==bg`
      icons = {
        ERROR = ' ',
        WARN = ' ',
        HINT = ' ',
        INFO = ' ',
      },
    },
    filetype_lsp = {},
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
}

return M
