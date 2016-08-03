should = require('should')
assert = require('assert')
async = require('async')

Neo4jRepostitory = require('../src/repositories/Neo4jRepository')

builder = require('../src/importers/buildEdges')

describe 'Build Edges', () ->

    checkAllEdges = (filename, repo, done) =>
        done()
        return

    it 'Wires Up All Edges.', (done) ->

        repoConfig = { user: 'neo4j', pass: 'macro7' }
        repo = new Neo4jRepostitory(repoConfig)
        builder.setRepo(repo)
        builder.buildZipsToLtlCodes((error, results) ->
            if (error?)
                console.log(error)
                assert(false)
                done(); return
            # do a spot check:
            repo.get({id: '15000_1500_2500', type: 'LtlCode'}, (error, result) ->
                if (error?)
                    assert(false)
                    done(); return
                data = JSON.parse(result)
                data.ltlCode.should.be.equal('15000')
                data.weightLo.should.be.equal('1500')
                data.weightHi.should.be.equal('2500')

                # now check all the nodes
                checkAllNodes(filename, repo, done)
                return
            )
            return

        )

