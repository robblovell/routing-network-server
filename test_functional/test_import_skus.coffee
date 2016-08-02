should = require('should')
assert = require('assert')

importer = require('../src/importers/importSkus')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')
fs = require('fs');
Papa = require('babyparse')

describe 'Import Skus', () ->

    checkAllNodes = (filename, repo, done) =>
        contents = fs.readFileSync(filename, 'utf8')
        result = Papa.parse(contents, @config)
        data = result.data

        # function to get one zip code by id and check the result.
        make = (id, type) ->
            return (callback) ->
                repo.get({id: id, type: type}, (error, result) ->
                    JSON.parse(result).id.should.be.equal(id)

                    callback(null, result)
                    return
                )

        getFuncs = []
        for node,i in data
            continue if i == 0 # don't look at the header.
            id = node[0]
            if (id != "")
                getFuncs.push(make(id, 'Sku'))

        async.parallelLimit(getFuncs, 1,
            (error, results) =>
                if error?
                    console.log('error'+error)
                    assert(false)

                done()
                return
        )
        return

    it 'Imports Skus Neo4j', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        filename = './data/skus.csv'
        importer.importKeyValue(filename, repo, (error, results) ->
            if (error?)
                console.log(error)
                assert(false)
                done(); return
            # do a spot check:
            repo.get({id: '1', type: 'Sku'}, (error, result) ->
                if (error?)
                    assert(false)
                    done(); return
                data = JSON.parse(result)
                data.id.should.be.equal('1')
                data.sku.should.be.equal('1000000')
                data.weight.should.be.equal('10')

                # now check all the nodes
                checkAllNodes(filename, repo, done)
                return
            )
            return

        )

