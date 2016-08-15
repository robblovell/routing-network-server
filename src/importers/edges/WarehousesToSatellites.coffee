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

    wireupSatellites: (warehouses, callback) =>
        @repo.pipeline()
        for bdwp in warehouses.bdwps # hook up one warehouse if it is sweep enabled.
            id1 = bdwp.id
            continue unless bdwp.haszip
            # find the near bdwp warehouses.
            found = false
            for satellite in warehouses.satellites
                continue unless satellite.haszip
                continue if id1 == satellite.id

                distance = geodist({lat: parseInt(bdwp.lat), lon: parseInt(bdwp.lon)},
                    {lat: parseInt(satellite.lat), lon: parseInt(satellite.lon)})

                # TODO:: replace constant below with something that makes sense.
                if distance < 1200 # TODO:: maximum distance to a sattelite
                    found = true
                    id2 = satellite.id
                    cost = distance # TODO:: real cost from a file generated from analytics
                    # hook up this warehouse to the closest satellite.
                    params = {
                        sourcekind: 'Warehouse', sourceid: ''+id1
                        destinationkind: 'Warehouse', destinationid: ''+id2
                        kind: 'REPOSITION', linkid: id1+'_'+id2
                    }
                    obj = { kind: 'REPOSITION', cost: cost, id: id1+"_"+id2 }
                    console.log("satellite: "+JSON.stringify(params))
                    @repo.setEdge(params, obj)

            if !found
                console.log("No satellite found close to this warehouse, uses postal codes or the code is not assigned.")

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

    buildWarehousesToSatellites: (callback) =>
        @repo.find({type: "Zip"}, (error, zips) =>
            @repo.find({type: "Warehouse"}, (error, warehouses) =>
                collation = cleanupAndCollateWarehouses(warehouses, zips)
                @wireupSatellites(collation, callback)
                return
            )
        )
        return
        callback(null, true)

module.exports = Builder