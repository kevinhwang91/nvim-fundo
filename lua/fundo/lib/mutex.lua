local Semaphore = require('fundo.lib.semaphore')

---@class FundoMutex: FundoSemaphore
local Mutex = {}

function Mutex:new()
    return Semaphore:new(1)
end

return Mutex
