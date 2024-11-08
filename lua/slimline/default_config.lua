local M = {
  bold = false, -- makes primary parts and mode bold
  verbose_mode = false, -- Mode as single letter or as a word
  style = 'bg', -- or "fg". Whether highlights should be applied to bg or fg of components
  mode_follow_style = true, -- Whether the mode color components should follow the style option
  components = { -- Choose components and their location
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
  },
}

return M
