iImport = require('./iImport')
fs = require('fs');
async = require('async')
math = require('mathjs')
geodist = require('geodist')
fs = require('fs');
Papa = require('babyparse')
papaConfig = {
    delimiter: ","	# auto-detect
    newline: ""	# auto-detect
    header: true
    dynamicTyping: false
    preview: 0
    encoding: "UTF-8"
    worker: false
    comments: false
    step: undefined
    download: false
    skipEmptyLines: false
    fastMode: false,
}
class Builder extends iImport
    constructor: (@config, @repo = null) ->

    setRepo: (repo) ->
        @repo = repo

    wireupZipsToLtls: (aix, nodes, ltls, callback) ->
        zip = nodes[aix]
        @repo.pipeline()
        if (zip? and zip.zip3 != '')
            for ltl in ltls # hook up one zip.
                continue if zip.id == ''
                id = zip.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                params = {
                    sourcekind: 'Zip'
                    sourceid: ''+zip.id
                    destinationkind: 'LtlCode'
                    destinationid: ''+id
                    kind: 'ZIPLTL'
                }
                obj = {
                    kind: 'ZIPLTL'
                    cost: 0
                    id: zip.id+"_"+id
                }
                @repo.setEdge(params, obj)

        @repo.exec((error, result) =>
            console.log("nodes: "+nodes.length+" ix: "+aix)
            if (error?)
                console.log("error:" +result)
                callback(error, result)
            else if ( aix+1 < nodes.length)
                @wireupZipsToLtls(aix+1, nodes, ltls, callback)
            else
                console.log("Finished")
                callback(error, result)
        )

    buildZipsToLtls: (callback) =>
        filename = './data/weights-codes.csv'
        @repo.find({type: "Zip"}, (error, zips) =>
            contentsCodes = fs.readFileSync(filename, 'utf8')
            result = Papa.parse(contentsCodes, papaConfig)
            ltls = result.data
            @wireupZipsToLtls(0, zips, ltls, callback)
            return
        )
        return

    wireupLtlsToLtls: (aix, bix, zips, ltls, callback) =>
        zip1 = zips[aix]
        zip2 = zips[bix]
        @repo.pipeline()
        if (zip1.zip3 != '' and zip2 != '')
            # for two zips, hook up an ltl.
            for ltl in ltls # hook up one zip.
                distance = geodist({lat: parseInt(zip1.latitude), lon: parseInt(zip1.longitude)},
                    {lat: parseInt(zip2.latitude), lon: parseInt(zip2.longitude)})

                id1 = zip1.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                id2 = zip2.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                params = {
                    sourcekind: 'LtlCode'
                    sourceid: ''+id1
                    destinationkind: 'LtlCode'
                    destinationid: ''+id2
                    kind: 'LTL'
                    cost: distance+10
                    linkid: id1+'_'+id2
                }
                matchStr =
                    "MATCH (a:"+params.sourcekind+
                        " {id: '"+params.sourceid+"'}), (b:"+params.destinationkind+
                        " {id: '"+params.destinationid+
                        "'}) CREATE (a)-[rel:"+params.kind.toUpperCase()+
                        " {id: '"+params.linkid+"', kind: '"+params.kind+"', cost: "+params.cost+
                        "}]->(b) RETURN rel"
                console.log(matchStr) if math.floor(math.random(0,10000)) == 1
                match = "MATCH (a:"+params.sourcekind+
                    " {id:{sourceid}}), (b:"+
                    params.destinationkind+
                    " {id:{destinationid}}) CREATE (a)-[rel:"+
                    params.kind.toUpperCase()+
                    " {id:{linkid}, kind:{kind}, cost: {cost}}]->(b) RETURN rel"
                @repo.run(match, params) # no callback on pipepline.s

        @repo.exec((error, result) =>
            if (error?)
                console.log("error:" +result)
                callback(error, result)
            else if (bix+1 < zips.length)
                @wireupLtlsToLtls(aix, bix+1, zips, ltls, callback)
            else if ( aix+1 < zips.length)
                console.log("zip: "+zips[aix].zip3)
                @traverseZips(aix+1, 0, zips, ltls, callback)
            else
                callback(error, result)
        )

    traverseZips: (aix, bix, zips, ltls, callback) =>
        @wireupLtlsToLtls(aix, bix, zips, ltls, callback)

    # add all to key value store.
    buildLtlCodesToLtlCodes: (callback) =>
        filename = './data/weights-codes.csv'
        @repo.find({type: "Zip"}, (error, zips) =>
            contentsCodes = fs.readFileSync(filename, 'utf8')
            result = Papa.parse(contentsCodes, papaConfig)
            ltls = result.data
            @traverseZips(0, 0, zips, ltls, callback)
            return
        )
        return


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