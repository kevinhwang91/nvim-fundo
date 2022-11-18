---@class FundoFsPath
local Path = {}
local uv = vim.loop

local function normalizeStr(res, str)
    if str == '..' then
        if #res == 0 then
            table.insert(res, '..')
        else
            table.remove(res)
        end
    elseif str ~= '.' and str ~= '' then
        table.insert(res, str)
    end
    return res
end

---
---@param p string
function Path.basename(p)
    assert(type(p) == 'string', 'expected string')
    local i = 1
    while i <= #p do
        local s = p:find(Path.sep, i, true)
        if not s then
            break
        end
        i = s + 1
    end
    return p:sub(i)
end

---
---@param p string
---@return string
function Path.normalize(p)
    assert(type(p) == 'string', 'expected string')
    if p == '' then
        return '.'
    end
    local res = {}
    local i = 1
    local li = 0
    while i <= #p do
        local s = p:find(Path.sep, i, true)
        if not s then
            break
        end
        local lastSect = p:sub(li, s - 1)
        normalizeStr(res, lastSect)
        i = s + 1
        li = i
    end
    normalizeStr(res, p:sub(li))
    return #res == 0 and '.' or table.concat(res, Path.sep)
end

---
---@param ... string
---@return string
function Path.join(...)
    local argc = select('#', ...)
    local res = {}
    for i = 1, argc do
        local sect = select(i, ...)
        normalizeStr(res, sect)
    end
    return #res == 0 and '.' or table.concat(res, Path.sep)
end

local function init()
    Path.sep = uv.os_uname().sysname == 'Windows_NT' and [[\]] or '/'
end

init()

return Path
