async = require('async')
request = require('superagent')

module.exports = class RestRepository
    constructor: (@config) ->
        @buffer = null

    find: (query, callback) ->
        request
            .get(@config.url)
            .query({ query: query })
            .set('Accept', 'application/json')
            .end(callback)

    get: (id, callback) ->
        request
            .get(@config.url+"/"+id)
            .set('Accept', 'application/json')
            .end(callback)

    add: (json, callback) ->
        make = (url, json) ->
            return (callback) ->
#                console.log("request:"+url)
                request
                .post(url)
                .send(json)
                .set('Accept', 'application/json')
                .end(callback)
                return

        if (@buffer? || !callback?)
            @buffer.push(make(@config.url, json))
        else
            request
            .post(@config.url)
            .send(json)
            .set('Accept', 'application/json')
            .end(callback)
        return

    set: (id, json, callback) ->
        make = (url, json) ->
            return (callback) ->
#                console.log("request:"+url)
                request
                    .put(url)
                    .send(json)
                    .set('Accept', 'application/json')
                    .end(callback)
                return

        if (!id?)
            url = @config.url
        else
            url = @config.url+"/"+id

        if (@buffer? || !callback?)
            @buffer.push(make(url, json))
        else
            request
                .put(url)
                .send(json)
                .set('Accept', 'application/json')
                .end(callback)
        return

    delete: (id) ->
        request
            .delete(@config.url+"/"+id)
            .send(json)
            .set('Accept', 'application/json')
            .end(callback)

    pipeline: () ->
        @buffer = []

    exec: (callback) ->
        async.parallelLimit(@buffer, 10,
            (error, results) =>
                console.log("Error:"+error) if (error?)
                @buffer = null
        )