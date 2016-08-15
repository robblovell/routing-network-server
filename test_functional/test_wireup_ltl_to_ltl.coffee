should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

builder = require('../src/importers/edges/LtlsToLtls')

describe 'Build Edges', () ->

    it 'Wires Up LtlCodes to LtlCodes', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        builder.setRepo(repo)
        builder.buildLtlToLtl((error, results) ->
            if (error?)
                console.log(error)
                assert(false)
                done(); return
            return
        )
        return


