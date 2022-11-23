local uv = vim.loop
local promise = require('promise')

---@class FundoFsUvWrapper
local UVWrapper = {}


local function assign2(name)
    UVWrapper[name] = function(a1)
        return promise(function(resolve, reject)
            uv['fs_' .. name](a1, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

local function assign3(name)
    UVWrapper[name] = function(a1, a2)
        return promise(function(resolve, reject)
            uv['fs_' .. name](a1, a2, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

local function assign4(name)
    UVWrapper[name] = function(a1, a2, a3)
        return promise(function(resolve, reject)
            uv['fs_' .. name](a1, a2, a3, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

local function assign5(name)
    UVWrapper[name] = function(a1, a2, a3, a4)
        return promise(function(resolve, reject)
            uv['fs_' .. name](a1, a2, a3, a4, function(err, data)
                if err then reject(err) else resolve(data) end
            end)
        end)
    end
end

---@diagnostic disable unused-local
--
---@param fd number
---@return Promise
function UVWrapper.close(fd) end

---@param fd number
---@return boolean
function UVWrapper.closeAsync(fd) end

---@param path string
---@param flags string|number
---@param mode number
---@return Promise
function UVWrapper.open(path, flags, mode) end

---@param path string
---@param flags string|number
---@param mode number
---@return number
function UVWrapper.openSync(path, flags, mode) end

---@param fd number
---@param size number
---@param offset? number
---@return Promise
function UVWrapper.read(fd, size, offset) end

---@param fd number
---@param size number
---@param offset? number
---@return string
function UVWrapper.readSync(fd, size, offset) end

---@param path string
---@return Promise
function UVWrapper.unlink(path) end

---@param path string
---@return boolean
function UVWrapper.unlinkSync(path) end

---@param fd number
---@param data string
---@param offset? number
---@return Promise
function UVWrapper.write(fd, data, offset) end

---@param fd number
---@param data string
---@param offset? number
---@return number
function UVWrapper.writeSync(fd, data, offset) end

---@param path string
---@param mode number
---@return Promise
function UVWrapper.mkdir(path, mode) end

---@param path string
---@param mode number
---@return boolean
function UVWrapper.mkdirSync(path, mode) end

---@param template string
---@return Promise
function UVWrapper.mkdtemp(template) end

---@param template string
---@return string
function UVWrapper.mkdtempSync(template) end

---@param template string
---@return Promise
function UVWrapper.mkstemp(template) end

---@param template string
---@return number|string
function UVWrapper.mkstempSync(template) end

---@param path string
---@return Promise
function UVWrapper.rmdir(path) end

---@param path string
---@return boolean
function UVWrapper.rmdirSync(path) end

---@param path string
---@return Promise
function UVWrapper.stat(path) end

---@param path string
---@return table
function UVWrapper.statSync(path) end

---@param fd number
---@return Promise
function UVWrapper.fstat(fd) end

---@param fd number
---@return table
function UVWrapper.fstatSync(fd) end

---@param path string
---@return Promise
function UVWrapper.lstat(path) end

---@param path string
---@return table
function UVWrapper.lstatSync(path) end

---@param path string
---@param newPath string
---@return Promise
function UVWrapper.rename(path, newPath) end

---@param path string
---@param newPath string
---@return boolean
function UVWrapper.renameSync(path, newPath) end

---@param fd number
---@return Promise
function UVWrapper.fsync(fd) end

---@param fd number
---@return boolean
function UVWrapper.fsyncSync(fd) end

---@param fd number
---@return Promise
function UVWrapper.fdatasync(fd) end

---@param fd number
---@return boolean
function UVWrapper.fdatasyncSync(fd) end

---@param fd number
---@param offset number
---@return Promise
function UVWrapper.ftruncate(fd, offset) end

---@param fd number
---@param offset number
---@return boolean
function UVWrapper.ftruncateSync(fd, offset) end

---@param outFd number
---@param inFd number
---@param inOffset number
---@param size number
---@return Promise
function UVWrapper.sendfile(outFd, inFd, inOffset, size) end

---@param outFd number
---@param inFd number
---@param inOffset number
---@param size number
---@return number
function UVWrapper.sendfileSync(outFd, inFd, inOffset, size) end

---@param path string
---@param mode number
---@return Promise
function UVWrapper.access(path, mode) end

---@param path string
---@param mode number
---@return boolean
function UVWrapper.accessSync(path, mode) end

---@param path string
---@param mode number
---@return Promise
function UVWrapper.chmod(path, mode) end

---@param path string
---@param mode number
---@return boolean
function UVWrapper.chmodSync(path, mode) end

---@param path string
---@param atime number
---@param mtime number
---@return Promise
function UVWrapper.utime(path, atime, mtime) end

---@param path string
---@param atime number
---@param mtime number
---@return boolean
function UVWrapper.utimeSync(path, atime, mtime) end

---@param path string
---@param atime number
---@param mtime number
---@return Promise
function UVWrapper.futime(path, atime, mtime) end

---@param path string
---@param atime number
---@param mtime number
---@return boolean
function UVWrapper.futimeSync(path, atime, mtime) end

---@param path string
---@param atime number
---@param mtime number
---@return Promise
function UVWrapper.lutime(path, atime, mtime) end

---@param path string
---@param atime number
---@param mtime number
---@return boolean
function UVWrapper.lutimeSync(path, atime, mtime) end

---@param path string
---@param newPath string
---@return Promise
function UVWrapper.link(path, newPath) end

---@param path string
---@param newPath string
---@return boolean
function UVWrapper.linkSync(path, newPath) end

---@param path string
---@param newPath string
---@param flags? table|number
---@return Promise
function UVWrapper.symlink(path, newPath, flags) end

---@param path string
---@param newPath string
---@param flags? table|number
---@return boolean
function UVWrapper.symlinkSync(path, newPath, flags) end

---@param path string
---@return Promise
function UVWrapper.readlink(path) end

---@param path string
---@return string
function UVWrapper.readlinkSync(path) end

---@param path string
---@return Promise
function UVWrapper.realpath(path) end

---@param path string
---@return string
function UVWrapper.realpathSync(path) end

---@param path string
---@param uid number
---@param gid number
---@return Promise
function UVWrapper.chown(path, uid, gid) end

---@param path string
---@param uid number
---@param gid number
---@return boolean
function UVWrapper.chownSync(path, uid, gid) end

---@param path string
---@param uid number
---@param gid number
---@return Promise
function UVWrapper.fchown(path, uid, gid) end

---@param path string
---@param uid number
---@param gid number
---@return boolean
function UVWrapper.fchownSync(path, uid, gid) end

---@param path string
---@param uid number
---@param gid number
---@return Promise
function UVWrapper.lchown(path, uid, gid) end

---@param path string
---@param uid number
---@param gid number
---@return boolean
function UVWrapper.lchownSync(path, uid, gid) end

---@param path string
---@param newPath string
---@param flags? table|number
---@return Promise
function UVWrapper.copyfile(path, newPath, flags) end

---@param path string
---@param newPath string
---@param flags? table|number
---@return boolean
function UVWrapper.copyfileSync(path, newPath, flags) end

---@param path string
---@param entries number
---@return Promise
function UVWrapper.opendir(path, entries) end

---@param path string
---@param entries number
---@return userdata
function UVWrapper.opendirSync(path, entries) end

---@param dir userdata
---@return Promise
function UVWrapper.readdir(dir) end

---@param dir userdata
---@return table
function UVWrapper.readdirSync(dir) end

---@param dir userdata
---@return Promise
function UVWrapper.closedir(dir) end

---@param dir userdata
---@return table
function UVWrapper.closedirSync(dir) end

---@param path string
---@return Promise
function UVWrapper.statfs(path) end

---@param path string
---@return table
function UVWrapper.statfsSync(path) end

---@diagnostic enable unused-local

assign2('close')
assign4('open')
assign4('read')
assign2('unlink')
assign4('write')
assign3('mkdir')
assign2('mkdtemp')
assign2('mkstemp')
assign2('rmdir')
assign2('stat')
assign2('fstat')
assign2('lstat')
assign3('rename')
assign2('fsync')
assign2('fdatasync')
assign3('ftruncate')
assign5('sendfile')
assign3('access')
assign3('chmod')
assign3('fchmod')
assign4('utime')
assign4('futime')
assign4('lutime')
assign3('link')
assign4('symlink')
assign2('readlink')
assign2('realpath')
assign4('chown')
assign4('fchown')
assign4('lchown')
assign4('copyfile')

-- TODO
---@diagnostic disable-next-line: duplicate-set-field
UVWrapper.opendir = function(path, entries)
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

assign2('readdir')
assign2('closedir')
assign2('statfs')

for name in pairs(UVWrapper) do
    UVWrapper[name .. 'Sync'] = uv['fs_' .. name]
end

return UVWrapper
