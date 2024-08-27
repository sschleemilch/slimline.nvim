local function create_M()
  local M = {}

  M.bold = false
  M.verbose_mode = false
  M.style = 'bg'

  M.spaces = {
    components = ' ',
    left = ' ',
    right = ' ',
  }

  M.sep = {
    hide = {
      first = false,
      last = false,
    },
    left = '',
    right = '',
  }

  M.components = {
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
  }

  M.hl = {
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
  }

  M.icons = {
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
  }

  return M
end

local M = create_M()

return M
