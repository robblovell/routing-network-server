should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

builder = require('../src/importers/buildEdges')

describe 'Build Edges', () ->

    it 'Wires Up ZipCodes to LtlCodes.', (done) ->
        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        builder.setRepo(repo)
        builder.buildZipsToLtls((error, results) ->
            if (error?)
                console.log(error)
                assert(false)
            done()
            return
        )

#    it 'Wires Up LtlCodes to LtlCodes', (done) ->
#        repoConfig = { user: 'neo4j', pass: 'macro7' }
#        repo = new Neo4jRepostitory(repoConfig)
#        builder.setRepo(repo)
#        builder.buildLtlCodesToLtlCodes((error, results) ->
#            if (error?)
#                console.log(error)
#                assert(false)
#                done(); return
#            return
#        )
#        return


