local M = {}
local highlights = require('slimline.highlights')
local utils = require('slimline.utils')

--- @param config table
--- @param sep {left: string, right: string}
--- @return string
function M.render(config, sep)
  local mode = utils.get_mode()
  local render = mode
  if config.verbose_mode == false then
    render = string.sub(mode, 1, 1)
  end
  local content = ' ' .. render .. ' '
  return highlights.hl_content(content, highlights.get_mode_hl(mode), sep.left, sep.right)
end

return M
