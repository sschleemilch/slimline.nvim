local slimline = require('slimline')
local C = {}

local config = slimline.config.configs.path

---@param path string
---@param chars integer
---@param full_dirs integer
---@return string
local function truncate(path, chars, full_dirs)
  local parts = {}
  for part in path:gmatch('[^/]+') do
    table.insert(parts, part)
  end

  local truncated = {}
  local n_parts = #parts

  for i, component in ipairs(parts) do
    if i > (n_parts - full_dirs) then
      table.insert(truncated, component)
    elseif #component > chars then
      table.insert(truncated, component:sub(1, chars))
    else
      table.insert(truncated, component)
    end
  end

  return table.concat(truncated, '/')
end

--- @param sep sep
--- @param direction component.direction
--- @param hls component.highlights
--- @param active boolean
--- @return string
function C.render(sep, direction, hls, active)
  if vim.bo.buftype ~= '' then return '' end

  local file = vim.fn.expand('%:t')

  if vim.bo.modified then file = file .. ' ' .. config.icons.modified end
  if vim.bo.readonly then file = file .. ' ' .. config.icons.read_only end

  local path = ''

  if config.directory == true then
    path = vim.fs.normalize(vim.fn.expand('%:.:h'))
    if #path == 0 then return '' end
    if path == '.' then
      path = ''
    else
      if config.truncate then path = truncate(path, config.truncate.chars, config.truncate.full_dirs) end
      path = config.icons.folder .. path
    end
  end

  return slimline.highlights.hl_component({ primary = file, secondary = path }, hls, sep, direction, active)
end

return C
