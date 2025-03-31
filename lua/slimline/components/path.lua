local M = {}

local name = 'path'
local highlights = require('slimline.highlights')
local config = require('slimline').config

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls table
--- @return string
function M.render(sep, direction, hls)
  if vim.bo.buftype ~= '' then
    return ''
  end
  local file = vim.fn.expand('%:t')

  local icons = config.configs[name].icons

  if vim.bo.modified then
    file = file .. ' ' .. icons.modified
  end
  if vim.bo.readonly then
    file = file .. ' ' .. icons.read_only
  end

  local path = nil

  if config.configs.path.directory == true then
    path = vim.fs.normalize(vim.fn.expand('%:.:h'))
    if #path == 0 then
      return ''
    end
    path = icons.folder .. path
  end

  return highlights.hl_component({ primary = file, secondary = path }, hls, sep, direction)
end

return M
