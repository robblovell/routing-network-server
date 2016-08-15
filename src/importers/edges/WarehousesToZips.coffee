iImport = require('./../iImport')
fs = require('fs');
async = require('async')
math = require('mathjs')
geodist = require('geodist')
fs = require('fs');
cleanupAndCollateWarehouses = require('./CleanupAndCollateWarehouses')

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

    wireupWarehousesToZips: (zips, warehouses, sourceKind, callback) =>
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
                sourcekind: sourceKind, sourceid: ''+id1
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
            async.series([
                (callback) =>
                    @repo.find({type: "Warehouse"}, (error, warehouses) =>
                        @wireupWarehousesToZips(zips, warehouses, 'Warehouse', callback)
                        return
                    )
                (callback) =>
                    @repo.find({type: "Seller"}, (error, warehouses) =>
                        @wireupWarehousesToZips(zips, warehouses, 'Seller', callback)
                        return
                    )
                ],
                (error, result) =>
                    callback()
            )
        )
        return

module.exports = Builder