local helper    = require('spec.helper.init')
local promise   = require('promise')
local async     = require('async')
local semaphore = require('fundo.lib.semaphore')
local mutex     = require('fundo.lib.mutex')

describe('semaphore.', function()
    it('limit concurrency', function()
        local s = semaphore:new(2)
        local running = 0
        local ran = 0
        local function task()
            return async(function()
                local release = await(s:acquire())
                assert(running <= 1)
                running = running + 1
                await(helper.delay(10))
                assert(running <= 2)
                running = running - 1
                ran = ran + 1
                release()
            end)
        end

        async(function()
            local tasks = {}
            for _ = 1, 5 do
                table.insert(tasks, task())
            end
            await(promise.all(tasks))
            done()
        end)
        assert.True(wait())
    end)

    it('limits concurrency (use syntax)', function()
        local s = semaphore:new(2)
        local running = 0
        local ran = 0
        local function task()
            return async(function()
                assert(running <= 1)
                running = running + 1
                await(helper.delay(10))
                assert(running <= 2)
                running = running - 1
                ran = ran + 1
            end)
        end

        async(function()
            local tasks = {}
            for _ = 1, 5 do
                table.insert(tasks, s:use(task))
            end
            await(promise.all(tasks))
            done()
        end)
        assert.True(wait())
    end)

    it('use recovers from thrown exception', function()
        local s = semaphore:new(2)
        local running = 0
        local ran = 0
        local erred = 0
        local function generateTask(i)
            return function()
                return async(function()
                    assert(running <= 1)
                    running = running + 1
                    await(helper.delay(10))
                    assert(running <= 2)
                    running = running - 1
                    if i == 2 then
                        error('bomb!')
                    end
                    ran = ran + 1
                end)
            end
        end

        async(function()
            await(s:use(generateTask(1)))
            if not pcall(await, s:use(generateTask(2))) then
                erred = erred + 1
            end
            await(s:use(generateTask(3)))
            await(s:use(generateTask(4)))
            await(s:use(generateTask(5)))
            assert.equal(4, ran)
            assert.equal(1, erred)
            assert.equal(2, s.count)
            done()
        end)
        assert.True(wait())
    end)
end)

describe('mutex.', function()
    it('tasks do nt overlap', function()
        local m = mutex:new()
        local running1 = false
        local running2 = false
        local ran1 = false
        local ran2 = false
        promise.all({
                m:acquire():thenCall(function(release)
                    running1 = true
                    ran1 = true
                    return helper.delay(10):thenCall(function()
                        assert.False(running2)
                        running1 = false
                        release()
                    end)
                end),
                m:acquire():thenCall(function(release)
                    running2 = true
                    ran2 = true
                    return helper.delay(10):thenCall(function()
                        assert.False(running1)
                        running2 = false
                        release()
                    end)
                end)
        }):thenCall(function()
            assert.False(running1)
            assert.False(running2)
            assert.True(ran1)
            assert.True(ran2)
            done()
        end)
        assert.True(wait())
    end)
    it('double lock deadlocks', function()
        local m = mutex:new()
        m:acquire():thenCall(function()
            return m:acquire()
        end):thenCall(function()
            error('bomb!')
        end)
        helper.delay(10):thenCall(function()
            done()
        end)
        assert.True(wait())
    end)
    it('double release ok', function()
        local release
        local m = mutex:new()
        m:acquire():thenCall(function(r)
            release = r
        end):thenCall(function()
            release()
        end):thenCall(function()
            release()
        end)
        m:acquire():thenCall(function()
            done()
        end)
        assert.True(wait())
    end)
end)
