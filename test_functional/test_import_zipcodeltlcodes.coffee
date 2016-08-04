should = require('should')
assert = require('assert')
math = require('mathjs')

importer = require('../src/importers/importZipCodeLtlCodes')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')
fs = require('fs');
Papa = require('babyparse')

describe 'Errata', () ->

    checkAllZipCodes = (filename1, filename2, repo, done) =>
        contents = fs.readFileSync(filename1, 'utf8')
        result1 = Papa.parse(contents, @config)
        ZipCodes = result1.data
        contentsCodes = fs.readFileSync(filename2, 'utf8')
        result2 = Papa.parse(contentsCodes, @config)
        LtlCodes = result2.data

        # function to get one zip code by id and check the result.
        make = (id, type) ->
            return (callback) ->
                repo.get({id: id, type: type}, (error, result) ->
                    JSON.parse(result).id.should.be.equal(id)
                    callback(null, result)
                    return
                )

        getZipFuncs = []
        zip3s = {}
        for zipcode,i in ZipCodes
            continue if i == 0
            zipcode.zip3 = zipcode[0].substring(0,3)

            if (zipcode.zip3 != "" && !zip3s[zipcode.zip3])
                zipcode.type = "LtlCode"
                zipcode.zip = [zipcode.zip]
                zip3s[zipcode.zip3] = zipcode

        # random test for existence of codes.
        for ltlcode,i in LtlCodes
            continue if i == 0
            continue if math.floor(math.random(0,10) > 1)
#            break if i > 2
            for key,zipcode of zip3s
                continue if math.floor(math.random(0,30) > 1)
                zipcode.ltlCode = ltlcode[0]
                zipcode.weightLo = ltlcode[1]
                zipcode.weightHi = ltlcode[2]
                id = zipcode.zip3+"_"+zipcode.ltlCode+"_"+zipcode.weightLo+"_"+zipcode.weightHi
                zipcode.id = id
                getZipFuncs.push(make(id, 'LtlCode')) if (id != "")

        console.log("Test for this many zips:"+getZipFuncs.length)
        async.parallelLimit(getZipFuncs, 1,
            (error, results) =>
                console.log('error'+error) if error
                done(); return
        )
        return

    it 'Imports ZipCodes Neo4j', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        filename1 = './data/zipcodes.csv'
        filename2 = './data/weights-codes.csv'
        importer.import(filename1, filename2, repo, (error, results) ->
            if (error?)
                console.log("error: "+error)
                assert(false)
                done(); return
            # do a spot check:
            repo.get({id: '002_1000_0_100', type: 'LtlCode'}, (error, result) ->
                if (error?)
                    console.log("error: "+error)
                    assert(false)
                    done(); return
                node = JSON.parse(result)
                node.id.should.be.equal('002_1000_0_100')
                node.zip3.should.be.equal('002')

                # now check all the zipcodes
                checkAllZipCodes(filename1, filename2, repo, done)
                return
            )
            return

        )
        return


#    checkAllZipCodes2 = (filename, repo, done) =>
#        contents = fs.readFileSync(filename, 'utf8')
#        result = Papa.parse(contents, @config)
#        data = result.data
#
#        # function to get one zip code by id and check the result.
#        make = (id) ->
#            return (callback) ->
#                repo.find(JSON.stringify({zip: id}), (error, result) ->
#                    result.body[0].zip.should.be.equal(id)
#                    callback(null, result)
#                )
#
#        getZipFuncs = []
#        for zipcode,i in data
#            continue if i == 0
#            id = zipcode[0]
#            getZipFuncs.push(make(id))
##            break if i > 3
#
#        async.parallelLimit(getZipFuncs, 1,
#            (error, results) =>
#                console.log('error'+error) if error
#                done()
#        )
#        return

#    it 'Imports ZipCodes Redis', (done) ->
#        redisRepoConfig = {
#            url: 'redis://127.0.0.1:6379/1'
#        }
#        repo = new RedisRepostitory(redisRepoConfig)
#        filename = './data/zipcodes.csv'
#        importer.importKeyValue(filename, repo, (error, results) ->
#            # do a spot check:
#            repo.get('852', (error, result) ->
#                zip = JSON.parse(result)
#                zip.zip3.should.be.equal('852')
#                result.should.be.equal('{"zip":"85200","city":"Mesa","state":"AZ","latitude":"33.423596","longitude":"-111.594435","timezone":"-7","dst":"0","zip3":"852"}')
#                # now check all the zipcodes
#                checkAllZipCodes(filename, repo, done)
#            )
#
#        )


#
#    it 'Imports ZipCodes REST', (done) ->
#        restRepoConfig = {
#            url: 'http://127.0.0.1:3000/codes'
#        }
#        repo = new RestRepostitory(restRepoConfig)
#        filename = './data/zipcodes.csv'
#        importer.import(filename, repo, (error, results) ->
#            # do a spot check:
#            repo.find(JSON.stringify({zip: '00210'}), (error, result) ->
#                zip = result.body[0]
#                zip.zip.should.be.equal('00210')
#                console.log(zip)
#                zip.city.should.be.equal('Portsmouth')
#                zip.state.should.be.equal('NH')
#                zip.latitude.should.be.equal('43.005895')
#                zip.longitude.should.be.equal('-71.013202')
#                zip.timezone.should.be.equal('-5')
#                zip.dst.should.be.equal('1')
#                # now check all the zipcodes
#                checkAllZipCodes2(filename, repo, done)
#            )
#        )


#    it 'Imports ZipCodes Mongoose', (done) ->
#        code = require('../models/code').model
#        repo = new MongooseRepostitory({}, code)
#        filename = './data/zipcodes.csv'
#        importer.import(filename, repo, (error, results) ->
## do a spot check:
#            repo.find(JSON.stringify({zip: '00210'}), (error, result) ->
#                zip = result.body[0]
#                zip.zip.should.be.equal('00210')
#                console.log(zip)
#                zip.city.should.be.equal('Portsmouth')
#                zip.state.should.be.equal('NH')
#                zip.latitude.should.be.equal('43.005895')
#                zip.longitude.should.be.equal('-71.013202')
#                zip.timezone.should.be.equal('-5')
#                zip.dst.should.be.equal('1')
#                # now check all the zipcodes
#                checkAllZipCodes(filename, repo, done)
#            )
#        )

