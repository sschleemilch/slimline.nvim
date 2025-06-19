local C = {}

--- @param direction string
--- |'"right"'
--- |'"left"'
--- @param hls {primary: {text: string, sep: string, sep2sec?: string}, secondary?: {text: string, sep: string} }
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ''
  end
  if not status.head or status.head == '' then
    return ''
  end

  local icons = Slimline.config.configs['git'].icons

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
  return Slimline.highlights.hl_component(
    { primary = branch, secondary = table.concat(mods, ' ') },
    hls,
    sep,
    direction,
    active
  )
end

return C
