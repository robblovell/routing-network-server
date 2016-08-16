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

    wireupLtlsToLtls: (aix, bix, zips, ltls, found, callback) =>
        zip1 = zips[aix]
        zip2 = zips[bix]
        @repo.pipeline()
        if (zip1.zip3 != '' and zip2 != '')
            distance = geodist({lat: parseInt(zip1.latitude), lon: parseInt(zip1.longitude)},
                {lat: parseInt(zip2.latitude), lon: parseInt(zip2.longitude)})
            if distance < 500
                found = true
#                console.log("Route between: #{zip1.zip3} and #{zip2.zip3}")
                # for two zips, hook up an ltl.
                for ltl in ltls # hook up one zip.
                    # TODO:: replace constant below with something that makes sense.
                    id1 = zip1.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                    id2 = zip2.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                    params = {
                        sourcekind: 'Ltl',sourceid: ''+id1
                        destinationkind: 'Ltl',destinationid: ''+id2
                        kind: 'LTL',cost: distance+50,linkid: id1+'_'+id2
                    }
                    obj = { kind: 'LTL', cost: distance+50, id: id1+"_"+id2 }
                    console.log(JSON.stringify(params)) if math.floor(math.random(0,1000)) == 0

                    @repo.setEdge(params, obj)
#            else
#                console.log("No route found between: #{zip1.zip3} and #{zip2.zip3}")

        @repo.exec((error, result) =>
            if (error?)
                console.log("error:" +result)
                callback(error, result)
            else if (bix+1 < zips.length)
                console.log("zip B: ------->"+zips[bix+1].zip3) if math.floor(math.random(0,500)) == 1

                @wireupLtlsToLtls(aix, bix+1, zips, ltls, found, callback)
            else if ( aix+1 < zips.length)
                console.log("NO ROUTES FOUND FOR ZIP: "+zips[aix].zip3) unless found
                console.log("zip A: -------< "+zips[aix+1].zip3)
                @traverseZips(aix+1, 0, zips, ltls, false, callback)
            else
                callback(error, result)
            return
        )

    traverseZips: (aix, bix, zips, ltls, callback) =>
        @wireupLtlsToLtls(aix, bix, zips, ltls, callback)
        return

# add all to key value store.
    buildLtlToLtl: (callback) =>
        # TODO:: move to config:
        filename = './data/weights-codes-half.csv'
        @repo.find({type: "Zip"}, (error, zips) =>
            contentsCodes = fs.readFileSync(filename, 'utf8')
            result = Papa.parse(contentsCodes, papaConfig)
            ltls = result.data
            @traverseZips(0, 0, zips, ltls, false, callback)
            return
        )
        return






module.exports = Builder