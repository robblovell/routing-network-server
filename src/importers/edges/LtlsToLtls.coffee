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

    wireupLtlsToLtls: (aix, bix, zips, ltls, callback) =>
        zip1 = zips[aix]
        zip2 = zips[bix]
        @repo.pipeline()
        if (zip1.zip3 != '' and zip2 != '')
            # for two zips, hook up an ltl.
            for ltl in ltls # hook up one zip.
                distance = geodist({lat: parseInt(zip1.latitude), lon: parseInt(zip1.longitude)},
                    {lat: parseInt(zip2.latitude), lon: parseInt(zip2.longitude)})

                # TODO:: replace constant below with something that makes sense.
                if distance < 1000
                    id1 = zip1.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                    id2 = zip2.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                    params = {
                        sourcekind: 'Ltl',sourceid: ''+id1
                        destinationkind: 'Ltl',destinationid: ''+id2
                        kind: 'LTL',cost: distance+50,linkid: id1+'_'+id2
                    }
                    obj = { kind: 'LTL', cost: distance+50, id: id1+"_"+id2 }
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






module.exports = Builder