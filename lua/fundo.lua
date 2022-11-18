local M = {}

---Enable fundo
function M.enable()
    require('fundo.main').enable()
end

---Disable fundo
function M.disable()
    require('fundo.main').disable()
end

---Setup configuration and enable fundo
---@param opts? FundoConfig
function M.setup(opts)
    opts = opts or {}
    M._config = opts
    M.enable()
end

---Reserved
function M.install()
end

return M
