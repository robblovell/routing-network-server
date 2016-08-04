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
                    sourcekind: 'Zip', sourceid: ''+zip.id,
                    destinationkind: 'LtlCode', destinationid: ''+id, kind: 'ZIPLTL'
                }
                obj = { kind: 'ZIPLTL',cost: 0,id: zip.id+"_"+id }
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
                    sourcekind: 'LtlCode',sourceid: ''+id1
                    destinationkind: 'LtlCode',destinationid: ''+id2
                    kind: 'LTL',cost: distance+10,linkid: id1+'_'+id2
                }
                obj = { kind: 'LTL', cost: distance+2, id: id1+"_"+id2 }
                @repo.setEdge(params, obj)

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
            return
        )

    traverseZips: (aix, bix, zips, ltls, callback) =>
        @wireupLtlsToLtls(aix, bix, zips, ltls, callback)
        return

    # add all to key value store.
    buildLtlToLtl: (callback) =>
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

    wireupWarehouses: (zips, warehouses, callback) =>
        @repo.pipeline()
    # for two zips, hook up an ltl.
        for warehouse in warehouses # hook up one zip.
            id1 = warehouse.id
            warehousezip3 = warehouse.PostalCode.substring(0,3)
            matches = zips.filter(( obj ) -> return obj.zip3 == warehousezip3)
            if (matches.length < 1)
                console.log("ERROR:: Warehouse missing postal code: "+warehousezip3+"  code: "+warehouse.PostalCode)
                continue
            else if (matches.length > 1)
                console.log("ERROR:: More than one zip found.")
            zip = matches[0]

            id2 = zip.id
            params = {
                sourcekind: 'Warehouse',sourceid: ''+id1
                destinationkind: 'Zip',destinationid: ''+id2
                kind: 'WAREHOUSEZIP',linkid: id1+'_'+id2
            }
            obj = { kind: 'WAREHOUSEZIP', id: id1+"_"+id2 }

            @repo.setEdge(params, obj)

        console.log("finished")
        @repo.exec((error, result) =>
            if (error?)
                console.log("error:" +result)
                callback(error, result)
            else
                callback(error, result)
            return
        )
        return

    buildWarehousesToZips: (callback) =>
        filename = './data/warehouses.csv'
        # warehouse nodes have a zip code.
        @repo.find({type: "Zip"}, (error, zips) =>
            @repo.find({type: "Warehouse"}, (error, warehouses) =>
                @wireupWarehouses(zips, warehouses, callback)
                return
            )
        )
        return

    buildSkusToWarehouses: (callback) =>
        callback(null, true)
        return

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