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

    wireupZipsToLtls: (aix, nodes, ltls, callback) ->
        zip = nodes[aix]
        @repo.pipeline()
        if (zip? and zip.zip3 != '')
            for ltl in ltls # hook up one zip.
                continue if zip.id == ''
                id = zip.zip3+"_"+ltl.ltlCode+"_"+ltl.weightLo+"_"+ltl.weightHi
                params = {
                    sourcekind: 'Zip', sourceid: ''+zip.id,
                    destinationkind: 'Ltl', destinationid: ''+id, kind: 'ZIPLTL'
                }
                obj = { kind: 'ZIPLTL',cost: 0,id: zip.id+"_"+id }
                @repo.setEdge(params, obj)
                params = {
                    destinationkind: 'Zip', destinationid: ''+zip.id,
                    sourcekind: 'Ltl', sourceid: ''+id, kind: 'LTLZIP'
                }
                obj = { kind: 'LTLZIP',cost: 0,id: id+"__"+zip.id }
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
        # TODO:: move to config:
        filename = './data/weights-codes-half.csv'
        @repo.find({type: "Zip"}, (error, zips) =>
            contentsCodes = fs.readFileSync(filename, 'utf8')
            result = Papa.parse(contentsCodes, papaConfig)
            ltls = result.data
            @wireupZipsToLtls(0, zips, ltls, callback)
            return
        )
        return

module.exports = Builder