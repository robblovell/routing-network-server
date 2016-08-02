should = require('should')
assert = require('assert')
math = require('mathjs')
uuid = require('uuid')
neo4j = require('neo4j-driver').v1
driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j','macro7'))

describe 'Test Routes', () ->

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


    makeUpsert = (data) ->
        data.id = uuid.v4() unless (data.id?)
        properties = (("n."+key+" = {"+key+"}, ") for key,value of data).reduce((t,s) -> t + s)
        properties = properties.slice(0,-2) # remove the trailing comma.
        create = "n.created=timestamp(), "+properties
        update = "n.updated=timestamp(), "+properties
        #         1234567890123456789012345678901234567890

        upsertStatement = "MERGE (n:#{data.type} { id: {id} }) ON CREATE SET "+
            create+
            " ON MATCH SET "+
            update

        return [data, upsertStatement]


    makeIdNode = () ->
        makeStatement = makeUpsert({id:id})
        return makeStatement

    buildGraph = (done) ->

#        tx = session.beginTransaction()
#        tx.run(upsert, props)
#
#        tx.commit().subscribe({
#                onCompleted: (result) ->
#
#            })


        props = { type: "Test", prop1: "x", prop2: "z" }
        [data, upsert] = makeUpsert(props)

#        upsert = " MERGE (n) ON CREATE SET "+create+" ON MATCH SET "+update
        console.log("12345678901234567890123456789012345678901234567890123456789012345678901234567890")
        console.log(upsert)
        session = driver.session()
        tx = session.beginTransaction()
        tx.run(upsert, data)

        tx.commit().subscribe({
            onCompleted: (result) ->
                session.close()

                session2 = driver.session()
                tx2 = session2.beginTransaction()
                props = {type: "Test", id: data.id, prop1: "231", prop2: "1000" }

                tx2.run(upsert, props)

                tx2.commit().subscribe({
                    onCompleted: () ->
                        session2.close()

                        done()
                    onError: (error) ->
                        console.log(error)
                        session2.close()
                        done()
                })
            ,
            onError: (error) ->
                console.log(error)
                session.close()
                done()
        })

    it 'upserts', (done) ->
        deleteGraph(() ->
            buildGraph(done)
        )

