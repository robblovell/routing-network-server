should = require('should')
assert = require('assert')
math = require('mathjs')
async = require('async')
neo4j = require('neo4j-driver').v1
driver = neo4j.driver('bolt://sb10.stations.graphenedb.com:24786', neo4j.auth.basic('network','3n6CUgoYeboY0PYjHLaa'))
#driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j','macro7'))
describe 'Build Simple Graph', () ->

    id = 1
    routes = []
    superdcs = []
    warehouses = []
    sweep_sellers = []
    sellers = []
#    consumer = {}
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
    costDistance = (node_location, decision, low, high) ->
        decide = math.floor(math.random(-decision,decision))
        if (decide > 0)
            distance = math.floor(math.random(low,high))
        else
            distance = math.floor(math.random(-low,-high))
        location = math.floor(node_location + distance)
        location = node_location + 1 if location < 1
        location = node_location - 1 if location > 100

        distance = math.floor(math.abs(distance))
        cost = distance
        return [location, cost, distance]

    makeSkuRoute = (id, source, kind, destination, inventory) ->
        return { id: id, source: source, kind: 'sku', destination: destination, inventory: inventory  }


    buildResuppliers = (callback) ->
        nj = {id: 'nj', name: 'newjersey', location: 0, kind: 'superdc', inventory: 25, type: 'Superdc' }
#        atlanta = {id: 'atlanta', name: 'atlanta', location: 10, kind: 'superdc', inventory: 25, type: 'Warehouse' }
        dallas = {id: 'dallas', name: 'dallas', location: 50, kind: 'superdc', inventory: 25, type: 'Superdc' }
        la = {id: 'losangeles', name: 'losangeles', location: 90, kind: 'superdc', inventory: 25, type: 'Superdc' }
#        seattle = {id: 'Seattle', name: 'Seattle', location: 100, kind: 'Superdc', inventory: 25, type: 'Warehouse' }
        resuppliers = [nj, dallas, la]#, seattle]
        superdcs = [nj, dallas, la]#, seattle]
        warehouses = [dallas, la]#, seattle]
        all = [nj, dallas, la]#, seattle]
        callback(null, { superdcs: resuppliers, resuppliers: resuppliers, warehouses: warehouses, all: all})

    buildResupplierRoutes = (args, callback) ->
        routes = []
        superdcs = args.resuppliers
        for resupplier in superdcs
            for resupplied in superdcs
                if (resupplier != resupplied)
                    distance = math.abs(resupplier.location-resupplied.location)
                    cost = distance
                    route = makeRoute(resupplier, resupplier, 'resupplies', resupplied, cost, distance)

                    routes.push(route)

        args.routes = routes
        callback(null, args)

    buildWarehouses = (args, callback) ->
        j=0
        superdcs = args.superdcs
        warehouses = args.warehouses
        routes = args.routes
        all = args.all
        warehousesPerSuperDC = 3
        for resupplier,k in superdcs
            if k < superdcs.length
                resupplier2 = superdcs[k+1]
            else
                resupplier2 = superdcs[0]

            for i in [1..warehousesPerSuperDC]
                [location, cost, distance] = costDistance(resupplier.location,1000, 3, 7)

                warehouse = {id: "ware"+j, name: "warehouse "+j, location: location, kind: 'warehouse', type: 'Warehouse' }
                warehouses.push(warehouse)
                all.push(warehouse)

                route = makeRoute(id++, resupplier, 'resupplies', warehouse, cost, distance)
                routes.push(route)
                j+=1
                if (resupplier2?)
                    distance = math.floor(math.random(-12,12))
                    location = math.floor(resupplier2.location+ distance)
                    distance = math.floor(math.abs(distance))
                    cost = distance

                    warehouse = {id: "ware"+j, name: "warehouse "+j, location: location, kind: 'warehouse', type: 'Warehouse' }
                    warehouses.push(warehouse)
                    all.push(warehouse)
                    route = makeRoute(id++, resupplier2, 'resupplies', warehouse, cost, distance)
                    routes.push(route)
                    j+=1

        callback(null, args)

    buildSellerSweepersNRoutes = (args, callback) ->
        j=100
        warehouses = args.warehouses
        all = args.all
        routes = args.routes
        sweep_sellers = []
        sweepersPerWarehouse = 1
        for warehouse, k in warehouses
            for i in [1..sweepersPerWarehouse]
                [location, cost, distance] = costDistance(warehouse.location,1000, 10, 15)

                seller = {id: 'vend'+j, name: 'sweepSeller '+j, location: location, kind: 'sweeper', type: 'Sweeper' }
                sweep_sellers.push(seller)
                all.push(seller)
                route = makeRoute(id++, seller, 'sweeps_to', warehouse, cost, distance)

                routes.push(route)

                j+= 10
        args.sweep_sellers = sweep_sellers
        callback(null, args)

    buildSellers = (args, callback) ->
        all = args.all

        numSellers = 3
        sellers = []
        j=1000
        for i in [0..100] by 100/numSellers
            inventory = 0
            if (i < 50)
                location = math.floor(math.random(1,27))
            else if (i > 50)
                location = math.floor(math.random(72,98))
            else
                location = 53
                inventory = 4

            seller = {id: 'sell'+j, name: 'seller'+j, location: location, kind: 'seller', inventory: inventory, type: 'Seller' }

            sellers.push(seller)
            all.push(seller)
            j+= 100

        args.sellers = sellers
        callback(null, args)

    buildEdgesNInventory = (args, callback) ->
        all = args.all
        routes = args.routes
        zips = args.zips
#        consumer = args.consumer
        edges = []
        console.log("warehouse edges")
        for node in all
            for zip in zips
#            if (node != consumer)
                distance = math.floor(math.abs(node.location-zip.location))
                cost = distance

                route = makeRoute(id++, node, 'leaf', zip, cost, distance)

                routes.push(route)
                unless (node.inventory?)
                    node.inventory = math.floor(math.random(0,2))
#            else
#                node.inventory = 0

        callback(null, args)

    buildZips = (args, callback) ->
        zips = []
        weights = []
        all = args.all
        ix = 0
        numzips = 3
        numweights = 3

        makezip = (zipnum, location, weight, distance) ->
            return {
                id: zipnum+weight,
                kind: 'zip',
                type: 'Zip'
                zip: zipnum,
                name: ''+zipnum+weight,
                city:"city_"+i,
                state: String.fromCharCode(65+i*2)+String.fromCharCode(65+i*2+1),
                latitude:""+location,
                longitude:""+(location+distance),
                location: ""+location,
                timezone:"-"+(4+math.floor(i/2)),
                dst:""+math.floor(i/4),
                code: weight,
                lo: weight,
                hi: weight+100
            }

        console.log("weights and zips")
        for weightfactor in [0...numweights]
            weight = 100*weightfactor
            weights.push({weight: weight, zips: []})

            for i in [0...numzips]
                distance = math.floor(100/numzips)+1
                location = distance * i

                zipnum = 20000*i
                zip = makezip(zipnum, location, weight, distance)
#                console.log(JSON.stringify(zip))
                zips.push(zip)

                weights[ix].zips.push(zip)
            ix++


        args.zips = zips
        args.weights = weights
        callback(null, args)

    makeRoute = (id, source, kind, destination, cost, distance) ->
        return { id: id, source: source, kind: kind, destination: destination, estimate: {  cost: cost, distance: distance }, type: kind }

    buildZipRelationships = (args, callback) ->
        all = args.all
        routes = args.routes
        weights = args.weights

        console.log("zip->zip(zip-weight)")
        for weightclass in weights
            weight = weightclass.weight
            for zip1 in weightclass.zips
                for zip2 in weightclass.zips
                    distance = math.floor(math.abs(zip1.location-zip2.location)) * weight/500
                    cost = distance
                    route = { id: id++, source: zip1, kind: 'zip', destination: zip2, estimate: {  cost: cost, distance: distance } }
#                    console.log(JSON.stringify(route))
                    routes.push(route)

        callback(null, args)
        return

    buildSKUS = (args, callback) ->
        skus = []
        numSkus = 3
        all = args.all
        console.log("SKUS")
        for i in [1..numSkus]

            skunum = i*300000
            sku = {
                id: skunum,
                kind: 'sku',
                sku: skunum,
                name: ''+skunum
                type: 'Sku'
            }
#            console.log(JSON.stringify(sku))
            skus.push(sku)
        args.skus = skus
        callback(null, args)

    buildSKURelationships = (args, callback) ->
        skus = args.skus
        all = args.all
        routes = args.routes
        console.log("SKU to node")
        for node in all
            if node.kind != 'consumer'
                for sku in skus
                    inventory = math.floor(math.random(0,10))
                    if inventory > 0
                        route = makeSkuRoute(id, sku, 'sku', node, inventory)
                        routes.push(route)


        callback(null, args)
        return

    buildGraph = (callback1) ->

        async.waterfall([
            (callback2) ->
                buildResuppliers(callback2) # super dc cases
        ,
            (args3, callback3) ->
                buildResupplierRoutes(args3, callback3)
        ,
            (args4, callback4) ->
#                consumer = {id: 'Customer', name: 'Customer', location: 48, kind: 'Consumer', inventory: 0}
#                args4.consumer = consumer
#                args4.all.push(consumer)
                buildWarehouses(args4, callback4)
        ,
            (args5, callback5) ->
                buildSellerSweepersNRoutes(args5, callback5)
        ,
            (args6, callback6) ->
                buildSellers(args6, callback6)
        ,
            (args, callback) ->
                buildZips(args, callback)
        ,
            (args, callback) ->
                buildZipRelationships(args, callback)
        ,
            (args, callback) ->
                buildEdgesNInventory(args, callback)
        ,
            (args, callback) ->
                buildSKUS(args, callback)
        ,
            (args, callback) ->
                buildSKURelationships(args, callback)
        ,
            (args10, callback10) ->
                persistGraph(args10, callback10)
        ],
        (error, result) ->
            callback1(error, result)
            return
        )

    persistGraph = (args, callback) ->
        all = args.all
        superdcs = args.superdcs
        warehouses = args.warehouses
        routes = args.routes
        edges = args.routes
        skus = args.skus
        zips = args.zips
#        for node in superdcs
#            console.log(JSON.stringify(node))
#        for node in warehouses
#            console.log(JSON.stringify(node))
#        for node in sweep_sellers
#            console.log(JSON.stringify(node))
#        for node in sellers
#            console.log(JSON.stringify(node))
#        console.log("------------------------------------------------------------------------------------------------")
#        for edge in edges
#            console.log("Edge: "+JSON.stringify(edge))
#        console.log("------------------------------------------------------------------------------------------------")
#        for node in all
#            console.log("Node: "+JSON.stringify(node))
#        console.log("------------------------------------------------------------------------------------------------")
        session = driver.session()
        tx = session.beginTransaction()

        for sku in skus
            skuString = "CREATE (:Sku {id: #{sku.id}, sku: '#{sku.sku}', kind: '#{sku.kind}', name: '#{sku.name}')"

#            console.log(skuString)
            skuStr = "CREATE (:Sku {id: {id}, sku: {sku}, kind: {kind}, name: {name} })"

            tx.run(skuStr, sku)

        for zip in zips
            zipString = "CREATE (:Zip {id: #{zip.id}, zip: #{zip.zip}, city: '#{zip.city}', state: '#{zip.state}'
                latitude: #{zip.latitude}, longitude: #{zip.longitude}, location: #{zip.location},
                timezone: #{zip.timezone}}, dst: #{zip.dst}, kind: '#{zip.kind}', name: '#{zip.name}')"

            # cost: {code: "1", lo: weight, hi: weight+99}
            console.log(zipString)
            zipStr = "CREATE (:Zip {id: {id}, zip: {zip}, city: {city}, state: {state},
                latitude: {latitude}, longitude: {longitude}, location: {location},
                timezone: {timezone}, dst: {dst}, kind: {kind}, name: {name}, lo: {lo}, hi: {hi}, code: {code} })"

            tx.run(zipStr, zip)

        for node in all
            nodeString = "CREATE (:#{node.type} {id: '#{node.id}', name: '#{node.name}', location: #{node.location},
                  kind: '#{node.kind}', inventory: #{node.inventory}})"
            console.log(nodeString)

            nodeStr = "CREATE (:#{node.type} {id: {id}, name: {name}, location: {location}, kind: {kind}, inventory: {inventory}})"
            tx.run(nodeStr, node)

        tx.commit().subscribe({
            onCompleted: () ->
#                console.log("------------------------------------------------------------------------------------------------")
                session.close()
                session2 = driver.session()
                tx2 = session2.beginTransaction()

                for edge in edges
                    if (edge.kind == 'sku')
                        params = {
                            sourcekind: edge.source.type
                            sourcename: edge.source.name
                            destinationkind: edge.destination.type
                            destinationname: edge.destination.name
                            kind: edge.kind
                            inventory: edge.inventory
                        }
                        matchStr =
                            "MATCH (a:"+params.sourcekind+" {name: "+params.sourcename+"}), (b:"+params.destinationkind+" {name: "+params.destinationname+
                                "}) CREATE (a)-[rel:"+params.kind.toUpperCase()+ " {kind: {"+params.kind+"}, inventory: "+params.inventory+"}]->(b) RETURN rel"
                        match =
                            "MATCH (a:"+params.sourcekind+" {name:{sourcename}}), (b:"+params.destinationkind+" {name:{destinationname}})
                            CREATE (a)-[rel:"+params.kind.toUpperCase()+ " {kind: {kind}, inventory: {inventory}}]->(b)
                            RETURN rel"
                    else
                        params = {
                            sourcekind: edge.source.type
                            sourcename: edge.source.name
                            destinationkind: edge.destination.type
                            destinationname: edge.destination.name
                            kind: edge.kind
                            cost: edge.estimate.distance
                        }

                        matchStr =
                            "MATCH (a:"+params.sourcekind+" {name: "+params.sourcename+"}), (b:"+params.destinationkind+" {name: "+params.destinationname+
                                   "}) CREATE (a)-[rel:"+params.kind.toUpperCase()+ " {kind: {"+params.kind+"}, cost: "+params.cost+"}]->(b) RETURN rel"
                        match =
                            "MATCH (a:"+params.sourcekind+" {name:{sourcename}}), (b:"+params.destinationkind+" {name:{destinationname}})
                            CREATE (a)-[rel:"+params.kind.toUpperCase()+ " {kind: {kind}, cost: {cost}}]->(b)
                            RETURN rel"
                    console.log(matchStr)

                    tx2.run(match,params)

#                    console.log("------------------------------------------------------------------------------------------------")

                tx2.commit().subscribe({
                    onCompleted: () ->
                        # Completed!
                        console.log("completed")
                        session2.close()
                        callback(null, args)
                        return
                    ,
                    onError: (error) ->
                        console.log(error)
                        session2.close()
                        callback(error, args)
                        return
                })

            ,
            onError: (error) ->
                console.log(error)
                session.close()
                callback(error, args)
                return
        })

    it 'builds simple graph with warehouses, zipcodes', (done) ->
        deleteGraph(()->
            buildGraph((error, result)->
                done()
            )
        )







