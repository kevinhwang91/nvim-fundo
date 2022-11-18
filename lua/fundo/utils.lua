---@class FundoUtils
local M = {}
local api = vim.api
local fn = vim.fn
local uv = vim.loop

---
---@return fun(): boolean
M.has08 = (function()
    local has08
    return function()
        if has08 == nil then
            has08 = fn.has('nvim-0.8') == 1
        end
        return has08
    end
end)()

---@return fun(): boolean
M.isWindows = (function()
    local isWin
    return function()
        if isWin == nil then
            isWin = uv.os_uname().sysname == 'Windows_NT'
        end
        return isWin
    end
end)()

---
---@return string
function M.mode()
    return api.nvim_get_mode().mode
end

---
---@param bufnr number
---@return number, number[]?
function M.getWinByBuf(bufnr)
    local curBufnr
    if not bufnr then
        curBufnr = api.nvim_get_current_buf()
        bufnr = curBufnr
    end
    local winids = {}
    for _, winid in ipairs(api.nvim_list_wins()) do
        if bufnr == api.nvim_win_get_buf(winid) then
            table.insert(winids, winid)
        end
    end
    if #winids == 0 then
        return -1
    elseif #winids == 1 then
        return winids[1]
    else
        if not curBufnr then
            curBufnr = api.nvim_get_current_buf()
        end
        local winid = curBufnr == bufnr and api.nvim_get_current_win() or winids[1]
        return winid, winids
    end
end

---
---@param bufnr number
---@param f fun(): any
---@return any
function M.bufCall(bufnr, f)
    if bufnr == 0 or bufnr == api.nvim_get_current_buf() then
        return f()
    else
        return api.nvim_buf_call(bufnr, f)
    end
end

---
---@param winid number
---@param f fun(): any
---@return any
function M.winCall(winid, f)
    if winid == 0 or winid == api.nvim_get_current_win() then
        return f()
    else
        return api.nvim_win_call(winid, f)
    end
end

---@param ms number
---@return Promise
function M.wait(ms)
    return require('promise')(function(resolve)
        local timer = uv.new_timer()
        timer:start(ms, 0, function()
            timer:close()
            resolve()
        end)
    end)
end

---
---@param callback function
---@param ms number
---@return userdata
function M.setTimeout(callback, ms)
    ---@type userdata
    local timer = uv.new_timer()
    timer:start(ms, 0, function()
        timer:close()
        callback()
    end)
    return timer
end

---
---@param bufnr number
---@param name? string
---@param off? number
---@return boolean
function M.isUnNameBuf(bufnr, name, off)
    name = name or api.nvim_buf_get_name(bufnr)
    off = off or api.nvim_buf_get_offset(bufnr, 1)
    return name == '' and off <= 0
end

---
---@param winid number
---@return table<string, number>
function M.getWinInfo(winid)
    local winfos = fn.getwininfo(winid)
    assert(type(winfos) == 'table' and #winfos == 1,
           '`getwininfo` expected 1 table with single element.')
    return winfos[1]
end

---
---@param winid number
---@return boolean
function M.isWinValid(winid)
    return type(winid) == 'number' and winid > 0 and api.nvim_win_is_valid(winid)
end

---
---@param bufnr number
---@return boolean
function M.isBufLoaded(bufnr)
    return type(bufnr) == 'number' and bufnr > 0 and api.nvim_buf_is_loaded(bufnr)
end

---
---@param winid number
---@return table
function M.saveView(winid)
    return M.winCall(winid, fn.winsaveview)
end

---
---@param winid number
---@param view table
function M.restView(winid, view)
    M.winCall(winid, function()
        fn.winrestview(view)
    end)
end

return M
