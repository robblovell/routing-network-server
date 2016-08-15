should = require('should')
assert = require('assert')
math = require('mathjs')
async = require('async')
neo4j = require('neo4j-driver').v1
#driver = neo4j.driver('bolt://sb10.stations.graphenedb.com:24786', neo4j.auth.basic('network','3n6CUgoYeboY0PYjHLaa'))
driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j','macro7'))
describe 'Delete Graph', () ->

    deleteGraph = (done) ->
        session = driver.session()
        tx = session.beginTransaction()

        console.log("Delete edges")
        tx.run("MATCH ()-[r]->() DELETE r")
        console.log("Delete nodes")
        tx.run("MATCH (n) delete n")
        tx.commit().subscribe({
            onCompleted: () ->
                console.log("delete completed")
                session.close()
                done()
            ,
            onError: (error) ->
                console.log(error)
                session.close()
                done()
        })

    it 'deleting graph', (done) ->
        deleteGraph(()->
            done()
        )