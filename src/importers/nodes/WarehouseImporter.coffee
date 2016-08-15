iImport = require('./../iImport')
Papa = require('babyparse')
fs = require('fs');
async = require('async')

class Importer extends iImport
    constructor: (@config) ->

    setTruth = (flag) ->
        if (typeof flag == "string")
            if flag == '1' || flag == '-1' || flag.toUpperCase() == 'TRUE'
                return true
            else
                return false
        if flag == -1 || flag == true || flag == 1
            return true
        else
            return false
    

    # add all to key value store.
    import: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data
        async.series(
            [
                (callback) =>
                    repo.run("CREATE INDEX ON :Seller(id)", {}, (error, result) =>
                        callback(error, result))
                (callback) =>
                    repo.run("CREATE INDEX ON :Warehouse(id)", {}, (error, result) =>
                        callback(error, result))
            ]
        ,
            (error, result) =>
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
                    # If a property of a warehouse can change over time, then it's not a new node type.
                    # If a property can't change over time, it's a node type.

                    node.isSeller = setTruth(node.isSeller)
                    node.IsBDWP = setTruth(node.IsBDWP) # don't string this together as an "or" set truth has a side effect.
                    node.IsResupplier = setTruth(node.IsResupplier)
                    node.IsSatellite = setTruth(node.IsSatellite)
                    node.isSweepable = setTruth(node.isSweepable)
                    node.isSeller = setTruth(node.isSeller)
                    node.IsCustomerPickup = setTruth(node.IsCustomerPickup)
                    node.type = 'Warehouse'
                    if node.isSeller
                        node.type = 'Seller'
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