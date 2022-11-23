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

---@param path string
---@param bufferSize? number
---@param iterAction fun(entries: table): boolean?
---@return Promise
function FS.openDirStream(path, bufferSize, iterAction)

    return async(function()
        bufferSize = bufferSize or 32
        local dir = await(uvw.opendir(path, bufferSize))
        local entries
        local ok, res = pcall(function()
            repeat
                entries = await(uvw.readdir(dir))
                if await(iterAction(entries)) then
                    break
                end
            until not entries
        end)
        await(uvw.closedir(dir))
        assert(ok, res)
    end)
end

return FS
