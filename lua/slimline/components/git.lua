local M = {}
local highlights = require('slimline.highlights')
local config = require('slimline').config
local name = 'git'

--- @param sep {left: string, right: string}
--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls table
--- @return string
function M.render(sep, direction, hls)
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ''
  end
  if not status.head or status.head == '' then
    return ''
  end

  local icons = config.configs[name].icons

  local branch = string.format('%s %s', icons.branch, status.head)

  local added = status.added and status.added > 0
  local removed = status.removed and status.removed > 0
  local changed = status.changed and status.changed > 0
  local modifications = added or removed or changed

  local mods = {}
  if modifications then
    if added then
      table.insert(mods, string.format('%s%s', icons.added, status.added))
    end
    if changed then
      table.insert(mods, string.format('%s%s', icons.modified, status.changed))
    end
    if removed then
      table.insert(mods, string.format('%s%s', icons.removed, status.removed))
    end
  end
  return highlights.hl_component({ primary = branch, secondary = table.concat(mods, ' ') }, hls, sep, direction)
end

return M
