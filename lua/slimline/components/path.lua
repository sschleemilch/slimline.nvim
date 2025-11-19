local slimline = require('slimline')
local C = {}
local config = slimline.config.configs.path

local cache = {}

local function truncate(path, chars, full_dirs)
  local parts = vim.split(path, '/', { trimempty = true })

  local truncated = {}
  local n_parts = #parts

  for i, component in ipairs(parts) do
    if i > (n_parts - full_dirs) then
      table.insert(truncated, component)
    else
      local len = #component
      if len > chars then
        table.insert(truncated, component:sub(1, chars))
      else
        table.insert(truncated, component)
      end
    end
  end

  local result = table.concat(truncated, '/')
  return result
end

---@param opts render.options
---@return string
function C.render(opts)
  if vim.bo.buftype ~= '' then return '' end

  local full_path = vim.fn.expand('%:p')
  local mod = vim.bo.modified
  local ro = vim.bo.readonly
  local key = full_path .. (opts.active and '+' or '') .. (mod and '*' or '') .. (ro and '!' or '')

  if cache[key] then return cache[key] end

  local file = vim.fn.expand('%:t')

  if mod then file = file .. ' ' .. config.icons.modified end
  if ro then file = file .. ' ' .. config.icons.read_only end

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

  local result = slimline.highlights.hl_component(
    { primary = file, secondary = path },
    opts.hls,
    opts.sep,
    opts.direction,
    opts.active,
    opts.style
  )
  cache[key] = result
  return result
end

return C
