local async = require('async')
local uv = vim.loop
local uvw = require('fundo.fs.uvwrapper')

local FS = setmetatable({}, {__index = uvw})

for name in pairs(uvw) do
    FS[name .. 'Sync'] = uv['fs_' .. name]
end

function FS.copyFile(path, newPath)
    return async(function()
        local p = newPath .. '.__'
        await(uvw.copyfile(path, p))
        pcall(await, uvw.rename(p, newPath))
    end)
end

return FS
