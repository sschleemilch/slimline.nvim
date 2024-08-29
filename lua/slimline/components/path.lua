local M = {}
local highlights = require('slimline.highlights')

--- @param config table
--- @param sep {left: string, right: string}
--- @return string
function M.render(config, sep)
  local file = highlights.hl_content(' ' .. vim.fn.expand('%:t') .. ' %m%r', highlights.hls.primary.text, sep.left)
  file = file .. highlights.hl_content(config.sep.right, highlights.hls.primary.sep_transition)

  local path = vim.fs.normalize(vim.fn.expand('%:.:h'))
  if #path == 0 then
    return ''
  end
  path = highlights.hl_content(' ' .. config.icons.folder .. path .. ' ', highlights.hls.secondary.text, nil, sep.right)

  return file .. path
end

return M
