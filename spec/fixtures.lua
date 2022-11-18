local busted = require('busted')

local _done
local co = _G.co

busted.subscribe({'test', 'start'}, function()
    _done = false
end)

local function getDone()
    return _done
end

function _G.done()
    _done = true
    return _done
end

---------------------------------------------------------------------
---Need to implement _G.wait to pass tests

local defaultTimeout = 1000

---Should override this function to customize EventLoop to pass tests
---@param ms? number
---@return boolean
function _G.wait(ms)
    if getDone() then
        return true
    end
    local interval = 5
    local timer = require('luv').new_timer()
    local cnt = 0
    ms = ms or defaultTimeout
    timer:start(interval, interval, function()
        cnt = cnt + interval
        local d = getDone()
        if cnt >= ms or d then
            timer:stop()
            timer:close()
            local thread = coroutine.running()
            if thread ~= co then
                require('spec.helpers.init').setTimeout(function()
                    coroutine.resume(co, d)
                end, 0)
            end
        end
    end)
    return coroutine.yield()
end
