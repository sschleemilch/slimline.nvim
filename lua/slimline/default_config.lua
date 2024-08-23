local M = {
  bold = false,
  verbose_mode = false,
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

return M
