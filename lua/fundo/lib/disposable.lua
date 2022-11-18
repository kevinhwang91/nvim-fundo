---@class FundoDisposable
---@field func fun()
local Disposable = {}

---
---@param disposables FundoDisposable[]
function Disposable.disposeAll(disposables)
    for _, item in ipairs(disposables) do
        if item.dispose then
            item:dispose()
        end
    end
end

---
---@param func fun()
---@return FundoDisposable
function Disposable:new(func)
    local o = setmetatable({}, self)
    self.__index = self
    o.func = func
    return o
end

---
---@param func fun()
---@return FundoDisposable
function Disposable:create(func)
    return self:new(func)
end

function Disposable:dispose()
    self.func()
end

return Disposable
