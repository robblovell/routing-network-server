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

    wireupResuppliers: (warehouses, callback) =>
        @repo.pipeline()

        for resupplier in warehouses.resuppliers
            id1 = resupplier.id
            continue unless resupplier.haszip
            # hook up this resupplier to all bdwp warehouses and other resuppliers.
            for bdwp in warehouses.bdwps
                if bdwp.id != resupplier.id and !bdwp.IsSatellite
                    if bdwp.haszip
                        distance = geodist({lat: parseInt(bdwp.lat), lon: parseInt(bdwp.lon)},
                            {lat: parseInt(resupplier.lat), lon: parseInt(resupplier.lon)})
                    else
                        distance = -1 #TODO:: real costs.

                    id2 = bdwp.id
                    cost = distance # TODO:: real cost from a file generated from analytics
                    # hook up this resupplier to this warehouse.
                    params = {
                        sourcekind: 'Warehouse', sourceid: ''+id1
                        destinationkind: 'Warehouse', destinationid: ''+id2
                        kind: 'RESUPPLIES', linkid: id1+'_'+id2
                    }
                    obj = { kind: 'RESUPPLIES', cost: cost, id: id1+"_"+id2 }
                    console.log("resupplier: "+JSON.stringify(params))
                    @repo.setEdge(params, obj)

        @repo.exec((error, result) =>
            if (error?)
                console.log("error:" +result)
                callback(error, result)
            else
                console.log("finished")
                callback(error, result)
            return
        )
        return

    buildResuppliersToWarehouses: (callback) =>
        @repo.find({type: "Zip"}, (error, zips) =>
            @repo.find({type: "Warehouse"}, (error, warehouses) =>
                @repo.find({type: "Seller"}, (error, sellers) =>
                    warehouses = [warehouses..., sellers...]
                    collation = cleanupAndCollateWarehouses(warehouses, zips)
                    @wireupResuppliers(collation, callback)
                    return
                )
            )
        )
        return
        callback(null, true)

module.exports = Builder