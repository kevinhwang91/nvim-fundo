local fn = vim.fn
local uv = vim.loop

local event = require('fundo.lib.event')
local disposable = require('fundo.lib.disposable')
local promise = require('promise')
local utils = require('fundo.utils')
local undo = require('fundo.model.undo')
local async = require('async')
local config = require('fundo.config')
local fs = require('fundo.fs')
local log = require('fundo.lib.log')
local path = require('fundo.fs.path')
local mutex = require('fundo.lib.mutex')

---@class FundoManager
---@field initialized boolean
---@field undos table<number, FundoUndo>
---@field lastScannedtime number
---@field mutex FundoMutex
---@field disposables FundoDisposable[]
local Manager = {}

function Manager:attach(bufnr)
    if not self.undos[bufnr] then
        local u = undo:new(bufnr, self.archivesDir)
        if u:attach() then
            self.undos[bufnr] = u
        end
    end
    return self.undos[bufnr]
end

function Manager:listFileStats(dir, bufferSize)
    return async(function()
        local tasks = {}
        await(fs.openDirStream(dir, bufferSize, function(entries)
            if not entries then
                return
            end
            for _, entry in ipairs(entries) do
                if entry.type == 'file' then
                    local name = entry.name
                    tasks[name] = fs.stat(path.join(dir, name))
                end
            end
        end))
        return promise.all(tasks)
    end)
end

function Manager:scanArchivesDir()
    return async(function()
        local statTbl = await(self:listFileStats(self.archivesDir, 1024))
        local stats = {}
        for name, stat in pairs(statTbl) do
            table.insert(stats, {name = name, mtime = stat.mtime.sec, size = stat.size})
        end
        table.sort(stats, function(a, b)
            return a.mtime > b.mtime
        end)
        local size = 0
        local limit = self.limitArchivesSize * 1024 * 1024
        local tasks = {}
        for _, stat in ipairs(stats) do
            if size > limit then
                local p = path.join(self.archivesDir, stat.name)
                log.debug(p, 'will be removed.')
                table.insert(tasks, fs.unlink(p))
            end
            size = size + stat.size
        end
        return promise.all(tasks)
    end)
end

function Manager:syncAll(block)
    return self.mutex:use(function()
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
            local now = uv.hrtime()
            if block then
                vim.wait(1000, function()
                    return res
                end, 30, false)
                log.debug(('has elaspsed %dms'):format((uv.hrtime() - now) / 1e6))
            end
            local results = await(p)
            log.debug('results:', results)
            -- 60 * 60 * 1e9 ns = 1 hour
            if not block and now - self.lastScannedtime > 60 * 60 * 1e9 then
                self.lastScannedtime = now
                await(self:scanArchivesDir())
            end
            res = true
        end)
    end)
end

function Manager:initialize()
    if self.initialized then
        return self
    end
    self.initialized = true
    self.archivesDir = path.normalize(config.archives_dir)
    self.limitArchivesSize = config.limit_archives_size
    -- convert 0o755 to decimal base
    fs.mkdirSync(self.archivesDir, 493)
    self.undos = {}
    self.lastScannedtime = 0
    self.mutex = mutex:new()
    self.disposables = {}
    table.insert(self.disposables, disposable:create(function()
        for _, b in pairs(self.undos) do
            b:dispose()
        end
        self.initialized = false
        self.undos = {}
        self.lastScannedtime = 0
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
            u:reset(true)
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
    end, self.disposables)
    event:on('VimLeave', function() self:syncAll(true) end, self.disposables)
    event:on('VimSuspend', function() self:syncAll(true) end, self.disposables)
    event:on('TermEnter', function() self:syncAll() end, self.disposables)
    event:on('FocusLost', function() self:syncAll() end, self.disposables)
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
