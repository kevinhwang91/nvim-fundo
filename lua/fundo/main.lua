local M = {}
local cmd = vim.cmd
local api = vim.api

local disposable = require('fundo.lib.disposable')
local manager    = require('fundo.manager')
local event      = require('fundo.lib.event')

local enabled

---@type FundoDisposable[]
local disposables = {}

local function createEvents()
    local groupId = api.nvim_create_augroup('Fundo', {})
    api.nvim_create_autocmd({'BufReadPost', 'BufWritePost', 'BufWipeout'}, {
        group = groupId,
        callback = function(t) event:emit(t.event, t.buf) end
    })
    api.nvim_create_autocmd('CmdlineEnter', {
        group = groupId,
        pattern = ':',
        callback = function(t) event:emit(t.event, t.file) end
    })
    api.nvim_create_autocmd({'VimLeave', 'VimSuspend', 'TermEnter', 'FocusLost'}, {
        group = groupId,
        callback = function(t) event:emit(t.event) end
    })

    return disposable:create(function()
        api.nvim_del_augroup_by_id(groupId)
    end)
end

local function createCommand()
    cmd([[
        com! FundoEnable lua require('fundo').enable()
        com! FundoDisable lua require('fundo').disable()
    ]])
end

function M.enable()
    if enabled then
        return false
    end
    createCommand()
    disposables = {}
    table.insert(disposables, createEvents())
    table.insert(disposables, manager:initialize())
    enabled = true
    return true
end

function M.disable()
    if not enabled then
        return false
    end
    disposable.disposeAll(disposables)
    enabled = false
    return true
end

return M
