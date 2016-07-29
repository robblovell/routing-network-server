async = require('async')
request = require('superagent')
iGraphRepository = require

module.exports = class iGraphRepository
    constructor: (@config) ->
        @buffer = null

    find: (query, callback) ->


    get: (id, callback) ->


    add: (json, callback) ->
        make = (json) ->

        if (@buffer? || !callback?)
            @buffer.push(make( json))
        else
            throw new Error 'not implemented'
        return

    set: (id, json, callback) ->
        make = (id, json) ->

        if (@buffer? || !callback?)
            @buffer.push(make(id, json))
        else
            throw new Error 'not implemented'
        return

    delete: (id) ->


    pipeline: () ->
        @buffer = []

    exec: (callback) ->
        async.parallelLimit(@buffer, 10,
            (error, results) =>
                console.log("Error:"+error) if (error?)
                @buffer = null
#                console.log('done')
        )