local M = {
  bold = false,
  verbose_mode = false,
  style = 'bg',
  spaces = {
    components = ' ',
    left = ' ',
    right = ' ',
  },
  sep = {
    hide = {
      first = false,
      last = false,
    },
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

return M
