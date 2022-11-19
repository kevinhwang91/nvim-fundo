local async = require('async')

local M = {}

local function wrapper(assertTrue, status, ...)
    assertTrue(status)
    return ...
end
function M.asyncWrapper(f )
    return async(function ()
        return await(f)
    end)
    -- return wrapper(pcall(f))
end

return M
