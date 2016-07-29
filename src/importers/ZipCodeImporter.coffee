iImport = require('./iImport')
Papa = require('babyparse')
fs = require('fs');
async = require('async')
module.exports = class ZipCodeImporter extends iImport
    constructor: (config) ->
        @config = config

    importKeyValue: (filename, repo, callback) ->
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data
        repo.pipeline()
        for zipcode in data
            id = zipcode.zip
            repo.set(id, zipcode)

        repo.exec(callback)

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
#            break if (i > 3)

        async.parallelLimit(addZipcodeFuncs, 10, (error, result) ->
            console.log(error) if error?
            callback(error, result)
            return
        )

#        repo.pipeline()
#        for zipcode in data
#            id = zipcode.zip
#            repo.add(id, zipcode)
#
#        repo.exec(callback)


