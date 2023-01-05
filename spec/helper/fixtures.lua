local _done
local defaultTimeout = 1000
local promise = require('promise')
local busted = require('busted')
busted.subscribe({'suite', 'start'}, function()
    vim.env.TMPDIR = vim.env.TMPDIR or '/tmp/fundo'
end)
busted.subscribe({'test', 'start'}, function()
    _done = false
end)
busted.subscribe({'suite', 'end'}, function()
end)

local function getDone()
    return _done
end

---@return boolean
function _G.done()
    _done = true
    return _done
end

---@param ms? number
---@return boolean, string
function _G.wait(ms)
    local ok, res
    if getDone() then
        return true, res
    end
    local interval = 20
    ms = ms or defaultTimeout
    local callWrapper = promise.loop.callWrapper
    ---@diagnostic disable-next-line: duplicate-set-field
    promise.loop.callWrapper = function(callback)
        ok, res = pcall(callback)
        if not ok then
            if type(res) == 'table' and res.err then
                res = res.err
            end
            done()
        end
    end
    local ret = vim.wait(ms, getDone, interval, false)
    ret = ret and ok
    promise.loop.callWrapper = callWrapper
    return ret, res
end
