iImport = require('./iImport')
fs = require('fs');
async = require('async')
math = require('mathjs')
geodist = require('geodist')

class Builder extends iImport
    constructor: (@config, @repo = null) ->

    setRepo: (repo) ->
        @repo = repo

    source = 'Zip'
    destination = 'Zip'
    kind = 'ZipTo'

    wireup: (aix, bix, nodes) =>
        @repo.pipeline()

        anode = nodes[aix]
        if (anode?)
            i = 0
            for k in [bix...bix+100]
                bnode = nodes[k]
                continue if !bnode?
                distance = geodist({lat: anode.lat, lon: anode.long}, {lat: bnode.lat, lon: bnode.lon})
                cost = math.floor(distance)+10
                params = {
                    sourcekind: source
                    sourceid: anode.id
                    destinationkind: destination
                    destinationid: bnode.id
                    kind: kind
                    cost: cost
                }
                matchStr =
                    "MATCH (a:"+params.sourcekind+
                        " {id: "+params.sourceid+"}), (b:"+params.destinationkind+
                        " {id: "+params.destinationid+
                        "}) CREATE (a)-[rel:"+params.kind.toUpperCase()+
                        " {kind: {"+params.kind+"}, inventory: "+params.inventory+
                        "}]->(b) RETURN rel"
                console.log(matchStr) if i++%500 == 0

                match = "MATCH (a:"+params.sourcekind+
                    " {id:{sourceid}}), (b:"+
                    params.destinationkind+
                    " {id:{destinationid}}) CREATE (a)-[rel:"+
                    params.kind.toUpperCase()+
                    " {kind: {kind}, cost: {cost}}]->(b) RETURN rel"
                @repo.run(match, params) # no callback on pipepline.


        @repo.exec((error, result) =>
            if bix >= nodes.length
                bix = 0
                aix += 1
            if aix < nodes.length
                console.log("Wire up:"+(aix+1)+ " "+(bix+1))
                @wireup(aix, bix+100, nodes)
            else
                callback(error, result)
            return
        )
        return

    # add all to key value store.
    buildZipsToLtlCodes: (callback) =>
        @repo.find({type: "Zip"}, (error, nodes) =>
            @wireup(1, 1, nodes, callback)
        )
        return

    buildLtlCodesToLtlCodes: (callback) =>
        callback(null, true)
    buildSweeps: (callback) =>
        callback(null, true)
    buildResuppliers: (callback) =>
        callback(null, true)
    buildWarehousesToZips: (callback) =>
        callback(null, true)
    buildSkusToWarehouses: (callback) =>
        callback(null, true)

    build: (callback) =>
        async.parallel([
                (callback) =>
                    @buildZipsToLtlCodes(callback)
            ,
                (callback) =>
                    @buildLtlCodesToLtlCodes(callback)
            ,
                (callback) =>
                    @buildSweeps(callback)
            ,
                (callback) =>
                    @buildResuppliers(callback)
            ,
                (callback) =>
                    @buildWarehousesToZips(callback)
            ,
                (callback) =>
                    @buildSkusToWarehouses(callback)
            ],
            (error, result) =>
                callback(error, result)
        )
        return


module.exports = Builder