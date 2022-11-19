package.path = os.getenv('PWD') .. '/lua/?.lua;' .. package.path

require('busted.compatibility').exit = function(code)
    vim.schedule(function()
        vim.cmd(('cq %d'):format(code))
    end)
end

_G.arg = vim.fn.argv()
_G.print = function(...)
    local argv = {...}
    for i = 1, #argv do
        argv[i] = tostring(argv[i])
    end
    table.insert(argv, '\n')
    io.write(unpack(argv))
end

require('busted.runner')({standalone = false, output = 'spec.outputHandler'})
vim.cmd('cq 0')
