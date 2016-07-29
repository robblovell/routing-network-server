should = require('should')
assert = require('assert')

importer = require('../src/importers/importZipCodes')
async = require('async')

RedisRepostitory = require('../src/repositories/RedisRepository')
RestRepostitory = require('../src/repositories/RestRepository')
MongooseRepostitory = require('../src/repositories/MongooseRepository')
fs = require('fs');
Papa = require('babyparse')

describe 'Errata', () ->

    checkAllZipCodes_KeyValue = (filename, repo, done) =>
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data

        # function to get one zip code by id and check the result.
        make = (id) ->
            return (callback) ->
                repo.get(id, (error, result) ->
                    JSON.parse(result).zip.should.be.equal(id)
                    console.log(result)
                    callback(null, result)
                )

        getZipFuncs = []
        for zipcode,i in data
            continue if i == 0
            id = zipcode[0]
            getZipFuncs.push(make(id))

        async.parallelLimit(getZipFuncs, 1,
            (error, results) =>
                console.log('error'+error) if error
                done()
        )
        return

    checkAllZipCodes = (filename, repo, done) =>
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data

        # function to get one zip code by id and check the result.
        make = (id) ->
            return (callback) ->
                repo.find(JSON.stringify({zip: id}), (error, result) ->
                    result.body[0].zip.should.be.equal(id)
                    callback(null, result)
                )

        getZipFuncs = []
        for zipcode,i in data
            continue if i == 0
            id = zipcode[0]
            getZipFuncs.push(make(id))
#            break if i > 3

        async.parallelLimit(getZipFuncs, 1,
            (error, results) =>
                console.log('error'+error) if error
                done()
        )
        return

    it 'Imports ZipCodes Redis', (done) ->
        redisRepoConfig = {
            url: 'redis://127.0.0.1:6379/1'
        }
        repo = new RedisRepostitory(redisRepoConfig)
        filename = './data/zipcodes.csv'
        importer.importKeyValue(filename, repo, (error, results) ->
            # do a spot check:
            repo.get('85281', (error, result) ->
                zip = JSON.parse(result)
                zip.zip.should.be.equal('85281')
                console.log(zip)
                result.should.be.equal('{"zip":"85281","city":"Tempe","state":"AZ","latitude":"33.426885","longitude":"-111.92733","timezone":"-7","dst":"0"}')
                # now check all the zipcodes
                checkAllZipCodes_KeyValue(filename, repo, done)
            )

        )

#    it 'Imports ZipCodes Neo4j', (done) ->
#        redisRepoConfig = {
#            url: 'redis://127.0.0.1:6379/1'
#        }
#        repo = new Neo4jRepostitory(redisRepoConfig)
#        filename = './data/zipcodes.csv'
#        importer.importKeyValue(filename, repo, (error, results) ->
## do a spot check:
#            repo.get('85281', (error, result) ->
#                zip = JSON.parse(result)
#                zip.zip.should.be.equal('85281')
#                result.should.be.equal('{"zip":"85281","city":"Tempe","state":"AZ","latitude":"33.426885","longitude":"-111.92733","timezone":"-7","dst":"0"}')
#                # now check all the zipcodes
#                checkAllZipCodes_KeyValue(filename, repo, done)
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
#                checkAllZipCodes(filename, repo, done)
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

