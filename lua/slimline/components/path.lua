local M = {}
local highlights = require('slimline.highlights')
local config = require('slimline').config

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @return string
function M.render(sep, direction)
  if vim.bo.buftype ~= '' then
    return ''
  end
  local file = vim.fn.expand('%:t')
  if vim.bo.modified then
    file = file .. ' ' .. config.icons.buffer.modified
  end
  if vim.bo.readonly then
    file = file .. ' ' .. config.icons.buffer.read_only
  end
  local path = vim.fs.normalize(vim.fn.expand('%:.:h'))
  if #path == 0 then
    return ''
  end
  path = config.icons.folder .. path

  return highlights.hl_component({ primary = file, secondary = path }, highlights.hls.component, sep, direction)
end

return M
