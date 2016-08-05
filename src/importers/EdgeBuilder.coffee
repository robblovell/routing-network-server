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


    wireupWarehousesToZips: (zips, warehouses, callback) =>
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
                @wireupWarehousesToZips(zips, warehouses, callback)
                return
            )
        )
        return

    wireupSkustoWarehouses: (aix, skus, warehouses, callback) =>
        @repo.pipeline()
        # for two zips, hook up an ltl.
        sku = skus[aix]
        if sku?
            id1 = sku.id
            for warehouse in warehouses # hook up one zip.
                id2 = warehouse.id

                params = {
                    sourcekind: 'Sku',sourceid: ''+id1
                    destinationkind: 'Warehouse',destinationid: ''+id2
                    kind: 'SKUWAREHOUSE',linkid: id1+'_'+id2
                }
                obj = { kind: 'SKUWAREHOUSE', id: id1+"_"+id2, inventory: math.floor(math.random(0,100)) }

                @repo.setEdge(params, obj)

        @repo.exec((error, result) =>
            if (error?)
                console.log("error:" +result)
                callback(error, result)
            else if (aix < skus.length)
                console.log("Sku: "+aix+"  "+JSON.stringify(sku))
                @wireupSkustoWarehouses(aix+1, skus, warehouses, callback)
            else
                console.log("finished")
                callback(error, result)
            return
        )
        return


    buildSkusToWarehouses: (callback) =>
        @repo.find({type: "Sku"}, (error, skus) =>
            @repo.find({type: "Warehouse"}, (error, warehouses) =>
                @wireupSkustoWarehouses(0, skus, warehouses, callback)
                return
            )
        )
        return

    cleanupAndCollateWarehouses: (warehouses, zips) =>
        flags = ['isSeller','isSweepable','IsBDWP','IsResupplier','IsCustomerPickup','IsSatellite']
        for warehouse in warehouses
            for flag in flags
                if warehouse[flag] == -1 || warehouse[flag] == '-1' || warehouse[flag].toUpperCase() == 'TRUE'||
                warehouse[flag] == true || warehouse[flag] == 1 || warehouse[flag] == '1'
                    warehouse[flag] = true
                else
                    warehouse[flag] = false

            zip = warehouse['PostalCode'].substring(0,3)
            matches = zips.filter(( obj ) -> return obj.zip3 == zip)
            if (matches.length > 0)
                zip = matches[0]
                warehouse.zip3 = zip.zip3
                warehouse.lat = zip.latitude
                warehouse.lon = zip.longitude
                warehouse.haszip = true
            else
                warehouse.haszip = false


        # make a list of BDWP warehouses
        bdwps = []
        for warehouse in warehouses
            if warehouse.IsBDWP or warehouse.IsResupplier
                bdwps.push(warehouse)
        resuppliers = []
        for warehouse in warehouses
            if warehouse.IsResupplier
                resuppliers.push(warehouse)

        # make a list of seller warehouses
        sellers = []
        for warehouse in warehouses
            if warehouse.isSeller
                sellers.push(warehouse)
        sweepers = []
        for warehouse in warehouses
            if warehouse.isSweepable
                sweepers.push(warehouse)
        satellites = []
        for warehouse in warehouses
            if warehouse.IsSatellite
                satellites.push(warehouse)

        return { bdwps:bdwps,resuppliers:resuppliers, sellers:sellers, sweepers:sweepers, satellites:satellites, warehouses:warehouses}

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
                    sourcekind: 'Warehouse', sourceid: ''+id1
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
                collation = @cleanupAndCollateWarehouses(warehouses, zips)
                @wireupSweeps(collation, callback)
                return
            )
        )
        return

        callback(null, true)

    wireupResuppliers: (warehouses, callback) =>
        @repo.pipeline()

        for resupplier in warehouses.resuppliers
            id1 = resupplier.id
            continue unless resupplier.haszip
            # hook up this resupplier to all bdwp warehouses and other resuppliers.
            for bdwp in warehouses.bdwps
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
                collation = @cleanupAndCollateWarehouses(warehouses, zips)
                @wireupResuppliers(collation, callback)
                return
            )
        )
        return

        callback(null, true)

    wireupSatellites: (warehouses, callback) =>
        @repo.pipeline()
        for bdwp in warehouses.bdwps # hook up one warehouse if it is sweep enabled.
            id1 = bdwp.id
            continue unless bdwp.haszip
            # find the nearest bdwp warehouse.
            found = null
            closest = -1
            for satellite in warehouses.satellites
                continue unless satellite.haszip

                distance = geodist({lat: parseInt(bdwp.lat), lon: parseInt(bdwp.lon)},
                    {lat: parseInt(satellite.lat), lon: parseInt(satellite.lon)})
                if (distance < closest || closest == -1)
                    closest = distance
                    found = satellite
            # TODO:: replace constant below with something that makes sense.
            if found? and distance < 300 # TODO:: maximum distance to a sattelite
                id2 = found.id
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
            else
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
                collation = @cleanupAndCollateWarehouses(warehouses, zips)
                @wireupSatellites(collation, callback)
                return
            )
        )
        return
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
                    @buildSweepsToWarehouses(callback)
            ,
                (callback) =>
                    @buildResuppliersToWarehouses(callback)
            ,
                (callback) =>
                    @buildWarehousesToWarehouses(callback)
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