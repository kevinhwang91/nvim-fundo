local async = require('async')
local uva = require('fundo.fs.uva')

local FS = setmetatable({}, {__index = uva})

function FS.copyFile(path, newPath)
    return async(function()
        local p = newPath .. '.__'
        await(uva.copyfile(path, p))
        pcall(await, uva.rename(p, newPath))
    end)
end

return FS
