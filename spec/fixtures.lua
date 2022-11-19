local _done
local defaultTimeout = 1000

require('busted').subscribe({'test', 'start'}, function()
    _done = false
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
---@return boolean
function _G.wait(ms)
    print(getDone())
    if getDone() then
        return true
    end
    local interval = 20
    ms = ms or defaultTimeout
    local ret = vim.wait(ms, getDone, interval, false)
    return ret
end
