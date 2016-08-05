### routing-network-server

A persistence layer for a routing network and mechanisms to determine minimum paths from one node to another.

To make this work:

Install neo4j locally.  Set the password for the 'neo4j' user to 'macro7'.
run 'npm install'
run 'npm start'

This will start the rest server.

To run imports from files to build the network, run the mocha tests in 'test_functional'.
Run the import tests first, then run the wireup tests. Imports upsert nodes into the network and 
Wireups upsert the edges between nodes.


The network consists of a warehouse node type where products or "items" can reside: **Warehouse, Resupplier, Seller, Sweeper, or Satellite**

The last mile of delivery is represented by a network of zip codes and ltl codes that are interconnected with costs.

Sku's or item nodes point to warehouses with edges that hold the amount of inventory at each warehouse.

The edge types between warehouses are: **Sweeps_to and Resupplies, Repositions_to**

Optimal query through different node types (old network query, todo:: new query):

```
MATCH p=(sweepNode)-[:SWEEPS_TO]->()-[:RESUPPLIES]->()-[:LEAF]->(consumer:Consumer) 
    WHERE sweepNode.kind = 'Sweeper' and sweepNode.inventory > 0.5
   WITH COLLECT(p) AS rows1

MATCH q=(fullNode)-[:LEAF]->(consumer:Consumer)
    WHERE  fullNode.inventory > 0 
   WITH rows1 + COLLECT(q) AS rows2

MATCH o=(fullNode)-[:RESUPPLIES]->()-[:LEAF]->(consumer:Consumer) 
    WHERE  fullNode.inventory > 0 
   WITH rows2 + COLLECT(o) AS rows3

UNWIND rows3 as rows
RETURN rows AS shortestPath, reduce(cost=0, r IN relationships(rows)| cost+r.cost) AS totalCost
ORDER BY totalCost ASC
LIMIT 10
```

TODO:
* REST endpoint for Routes
* Add  **satellites** to the model
* Other costs like time and distance (per item type)
* Fees for nodes (per item type)

