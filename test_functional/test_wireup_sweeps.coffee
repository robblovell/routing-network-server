should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

Builder = require('../src/importers/edges/SweepsToWarehouses')
builder = new Builder()
describe 'Setup Seller Sweeps to Warehouses', () ->

    it 'Wires Up Sweeps', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        builder.setRepo(repo)
        builder.buildSweepsToWarehouses((error, results) ->
            if (error?)
                console.log(error)
                assert(false)
            done();
            return
        )
        return


