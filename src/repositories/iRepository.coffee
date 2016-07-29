
class iRepository
    constructor: (config) ->

    find: (query) ->
        throw new Error("not implemented")

    get: (id) ->
        throw new Error("not implemented")

    add: (json) ->
        throw new Error("not implemented")

    set: (id, json) ->
        throw new Error("not implemented")

    delete: (id) ->
        throw new Error("not implemented")

    pipeline: () ->
        throw new Error("not implemented")

    exec: (callback) ->
        throw new Error("not implemented")

module.exports = iRepository
