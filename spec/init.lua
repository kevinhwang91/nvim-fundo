package.path = os.getenv('PWD') .. '/lua/?.lua;' .. package.path

local co = coroutine.create(function()
    require('busted.runner')({standalone = false, output = 'spec.outputHandler'})
    -- no errors
    vim.schedule(function()
        vim.cmd('cq 0')
    end)
end)

_G.co = co

require('busted.compatibility').exit = function(code)
    vim.schedule(function()
        vim.cmd(('cq %d'):format(code))
    end)
end

_G.print = function(...)
    local argv = {...}
    for i = 1, #argv do
        argv[i] = tostring(argv[i])
    end
    table.insert(argv, '\n')
    io.write(unpack(argv))
end
coroutine.resume(co)
