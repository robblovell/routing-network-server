#should = require('should')
#assert = require('assert')
#
#importer = require('../src/importers/importLtlCodes')
#async = require('async')
#
#Neo4jRepostitory = require('../src/repositories/Neo4jRepository')
#fs = require('fs');
#Papa = require('babyparse')
#
#describe 'Import LtlCodes', () ->
#
#    checkAllNodes = (filename, repo, done) =>
#        contents = fs.readFileSync(filename, 'utf8')
#        result = Papa.parse(contents, @config)
#        data = result.data
#
#        # function to get one zip code by id and check the result.
#        make = (id, type) ->
#            return (callback) ->
#                repo.get({id: id, type: type}, (error, result) ->
#                    JSON.parse(result).id.should.be.equal(id)
#
#                    callback(null, result)
#                    return
#                )
#
#        getFuncs = []
#        for node,i in data
#            continue if i == 0 # don't look at the header.
#            id = (v for v in node).reduce((x,y) -> ""+x+"_"+y)
#
#            if (id != "")
#                getFuncs.push(make(id, 'LtlCode'))
#
#        async.parallelLimit(getFuncs, 1,
#            (error, results) =>
#                if error?
#                    console.log('error'+error)
#                    assert(false)
#
#                done()
#                return
#        )
#        return
#
#    it 'Imports LtlCodes Neo4j', (done) ->
#        repoConfig = { user: 'neo4j', pass: 'macro7' }
#        repo = new Neo4jRepostitory(repoConfig)
#        filename = './data/weights-codes.csv'
#        importer.import(filename, repo, (error, results) =>
#            if (error?)
#                console.log(error)
#                assert(false)
#                done(); return
#            # do a spot check:
#            repo.get({id: '15000_1500_2500', type: 'LtlCode'}, (error, result) =>
#                if (error?)
#                    assert(false)
#                    done(); return
#                data = JSON.parse(result)
#                data.ltlCode.should.be.equal('15000')
#                data.weightLo.should.be.equal('1500')
#                data.weightHi.should.be.equal('2500')
#
#                # now check all the nodes
#                checkAllNodes(filename, repo, done)
#                return
#            )
#            return
#
#        )
#        return
#
