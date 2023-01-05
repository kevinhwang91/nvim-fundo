local promise = require('promise')

local M = {}

M.setTimeout = promise.loop.setTimeout

function M.delay(ms)
    return promise(function(resolve)
        M.setTimeout(function()
            resolve()
        end, ms)
    end)
end

return M
