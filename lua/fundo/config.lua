local path = require('fundo.fs.path')

---@class FundoConfig
local def = {
    archives_dir = vim.fn.stdpath('cache') .. path.sep .. 'fundo',
    limit_archives_size = 512
}

---@type FundoConfig
local Config = {}

local function init()
    local fundo = require('fundo')
    ---@type FundoConfig
    Config = vim.tbl_deep_extend('keep', fundo._config or {}, def)
    vim.validate({
        archives_dir = {Config.archives_dir, 'string'},
        limit_archives_size = {Config.limit_archives_size, 'number'}
    })
    Config.archives_dir = vim.fn.expand(Config.archives_dir)
    fundo._config = nil
end

init()

return Config
