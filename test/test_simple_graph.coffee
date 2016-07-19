#should = require('should')
#assert = require('assert')
#math = require('mathjs')
#
#neo4j = require('neo4j-driver').v1
#driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j','macro7'))
#
#describe 'Errata', () ->
#
#    id = 1
#    nodes = []
#    edges = []
#    deleteGraph = (done) ->
#        session = driver.session()
#        tx = session.beginTransaction()
#
#        console.log("Delete edges")
#        tx.run("MATCH ()-[r]->() DELETE r")
#        console.log("Delete nodes")
#        tx.run("MATCH (n) delete n")
#        tx.commit().subscribe({
#            onCompleted: () ->
#                console.log("delete completed")
#                session.close()
#                done()
#            ,
#            onError: (error) ->
#                console.log(error)
#                session.close()
#                done()
#        })
#
#    buildGraph = (done) ->
#        nodes.push( {id: "Emil", name: "Emil" } )
#        nodes.push( {id: "Ian", name: "Ian" } )
#        nodes.push( {id: "Jim", name: "Jim" } )
#
#        edges.push({ id: id++, source: nodes[1], destination: nodes[0], cost: 1 })
#        edges.push({ id: id++, source: nodes[2], destination: nodes[0], cost: 2 })
#        edges.push({ id: id++, source: nodes[2], destination: nodes[1], cost: 4 })
#
#        console.log("------------------------------------------------------------------------------------------------")
#        for edge in edges
#            console.log("Edge: "+JSON.stringify(edge))
#        console.log("------------------------------------------------------------------------------------------------")
#        for node in nodes
#            console.log("Node: "+JSON.stringify(node))
#        console.log("------------------------------------------------------------------------------------------------")
#        session = driver.session()
#        tx = session.beginTransaction()
#        for node in nodes
#            console.log("CREATE NODE :Person "+JSON.stringify(node))
#            tx.run("CREATE (Node:Person {id:{id}, name:{name}})", node)
#
#        tx.commit().subscribe({
#            onCompleted: () ->
#                console.log("------------------------------------------------------------------------------------------------")
#                session.close()
#                session2 = driver.session()
#                tx2 = session2.beginTransaction()
#                for edge in edges
#                    params = {
#                        source: edge.source.name
#                        destination: edge.destination.name
#                        cost: edge.cost
#                    }
#                    matchStr =
#                        "CREATE EDGE: MATCH (p1:Person {name: "+params.source+"}), (p2:Person {name: "+params.destination+"})
#                                CREATE (p1)-[rel:KNOWS {cost: "+params.cost+"}]->(p2)
#                                RETURN rel"
#                    match =
#                        "MATCH (a:Person {name:{source}}), (b:Person {name:{destination}})
#                        CREATE (a)-[rel:KNOWS {cost:{cost}}]->(b)
#                        RETURN rel"
#                    console.log(matchStr)
#                    tx2.run(match,params)
#
#                tx2.commit().subscribe({
#                    onCompleted: () ->
#                        console.log("Complete")
#                        done()
#                    onError: (error) ->
#                        console.log(error)
#                        session2.close()
#                        done()
#                })
#            ,
#            onError: (error) ->
#                console.log(error)
#                session.close()
#                done()
#        })
#
#
#
#        console.log("------------------------------------------------------------------------------------------------")
#
#
#    before (done) ->
#        deleteGraph(()->
#            buildGraph(()->
#                done()
#            )
#        )
#
#    it 'Finds shortest route', (done) ->
#
#        done()
#
#
#
#
#
