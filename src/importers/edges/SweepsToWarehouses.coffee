iImport = require('./../iImport')
fs = require('fs');
async = require('async')
math = require('mathjs')
geodist = require('geodist')
fs = require('fs');
cleanupAndCollateWarehouses = require('cleanupAndCollateWarehouses')

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


    wireupSweeps: (warehouses, callback) =>
        @repo.pipeline()
        for sweeper in warehouses.sweepers # hook up one warehouse if it is sweep enabled.
            id1 = sweeper.id
            continue unless sweeper.haszip
            # find the nearest bdwp warehouse.
            found = null
            closest = -1
            for bdwp in warehouses.bdwps
                continue unless bdwp.haszip
                distance = geodist({lat: parseInt(bdwp.lat), lon: parseInt(bdwp.lon)},
                    {lat: parseInt(sweeper.lat), lon: parseInt(sweeper.lon)})
                if (distance < closest || closest == -1)
                    closest = distance
                    found = bdwp
            if found?
                id2 = found.id
                cost = distance # TODO:: real cost from a file generated from analytics
                # hook up this sweeper to the closest warehouse.
                params = {
                    sourcekind: 'Seller', sourceid: ''+id1
                    destinationkind: 'Warehouse', destinationid: ''+id2
                    kind: 'SWEEP', linkid: id1+'_'+id2
                }
                obj = { kind: 'SWEEP', cost: cost, id: id1+"_"+id2 }
                @repo.setEdge(params, obj)
            else
                console.log("No warehouses found close to this sweeper, uses postal codes or the code is not assigned.")

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

    buildSweepsToWarehouses: (callback) =>
        @repo.find({type: "Zip"}, (error, zips) =>
            @repo.find({type: "Warehouse"}, (error, warehouses) =>
                @repo.find({type: "Seller"}, (error, sellers) =>
                    warehouses = [warehouses..., sellers...]
                    collation = cleanupAndCollateWarehouses(warehouses, zips)
                    @wireupSweeps(collation, callback)
                    return
                )
            )
        )
        return

        callback(null, true)

module.exports = Builder