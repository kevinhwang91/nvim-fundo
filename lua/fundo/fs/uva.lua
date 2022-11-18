---@class FundoFsUvAsync
---@field close fun(string): string
local UVAsync = {}

local uv = vim.loop

local promise = require('promise')

local function wrap2(name)
    return function(a1)
        return promise(function(resolve, reject)
            uv[name](a1, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

local function wrap3(name)
    return function(a1, a2)
        return promise(function(resolve, reject)
            uv[name](a1, a2, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

local function wrap4(name)
    return function(a1, a2, a3)
        return promise(function(resolve, reject)
            uv[name](a1, a2, a3, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

local function wrap5(name)
    return function(a1, a2, a3, a4)
        return promise(function(resolve, reject)
            uv[name](a1, a2, a3, a4, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

UVAsync.close = wrap2('fs_close')
UVAsync.open = wrap4('fs_open')
UVAsync.read = wrap4('fs_read')
UVAsync.unlink = wrap2('fs_unlink')
UVAsync.write = wrap4('fs_write')
UVAsync.mkdir = wrap3('fs_mkdir')
UVAsync.mkdtemp = wrap2('fs_mkdtemp')
UVAsync.mkstemp = wrap2('fs_mkstemp')
UVAsync.rmdir = wrap2('fs_rmdir')
UVAsync.stat = wrap2('fs_stat')
UVAsync.fstat = wrap2('fs_fstat')
UVAsync.lstat = wrap2('fs_lstat')
UVAsync.rename = wrap3('fs_rename')
UVAsync.fsync = wrap2('fs_fsync')
UVAsync.fdatasync = wrap2('fs_fdatasync')
UVAsync.ftruncate = wrap3('fs_ftruncate')
UVAsync.sendfile = wrap5('fs_sendfile')
UVAsync.access = wrap3('fs_access')
UVAsync.chmod = wrap3('fs_chmod')
UVAsync.fchmod = wrap3('fs_fchmod')
UVAsync.utime = wrap4('fs_utime')
UVAsync.futime = wrap4('fs_futime')
UVAsync.lutime = wrap4('fs_lutime')
UVAsync.link = wrap3('fs_link')
UVAsync.symlink = wrap4('fs_symlink')
UVAsync.readlink = wrap2('fs_readlink')
UVAsync.realpath = wrap2('fs_realpath')
UVAsync.chown = wrap4('fs_chown')
UVAsync.fchown = wrap4('fs_fchown')
UVAsync.lchown = wrap4('fs_lchown')
UVAsync.copyfile = wrap4('fs_copyfile')

-- TODO
UVAsync.opendir = function(path, entries)
    return promise(function(resolve, reject)
        uv.fs_opendir(path, function(err, data)
            if err then
                reject(err)
            else
                resolve(data)
            end
        end, entries)
    end)
end

UVAsync.readdir = wrap2('fs_readdir')
UVAsync.closedir = wrap2('fs_closedir')
UVAsync.statfs = wrap2('fs_statfs')

return UVAsync
