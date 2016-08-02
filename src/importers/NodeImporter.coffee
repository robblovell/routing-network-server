iImport = require('./iImport')
Papa = require('babyparse')
fs = require('fs');
async = require('async')

class Importer extends iImport
    constructor: (config) ->
        @config = config

    # add all to key value store.
    importKeyValue: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data
        repo.pipeline()

        for node in data
            id = node[@config.nodeIdName]
            node.type = @config.nodeType
            node.id = id
            repo.set(id, node, (error, result) ->
                if error?
                    callback(error, null)
                return
            )

        repo.exec(callback)
        return

    # add all to database.
    import: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data

        makeAdd = (node) ->
            return (callback) ->
                repo.find(JSON.stringify({zip: node.zip}), (error, result) ->
                    if (result.body.length == 0)
                        repo.add(node, (error, result) ->
                            console.log(error) if (error?)
                            callback(error, result)
                            return
                        )
                    else
                        callback(error, result)
                    return
                )
        addFuncs = []
        for node, i in data
            addFuncs.push(makeAdd(node))

        async.parallelLimit(addFuncs, 10, (error, result) ->
            console.log(error) if error?
            callback(error, result)
            return
        )

module.exports = Importer