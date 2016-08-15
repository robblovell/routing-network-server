should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

Builder = require('../src/importers/edges/LtlsToLtls')
builder = new Builder()
describe 'Link Ltl to Ltl Costs', () ->

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


