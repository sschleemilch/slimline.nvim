local slimline = require('slimline')
local initialized = false

local C = {}

local function init()
    if initialized then
        return
    end
    vim.opt.showmode = false
    initialized = true
end


---@alias ModeConfig {verbose: boolean, hls: table, direction: string, sep: Sep}

--- @param cfg ModeConfig
--- @return string
function C.render(cfg, active)
    init()
    local mode = slimline.get_mode()
    local primary = mode.short
    if cfg.verbose then
        primary = mode.long
    end
    return slimline.highlights.hl_component({ primary = primary }, cfg.hls, cfg.sep, cfg.direction, active)
end

return C
