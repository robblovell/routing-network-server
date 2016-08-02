### routing-network-server

A persistence layer for a routing network and mechanisms to determine minimum paths from one node to another.

The network consists of six node types where products or "items" can reside: **Warehouse, Resupplier, Seller, Sweeper, Consumer**

And one node type that represents an item: **Item** (still to be modeled)

There are three edge types: **Sweeps_to, Resupplies, Leaf**

Optimal query through different node types:

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
* REST interface hooked to the graph database
* REST endpoint for Routes
* Add **items** and **satellites** to the model
* Queries for Consolidated routes
* 2D locations 
* Other costs like time and distance (per item type)
* Cost breakdowns between sellers, retailer, and consumer (per item type)
* Fees for nodes (per item type)

