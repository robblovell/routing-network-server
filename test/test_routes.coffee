should = require('should')
assert = require('assert')
math = require('mathjs')

neo4j = require('neo4j-driver').v1
driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j','macro7'))

describe 'Errata', () ->

    id = 1
    routes = []
    superdcs = []
    warehouses = []
    sweep_sellers = []
    sellers = []
    consumer = {}
    all = []
    nodes = []
    edges = []
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
    buildGraph = (done) ->
        sku = '12345'

        nj = {id: 'NJ', name: 'NewJersey', location: 0, kind: 'Superdc', inventory: 25}
        atlanta = {id: 'Atlanta', name: 'Atlanta', location: 100, kind: 'Superdc', inventory: 25}
        dallas = {id: 'Dallas', name: 'Dallas', location: 50, kind: 'Superdc', inventory: 25}
        la = {id: 'LosAngeles', name: 'LosAngeles', location: 100, kind: 'Superdc', inventory: 25}
        seattle = {id: 'Seattle', name: 'Seattle', location: 100, kind: 'Superdc', inventory: 25}

        superdcs = [nj, atlanta, dallas, la, seattle]
        all = [nj, atlanta, dallas, la, seattle]

        for resupplier in superdcs
            for resupplied in superdcs
                if (resupplier != resupplied)
                    distance = math.abs(resupplier.location-resupplied.location)
                    cost = distance

                    route = { id: resupplier, source: resupplier, kind: 'resupplies', destination: resupplied, estimate: {  cost: cost, distance: distance } }
                    routes.push(route)
        warehouses = [nj, dallas, seattle]
        j=0
        for resupplier,k in superdcs
            if k < superdcs.length
                resupplier2 = superdcs[k+1]
            else
                resupplier2 = superdcs[0]

            for i in [0..1]
                decide = math.floor(math.random(-1000,1000))
            if (decide > 0)
                distance = math.floor(math.random(3,7))
            else
                distance = math.floor(math.random(-3,-7))
                location = math.floor(resupplier.location+ distance)
                distance = math.floor(math.abs(distance))
                cost = distance

                warehouse = {id: "Ware"+j, name: "Warehouse "+j, location: location, kind: 'Warehouse'}
                warehouses.push(warehouse)
                all.push(warehouse)

                route = { id: id++, source: resupplier, kind: 'resupplies', destination: warehouse, estimate: {  cost: cost, distance: distance } }
                routes.push(route)
                j+=1
                if (resupplier2?)
                    distance = math.floor(math.random(-12,12))
                    location = math.floor(resupplier2.location+ distance)
                    distance = math.floor(math.abs(distance))
                    cost = distance

                    warehouse = {id: "Ware"+j, name: "Warehouse "+j, location: location, kind: 'Warehouse'}
                    warehouses.push(warehouse)
                    all.push(warehouse)

                    route = { id: id++, source: resupplier2, kind: 'resupplies', destination: warehouse, estimate: {  cost: cost, distance: distance } }
                    routes.push(route)
                    j+=1


        j=100
        for warehouse, k in warehouses
            for i in [0..1]
                decide = math.floor(math.random(-1000,1000))
                if (decide > 0)
                    distance = math.floor(math.random(10,15))
                else
                    distance = math.floor(math.random(-10,-15))
                location = math.floor(warehouse.location+ distance)
                distance = math.floor(math.abs(distance))
                cost = distance
                seller = {id: 'Vend'+j, name: 'SweepSeller '+j, location: location, kind: 'Sweeper'}
                sweep_sellers.push(seller)
                all.push(seller)
                route = { id: id++, source: seller, kind: 'sweeps_to', destination: warehouse, estimate: {  cost: cost, distance: distance } }
                routes.push(route)

                j+= 10

        sellers = []
        j=1000
        for i in [0..100]
            inventory = 0
            if (i < 50)
                location = math.floor(math.random(1,19))
            else if (i > 50)
                location = math.floor(math.random(81,98))
            else
                location = 53
                inventory = 4
            if inventory > 0
                seller = {id: 'Sell'+j, name: 'Seller'+j, location: location, kind: 'Seller', inventory: inventory}
            else
                seller = {id: 'Sell'+j, name: 'Seller'+j, location: location, kind: 'Seller'}
            sellers.push(seller)
            all.push(seller)
            j+= 100

        consumer = {id: 'Robb', name: 'Robb Lovell', location: 48, kind: 'Consumer'}
        all.push(consumer)

        for node in all
            if (node != consumer)
                distance = math.floor(math.abs(node.location-consumer.location))
                cost = distance

                route = { id: id++, source: node, kind: 'leaf', destination: consumer, estimate: {  cost: cost, distance: distance } }
                routes.push(route)
                unless (node.inventory?)
                    node.inventory = math.floor(math.random(0,2))
            else
                node.inventory = 0
        for route in routes
            edges.push(route)

#        for node in superdcs
#            console.log(JSON.stringify(node))
#        for node in warehouses
#            console.log(JSON.stringify(node))
#        for node in sweep_sellers
#            console.log(JSON.stringify(node))
#        for node in sellers
#            console.log(JSON.stringify(node))
        console.log("------------------------------------------------------------------------------------------------")
        for edge in edges
            console.log("Edge: "+JSON.stringify(edge))
        console.log("------------------------------------------------------------------------------------------------")
        for node in all
            console.log("Node: "+JSON.stringify(node))
        console.log("------------------------------------------------------------------------------------------------")
        session = driver.session()
        tx = session.beginTransaction()
        for node in all
            console.log("CREATE NODE: "+JSON.stringify(node))
            nodeStr = "CREATE (Node:"+node.kind+" {id: {id}, name: {name}, location: {location}, kind: {kind}, inventory: {inventory}})"
            tx.run(nodeStr, node)

        tx.commit().subscribe({
            onCompleted: () ->
                console.log("------------------------------------------------------------------------------------------------")
                session.close()
                session2 = driver.session()
                tx2 = session2.beginTransaction()

                for edge in edges
                    params = {
                        sourcekind: edge.source.kind
                        sourcename: edge.source.name
                        destinationkind: edge.destination.kind
                        destinationname: edge.destination.name
                        kind: edge.kind
                        cost: edge.estimate.distance
                    }
                    matchStr =
                        "CREATE EDGE: MATCH (a:"+params.sourcekind+" {name: "+params.sourcename+"}), (b:"+params.destinationkind+" {name: "+params.destinationname+
                               "}) CREATE (a)-[rel:"+params.kind.toUpperCase()+ " {kind: {"+params.kind+"}, cost: "+params.cost+"}]->(b) RETURN rel"
                    console.log(matchStr)
                    match =
                        "MATCH (a:"+params.sourcekind+" {name:{sourcename}}), (b:"+params.destinationkind+" {name:{destinationname}})
                        CREATE (a)-[rel:"+params.kind.toUpperCase()+ " {kind: {kind}, cost: {cost}}]->(b)
                        RETURN rel"
                    tx2.run(match,params)

                    console.log("------------------------------------------------------------------------------------------------")

                tx2.commit().subscribe({
                    onCompleted: () ->
                        # Completed!
                        console.log("completed")
                        session2.close()
                        done()
                    ,
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

    before (done) ->
        deleteGraph(()->
            buildGraph(()->
                done()
            )
        )

    it 'Finds shortest route', (done) ->

        done()





