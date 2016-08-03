iImport = require('./iImport')
Papa = require('babyparse')
fs = require('fs');

class ZipCodeImporter extends iImport
    constructor: (config) ->
        @config = config

    # add all to key value store.
    import: (filename1, filename2, repo, callback) ->
        contents = fs.readFileSync(filename1, 'utf8')
        result1 = Papa.parse(contents, @config)
        ZipCodes = result1.data
        contentsCodes = fs.readFileSync(filename2, 'utf8')
        result2 = Papa.parse(contentsCodes, @config)
        LtlCodes = result2.data

        zip3s = {}
        for zipcode,i in ZipCodes
            continue if i == 0
            zipcode.zip3 = zipcode.zip.substring(0,3)

            if (!zip3s[zipcode.zip3])
                zipcode.type = "Zip"
                zipcode.zip = [zipcode.zip]
                zip3s[zipcode.zip3] = zipcode
            else
                zip3s[zipcode.zip3].zip.push(zipcode.zip)

        console.log("finished fixing up zip codes")

        build = (ix, codes, zips, callback) ->
            ltlcode = codes[ix]
            repo.pipeline()
            count = 0

            for key, zipcode of zips
                zipcode.ltlCode = ltlcode.ltlCode
                zipcode.weightLo = ltlcode.weightLo
                zipcode.weightHi = ltlcode.weightHi
                id = zipcode.zip3+"_"+zipcode.ltlCode+"_"+zipcode.weightLo+"_"+zipcode.weightHi
                zipcode.id = id

#                console.log("ix: #{count*ix}  Zip Code: "+zipcode.id) if math.floor(math.random(0,100)) == 0
                repo.set(id, zipcode, (error, result) ->
                    if error?
                        callback(error, null)
                    return
                )
                count++

            console.log("Doing Chunk: "+ix)
            repo.exec((error, result) ->
                if (ix < codes.length && codes[ix+1]?)
                    console.log("next chunck: "+(ix+1))
                    build(ix+1, codes, zips, callback)
                else
                    console.log("finished")
                    callback(error,result)
                return
            )
            return

#        repo.run("CREATE INDEX ON :Zip(id)", {}, (error, result) -> )
#        repo.run("CREATE INDEX ON :Zip(zip3)", {}, (error, result) ->)
        # 1 to skip the header of the csv file.
        build(1, LtlCodes,zip3s, callback)

        return

module.exports = ZipCodeImporter