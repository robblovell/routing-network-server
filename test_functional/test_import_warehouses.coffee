should = require('should')
assert = require('assert')

importer = require('../src/importers/importWarehouses')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')
fs = require('fs');
Papa = require('babyparse')

describe 'Import Warehouses', () ->

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
            getFuncs.push(make(id, 'Warehouse'))

        async.parallelLimit(getFuncs, 1,
            (error, results) =>
                console.log('error'+error) if error
                done()
                return
        )
        return

    it 'Imports Warehouses Neo4j', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        filename = './data/warehouses.csv'
        importer.import(filename, repo, (error, results) ->
            if (error?)
                console.log(error)
                assert(false)
                done(); return
            # do a spot check:
            repo.get({id: '2000502', type: 'Warehouse'}, (error, result) ->
                if (error?)
                    assert(false)
                    done(); return
                data = JSON.parse(result)
                data.id.should.be.equal('2000502')

                # now check all the nodes
                checkAllNodes(filename, repo, done)
                return
            )
            return

        )

