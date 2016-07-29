Redis = require('ioredis')
iRepository = require('./iRepository')

class RedisRepository extends iRepository
    constructor: (@config) ->
        # 'redis://127.0.0.1:6379/1'
        if !@config.url?
            @config.url = 'redis://127.0.0.1:6379/1'

        @redis = new Redis(@config.url)
        @buffer = null

    find: (query, callback) ->
        return @redis.get(query, callback)

    get: (id, callback) ->
        return @redis.get(id, callback)

    add: (json) ->
        if (@buffer?)
            @buffer.set(id, JSON.stringify(json))
        else
            @redis.set(id, json)

    set: (id, json) ->
        if (@buffer?)
            @buffer.set(id, JSON.stringify(json))
        else
            @redis.set(id, json)

    delete: (id) ->
        throw new Error("not implemented")

    pipeline: () ->
        @buffer = @redis.pipeline()

    exec: (callback) ->
        @buffer.exec(callback)
        @buffer = null

module.exports = RedisRepository