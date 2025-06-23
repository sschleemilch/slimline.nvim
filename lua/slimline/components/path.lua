local slimline = require('slimline')
local C = {}

local config = slimline.config.configs.path

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  if vim.bo.buftype ~= '' then
    return ''
  end

  local file = vim.fn.expand('%:t')

  if vim.bo.modified then
    file = file .. ' ' .. config.icons.modified
  end
  if vim.bo.readonly then
    file = file .. ' ' .. config.icons.read_only
  end

  local path = ''

  if config.directory == true then
    path = vim.fs.normalize(vim.fn.expand('%:.:h'))
    if #path == 0 then
      return ''
    end
    if path == '.' then
      path = ''
    else
      path = config.icons.folder .. path
    end
  end

  return slimline.highlights.hl_component({ primary = file, secondary = path }, hls, sep, direction, active)
end

return C
