local M = {}
local highlights = require('slimline.highlights')

--- @param config table
--- @param sep {left: string, right: string}
--- @return string
function M.render(config, sep)
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ''
  end
  if not status.head or status.head == '' then
    return ''
  end

  local added = status.added and status.added > 0
  local removed = status.removed and status.removed > 0
  local changed = status.changed and status.changed > 0
  local modifications = added or removed or changed

  local branch = string.format(' %s %s ', config.icons.git.branch, status.head)
  branch = highlights.hl_content(branch, highlights.hls.primary.text, sep.left)
  local branch_hl_right_sep = highlights.hls.primary.sep
  if modifications then
    branch_hl_right_sep = highlights.hls.primary.sep_transition
  end
  -- if there are modifications the main part of the git components should have a right side
  -- seperator
  if modifications then
    sep.right = config.sep.right
  end
  branch = branch .. highlights.hl_content(sep.right, branch_hl_right_sep)

  local mods = ''
  if modifications then
    if added then
      mods = mods .. string.format(' +%s', status.added)
    end
    if changed then
      mods = mods .. string.format(' ~%s', status.changed)
    end
    if removed then
      mods = mods .. string.format(' -%s', status.removed)
    end
    mods = highlights.hl_content(mods .. ' ', highlights.hls.secondary.text, nil, sep.right)
  end
  return branch .. mods
end

return M
