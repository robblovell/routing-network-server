
class iGraphRepository
    constructor: (config) ->

    query: (query) ->
        throw new Error("not implemented")

    getNode: (id) ->
        throw new Error("not implemented")

    setNode: (id, json) ->
        throw new Error("not implemented")

    deleteNode: (id, type='node') ->
        throw new Error("not implemented")

    getRelationship: (id) ->
        throw new Error("not implemented")

    setRelationship: (id, json) ->
        throw new Error("not implemented")

    deleteRelationship: (id) ->
        throw new Error("not implemented")

    pipeline: () ->
        throw new Error("not implemented")

    exec: (callback) ->
        throw new Error("not implemented")

module.exports = iGraphRepository
