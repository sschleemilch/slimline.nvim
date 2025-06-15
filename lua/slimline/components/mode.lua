local highlights = require('slimline.highlights')
local utils = require('slimline.utils')
local config = require('slimline').config.configs.mode

local initialized = false
local needs_update = true
local content = ''

local C = {}

local function init()
  if initialized then
    return
  end
  utils.au('ModeChanged', '*', function()
    needs_update = true
  end, 'Watch for mode change')
  vim.o.showmode = false
  initialized = true
end

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @return string
function C.render(sep, direction, hls)
  if not needs_update then
    return content
  end

  init()

  local mode = utils.get_mode()
  local new_content = mode
  if not config.verbose then
    new_content = string.sub(mode, 1, 1)
  end
  content = highlights.hl_component({ primary = new_content }, hls, sep, direction)
  needs_update = false
  return content
end

return C
