——— Best

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
LIMIT 20

