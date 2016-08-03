iImport = require('./iImport')
fs = require('fs');
async = require('async')
math = require('mathjs')
geodist = require('geodist')
class Importer extends iImport
    constructor: (@config, @repo = null) ->

    source = 'Zip'
    destination = 'LtlCode'
    kind = 'ZipLtl'
    inventoryLo = 0
    inventoryHi = 10

    setRepo: (repo) ->
        @repo = repo

    wireup: (aix, aNodes, bNodes, callback) =>
        @repo.pipeline()
        aNode = aNodes[aix]
        for bNode in bNodes
            distance = geodist({lat: aNode.lat, lon: aNode.long},
                {lat: bNode.lat, lon: bNode.lon})

            params = {
                sourcekind: source
                sourcenid: aNode.id
                destinationkind: destination
                destinationnid: bNode.id
                kind: kind
                cost: math.floor(distance)
            }
            matchStr =
                "MATCH (a:"+params.sourcekind+
                    " {id: "+params.sourceid+"}), (b:"+params.destinationkind+
                    " {id: "+params.destinationid+
                    "}) CREATE (a)-[rel:"+params.kind.toUpperCase()+
                    " {kind: {"+params.kind+"}, inventory: "+params.inventory+
                    "}]->(b) RETURN rel"
            console.log(matchStr) # if math.random(0,10) == 0
            match = "MATCH (a:"+params.sourcekind+
                " {name:{sourceid}}), (b:"+
                params.destinationkind+
                " {name:{destinationid}}) CREATE (a)-[rel:"+
                params.kind.toUpperCase()+
                " {kind: {kind}, cost: {cost}}]->(b) RETURN rel"
            @repo.run(match, params) # no callback on pipepline.

        @repo.exec((error, result) =>
            if (aix < aNode.length)
                @wireup(aix+1, aNodes, bNodes, callback)
            else
                callback(error, result)
        )


    # add all to key value store.
    buildZipsToLtlCodes: (callback) =>
        @repo.find({type: "Zip"}, (error, aNodes) =>
            @repo.find({type: "LtlCode"}, (error, bNodes) =>
                @wireup(1, aNodes, bNodes, callback)
                return
            )
            return
        )
        return

    buildLtlCodesToLtlCodes: (callback) ->
        callback(null, true)
    buildSweeps: (callback) ->
        callback(null, true)
    buildResuppliers: (callback) ->
        callback(null, true)
    buildWarehousesToZips: (callback) ->
        callback(null, true)
    buildSkusToWarehouses: (callback) ->
        callback(null, true)

    buildEdges: (callback) ->
        async.parallel([
                (callback) ->
                    buildZipsToLtlCodes(callback)
            ,
                (callback) ->
                    buildLtlCodesToLtlCodes(callback)
            ,
                (callback) ->
                    buildSweeps(callback)
            ,
                (callback) ->
                    buildResuppliers(callback)
            ,
                (callback) ->
                    buildWarehousesToZips(callback)
            ,
                (callback) ->
                    buildSkusToWarehouses(callback)
            ],
            (error, result) ->
                callback(error, result)
        )
        return

    import: (repo, callback) ->
        buildEdges(repo, callback)
        return

module.exports = Importer