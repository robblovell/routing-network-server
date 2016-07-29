async = require('async')
request = require('superagent')

module.exports = class RestRepository
    constructor: (@config, @model) ->
        @buffer = null

    find: (query, callback) ->
        @model.find(query, callback)
        return

    get: (id, callback) ->
        @model.findById(id, callback)
        return

    add: (json, callback) ->
        model = new @model(json)
        callback(null, model)
        return

    set: (id, json, callback) ->
        make = (url, json) ->
            return (callback) ->
                @model.update({ _id: id }, json, {multi: false}, callback)
                return
        if (@buffer? || !callback?)
            @buffer.push(make(@config.url, json))
        else
            @model.update({ _id: id }, json, {multi: false}, callback)
        return

    delete: (id, callback) ->
        @model.remove({ _id: id }, callback)
        return

    pipeline: () ->
        @buffer = []
        return

    exec: (callback) ->
        async.parallelLimit(@buffer, 10,
            (error, results) =>
                console.log("Error:"+error) if (error?)
                @buffer = null
#                console.log('done')
                return
        )
        return