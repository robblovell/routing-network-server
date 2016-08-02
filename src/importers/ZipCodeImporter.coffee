iImport = require('./iImport')
Papa = require('babyparse')
fs = require('fs');
async = require('async')

class ZipCodeImporter extends iImport
    constructor: (config) ->
        @config = config

    # add all to key value store.
    importKeyValue: (filename, repo, callback) ->
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
                repo.set(id, zipcode, (error, result) ->
                    if error?
                        callback(error, null)

                    return
                )
                have[id] = true

        repo.exec(callback)
        return

    # add all to database.
    import: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data

        makeAdd = (zipcode) ->
            return (callback) ->
                repo.find(JSON.stringify({zip: zipcode.zip}), (error, result) ->
                    if (result.body.length == 0)
                        repo.add(zipcode, (error, result) ->
                            console.log(error) if (error?)
                            callback(error, result)
                            return
                        )
                    else
                        callback(error, result)
                    return
                )
        addZipcodeFuncs = []
        for zipcode, i in data
            addZipcodeFuncs.push(makeAdd(zipcode))

        async.parallelLimit(addZipcodeFuncs, 10, (error, result) ->
            console.log(error) if error?
            callback(error, result)
            return
        )

module.exports = ZipCodeImporter