should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

Builder = require('../src/importers/edges/ResuppliersToWarehouses')

builder = new Builder()
describe 'Wire up Resuplliers (SuperDC\'s)', () ->

    it "Wires Up Resuppliers (SuperDc's)", (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        builder.setRepo(repo)
        builder.buildResuppliersToWarehouses((error, results) ->
            if (error?)
                console.log(error)
                assert(false)
            done();
            return
        )
        return


