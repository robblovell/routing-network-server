iImport = require('./../iImport')
Papa = require('babyparse')
fs = require('fs');
async = require('async')

class ZipCodeImporter extends iImport
    constructor: (config) ->
        @config = config

    # add all to key value store.
    import: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data
        repo.pipeline()
        for zipcode in data
            zipcode.zip3 = zipcode.zip.substring(0,3)
            zipcode.type = "Zip"

        have = []
        for zipcode in data
            id = zipcode.zip3
            if !have[id]
                console.log("zipcode: "+id)
                repo.set(id, zipcode, (error, result) ->
                    if error?
                        callback(error, null)

                    return
                )
                have[id] = true

        repo.exec((error, result) ->
            repo.run("CREATE INDEX ON :Zip(id)", {}, (error, result) ->
                repo.run("CREATE INDEX ON :Zip(zip3)", {}, (error, result) ->
                    callback(error, result)
                )
            )
        )
        return


module.exports = ZipCodeImporter