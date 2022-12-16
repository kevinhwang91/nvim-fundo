---Respect to NodeJS path module
---@class FundoFsPath
local Path = {}

local utils = require('fundo.utils')
local isWindows
local unixSep, windowSep

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
---@param suffix? string An optional suffix to remove
function Path.basename(p, suffix)
    assert(type(p) == 'string', 'expected string')
    if suffix then
        assert(type(suffix) == 'string', 'expected string')
    end
    local i = 1
    while i <= #p do
        local s = p:find(Path.sep, i, true)
        if not s then
            break
        end
        i = s + 1
    end
    if suffix then
        local s, e = p:find(suffix, i, true)
        p = (s and s > i and e == #p) and p:sub(i, s - 1) or p:sub(i)
    else
        p = p:sub(i)
    end
    return p
end

---@param p string
function Path.dirname(p)
    assert(type(p) == 'string', 'expected string')
    if p == Path.sep then
        return Path.sep
    end
    local ls = 1
    while ls <= #p do
        local s = p:find(Path.sep, ls + 1, true)
        if not s then
            break
        end
        ls = s
    end
    return ls > 1 and p:sub(1, ls - 1) or '.'
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
    local firstIsSep = false
    while i <= #p do
        local s = p:find(Path.sep, i, true)
        if not s then
            break
        end
        if s == 1 then
            firstIsSep = true
        else
            normalizeStr(res, p:sub(li, s - 1))
        end
        i = s + 1
        li = i
    end
    local lastIsSep = i > #p
    normalizeStr(res, p:sub(li))
    if #res == 0 then
        return '.'
    end
    p = table.concat(res, Path.sep)
    if firstIsSep then
        p = Path.sep .. p
    end
    if lastIsSep then
        p = p .. Path.sep
    end
    return p
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
    unixSep, windowSep = '/', [[\]]
    isWindows = utils.isWindows()
    Path.sep = isWindows and windowSep or unixSep
end

init()

return Path
