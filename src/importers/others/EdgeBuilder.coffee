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

    wireup: (aix, bix, aNodes, ltlCodes, callback) =>
        aNode = aNodes[aix]
        bNode = aNodes[bix]
        @repo.pipeline()

        for ltlCode in ltlCodes
            distance = geodist({lat: parseInt(aNode.latitude), lon: parseInt(aNode.longitude)},
                {lat: parseInt(bNode.latitude), lon: parseInt(bNode.longitude)})
            # connect zip codes to each ltlCode
            params = {
                sourcekind: source
                sourcenid: aNode.id
                destinationkind: destination
                destinationnid: bNode.id
                kind: kind
                cost: math.floor(distance)+10
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
            if (bix+1 < bNode.length)
                @wireup(aix, bix+1, aNodes, ltlCodes, callback)
            else if (aix+1 < bNode.length)
                @traverse(aix+1, 1, aNodes, ltlCodes, callback)
            else
                callback(error, result)
        )
    traverse: (aix, bix, aNodes, ltlCodes, callback) =>
        @wireup(aix, bix, aNodes, ltlCodes, callback)

    zip2ltl: (ix, nodes, ltlCodes, callback) =>
        # wire this zipcode to all ltl codes.
        aNode = aNodes[aix]
        @repo.pipeline()
        for ltlCode in ltlCodes
            params = {
                sourcekind: source
                sourcenid: aNode.id
                destinationkind: destination
                destinationnid: bNode.id
                kind: kind
                cost: math.floor(distance)+10
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
            @wireup(aix, bix, aNodes, ltlCodes, callback)
        )


    # add all to key value store.
    buildZipsToLtlCodes: (callback) =>
        @repo.find({type: "Zip"}, (error, aNodes) =>
            # find the zip's ltlCode
            for zip in aNodes
                @repo.find({type: "LtlCode"}, (error, ltlCodes) =>
                    @traverse(1, 1, aNodes, ltlCodes, callback)
                    return
                )
            return
        )
        return

    wireupLtlCodes: (aix, ltlCodes,callback) ->
        @repo.pipeline()
        aCode = ltlCodes[aix]
#        for bCode in ltlCodes




    buildLtlCodesToLtlCodes: (callback) ->
        @repo.find({type: "LtlCode"}, (error, ltlCodes) =>
            @wireupLtlCodes(1, 1, aNodes, ltlCodes, callback)
            return
        )
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