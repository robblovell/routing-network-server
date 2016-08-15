should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

Builder = require('../src/importers/edges/SkusToWarehouses')
builder = new Builder()

describe 'Build Sku Inventories', () ->

    it 'Wires Up Skus to Warehouses', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        builder.setRepo(repo)
        builder.buildSkusToWarehouses((error, results) ->
            if (error?)
                console.log(error)
                assert(false)
            done();
            return
        )
        return


