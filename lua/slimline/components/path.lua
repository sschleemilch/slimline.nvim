local C = {}

local highlights = require('slimline.highlights')
local config = require('slimline').config.configs.path

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @return string
function C.render(sep, direction, hls)
  if vim.bo.buftype ~= '' then
    return ''
  end

  local file = vim.fn.expand('%:t')

  if vim.bo.modified then
    file = file .. ' ' .. config.icons.modified
  end
  if vim.bo.readonly then
    file = file .. ' ' .. config.read_only
  end

  local path = nil

  if config.directory == true then
    path = vim.fs.normalize(vim.fn.expand('%:.:h'))
    if #path == 0 then
      return ''
    end
    path = config.icons.folder .. path
  end

  return highlights.hl_component({ primary = file, secondary = path }, hls, sep, direction)
end

return C
