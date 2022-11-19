return function(options)
    local busted = require('busted')
    local handler = require('busted.outputHandlers.utfTerminal')(options)

    local promiseUnhandledError = {}

    busted.subscribe({'test', 'end'}, function(element, parent)
        while #promiseUnhandledError > 0 do
            local res = table.remove(promiseUnhandledError, 1)
            handler.successesCount = handler.successesCount - 1
            handler.failuresCount = handler.failuresCount + 1
            busted.publish({'failure', element.descriptor}, element, parent, tostring(res))
        end
    end)

    require('promise').loop.callWrapper = function(callback)
        local ok, res = pcall(callback)
        if ok then
            return
        end
        -- Some tests never handle the rejected promises, We should ignore them.
        local msg = tostring(res)
        if msg:match('^UnhandledPromiseRejection') then
            return
        end
        table.insert(promiseUnhandledError, msg)
    end
    return handler
end
