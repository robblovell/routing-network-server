iImport = require('./../iImport')
Papa = require('babyparse')
fs = require('fs');

class Importer extends iImport
    constructor: (@config) ->

    # add all to key value store.
    import: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data
        repo.run("CREATE INDEX ON :#{@config.nodeType}(id)", {}, (error, result) =>
            if (error?)
                console.log(""+JSON.stringify(error))
                callback(error)
                return
            repo.pipeline()
            for node in data
                if (@config.nodeIdName == '')
                    id = (v for k,v of node).reduce((x,y) -> ""+x+"_"+y)
                else
                    id = node[@config.nodeIdName]
                console.log("id: "+id)
                node.type = @config.nodeType
                node.id = id
                repo.set(id, node, (error, result) ->
                    if error?
                        callback(error, null)
                    return
                )

            repo.exec(callback)
            return
        )

module.exports = Importer