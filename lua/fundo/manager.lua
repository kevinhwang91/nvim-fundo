local api = vim.api
local fn = vim.fn
local uv = vim.loop

local event      = require('fundo.lib.event')
local disposable = require('fundo.lib.disposable')
local promise    = require('promise')
local utils      = require('fundo.utils')
local undo       = require('fundo.model.undo')
local async      = require('async')
local config     = require('fundo.config')
local log        = require('fundo.lib.log')

---@class FundoManager
---@field initialized boolean
---@field undos table<number, FundoUndo>
---@field disposables FundoDisposable[]
local Manager = {}

function Manager:attach(bufnr)
    if not self.undos[bufnr] then
        local u = undo:new(bufnr, self.achieveDir)
        if u:attach() then
            self.undos[bufnr] = u
        end
    end
    return self.undos[bufnr]
end

function Manager:syncAll(block)
    return async(function()
        local tasks = {}
        for bufnr, u in pairs(self.undos) do
            if u:shouldTransfer() then
                tasks[bufnr] = u:transfer()
            end
        end
        if vim.tbl_isempty(tasks) then
            return
        end
        local res = false
        local p = promise.allSettled(tasks):thenCall(function(value)
            res = true
            return value
        end)
        if block then
            local now = uv.hrtime()
            vim.wait(1000, function()
                return res
            end, 30, false)
            log.debug('has elaspsed %dms', (uv.hrtime() - now) / 1e6)
        end
        local stats = await(p)
        log.debug('stats:', stats)
        res = true
    end)
end

function Manager:initialize()
    if self.initialized then
        return self
    end
    self.initialized = true
    self.achieveDir = config.archives_dir
    fn.mkdir(self.achieveDir, 'p')
    self.undos = {}
    self.disposables = {}
    table.insert(self.disposables, disposable:create(function()
        for _, b in pairs(self.undos) do
            b:dispose()
        end
        self.initialized = false
        self.undos = {}
    end))
    event:on('BufReadPost', function(bufnr)
        local u = self:attach(bufnr)
        if u then
            u:check()
        end
    end, self.disposables)
    event:on('BufWritePost', function(bufnr)
        local u = self.undos[bufnr]
        if u then
            u:reset()
        end
    end, self.disposables)
    event:on('BufWipeout', function(bufnr)
        local u = self.undos[bufnr]
        if u then
            u:dispose()
            self.undos[bufnr] = nil
        end
    end, self.disposables)
    event:on('CmdlineEnter', function(char)
        if char ~= ':' then
            return
        end
        promise.resolve():thenCall(function()
            if utils.mode() == 'c' and fn.getcmdtype() == ':' then
                self:syncAll()
            end
        end)
    end)
    event:on('VimLeave', function() self:syncAll(true) end)
    event:on('VimSuspend', function() self:syncAll(true) end)
    event:on('TermEnter', function() self:syncAll() end)
    event:on('FocusLost', function() self:syncAll() end)

    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if utils.isBufLoaded(bufnr) then
            self:attach(bufnr)
        else
            -- the first buffer is unloaded while firing `BufEnter`
            promise.resolve():thenCall(function()
                if utils.isBufLoaded(bufnr) then
                    self:attach(bufnr)
                end
            end)
        end
    end
    return self
end

---
---@param bufnr number
---@return FundoUndo
function Manager:get(bufnr)
    return self.undos[bufnr]
end

function Manager:dispose()
    disposable.disposeAll(self.disposables)
    self.disposables = {}
end

return Manager
