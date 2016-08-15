iImport = require('./../iImport')
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
                @repo.find({type: "Seller"}, (error, sellers) =>
                    warehouses = [warehouses..., sellers...]
                    @wireupSkustoWarehouses(0, skus, warehouses, callback)
                    return
                )
            )
        )
        return

module.exports = Builder