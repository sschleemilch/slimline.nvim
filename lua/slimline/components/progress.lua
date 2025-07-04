local slimline = require('slimline')
local C = {}

--- @param cfg table
--- @param active boolean
--- @return string
function C.render(cfg, active)
    local cur = vim.fn.line('.')
    local total = vim.fn.line('$')
    local primary
    if cur == 1 then
        primary = 'Top'
    elseif cur == total then
        primary = 'Bot'
    else
        primary = string.format('%2d%%%%', math.floor(cur / total * 100))
    end

    local secondary = ''

    if cfg.column then
        local col = vim.fn.col('.')
        secondary = string.format('%3d', col)
    end

    primary = string.format('%s %s / %s', cfg.icon, primary, total)

    return slimline.highlights.hl_component({ primary = primary, secondary = secondary }, cfg.hls, cfg.sep, cfg
        .direction, active)
end

return C
