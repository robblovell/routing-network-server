should = require('should')
assert = require('assert')
sinon = require('sinon')
neo4j = require('neo4j-driver').v1

Repo = require('../src/repositories/Neo4jRepository')
describe 'Build Simple Graph', () ->

    spy = null
    before (done) ->
        sinon.stub(neo4j,"driver")
        neo4j.driver = sinon.stub().returns(42)
        repo = new Repo({url: "bolt://user:pass@localhost"})
        done()
        return

    it 'constructs', (done) ->
        repo.config.url.should.be.equal("bolt://localhost")
        repo.config.user.should.be.equal("user")
        repo.config.pass.should.be.equal("pass")
        assert(neo4j.driver.called)
        repo.neo4j.should.not.be.null
        done()

    it 'gets', (done) ->

