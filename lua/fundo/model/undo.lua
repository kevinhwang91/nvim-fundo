local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

local async = require('async')
local path = require('fundo.fs.path')
local fs = require('fundo.fs')
local utils = require('fundo.utils')

---@class FundoUndo
---@field private nothingMsg string
---@field dir string
---@field bufnr number
---@field attached boolean
local Undo = {
    nothingMsg = 'Nothing to undo'
}

function Undo:new(bufnr, dir)
    local o = setmetatable({}, self)
    self.__index = self
    o.bufnr = bufnr
    o.dir = dir
    return o
end

function Undo:attach()
    local bt = vim.bo[self.bufnr].bt
    local name = api.nvim_buf_get_name(self.bufnr)
    if path.dirname(name) == self.dir then
        vim.bo[self.bufnr].undofile = false
    end
    self.attached = (bt == '' or bt == 'acwrite') and vim.bo[self.bufnr].undofile
    if self.attached then
        self:reset()
    end
    return self.attached
end

function Undo:dispose()
    self.attached = false
end

---
---@param dirty? boolean
---@param bufName? string
function Undo:reset(dirty, bufName)
    if not self.attached then
        return
    end
    local name = bufName or api.nvim_buf_get_name(self.bufnr)
    if name ~= self.name then
        self.undoPath = fn.undofile(name)
        local basename = path.basename(self.undoPath)
        self.fallbackPath = path.join(self.dir, basename)
    end
    self.name = name
    self.isDirty = dirty and self.undoPath ~= '' and vim.bo[self.bufnr].undolevels ~= 0
end

function Undo:isEmpty()
    local res = utils.bufCall(self.bufnr, function()
        return api.nvim_exec('undolist', true)
    end)
    return res:sub(1, #self.nothingMsg) == self.nothingMsg
end

function Undo:loadUndo()
    return utils.bufCall(self.bufnr, function()
        return pcall(cmd, 'sil rundo ' .. fn.fnameescape(self.undoPath))
    end)
end

function Undo:loadFileAndUndo(winid)
    local view
    if winid then
        view = utils.saveView(winid)
    end

    local ei = vim.o.eventignore
    vim.o.eventignore = 'all'
    pcall(function()
        local modified = vim.bo[self.bufnr].modified
        local lines = api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
        utils.bufCall(self.bufnr, function()
            cmd(([[
                keepalt sil %dread %s
                sil 1,%ddelete_
            ]]):format(#lines, fn.fnameescape(self.fallbackPath), #lines))
        end)
        self:loadUndo()
        api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
        vim.bo[self.bufnr].modified = modified

        if winid then
            utils.restView(winid, view)
        end
    end)
    vim.o.eventignore = ei
end

function Undo:loadFallBack()
    if not fs.statSync(self.fallbackPath) then
        return
    end
    local preferredWinid, winids = utils.getWinByBuf(self.bufnr)
    if preferredWinid == -1 then
        self:loadFileAndUndo()
    elseif winids then
        for _, winid in ipairs(winids) do
            self:loadFileAndUndo(winid)
        end
    else
        self:loadFileAndUndo(preferredWinid)
    end
end

function Undo:shouldTransfer()
    return self.attached and self.isDirty
end

function Undo:transfer()
    return async(function()
        if not self:shouldTransfer() then
            return
        end
        local stat = await(fs.stat(self.undoPath))
        if stat then
            await(fs.copyFile(self.name, self.fallbackPath))
        end
        self.isDirty = false
    end)
end

function Undo:check()
    if not self.attached then
        return
    end
    if self:isEmpty() then
        self:loadFallBack()
    end
end

return Undo
