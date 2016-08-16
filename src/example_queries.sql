
MATCH p=(sweepNode)-[:SWEEPS_TO]->()-[:RESUPPLIES]->()-[:LEAF]->(consumer:Consumer)
	WHERE sweepNode.kind = 'Sweeper' and sweepNode.inventory > 0
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



MATCH r=(item:Sku)-[sku:SKUWAREHOUSE]->(warehouse) WHERE item.sku = '1000000' and sku.inventory > 3
MATCH (needsResupply) WHERE needsResupply.inventory = 0

MATCH p=(item:Sku)-[sku:SKUWAREHOUSE]->(warehouse)-[:SWEEP]->()-[:RESUPPLIES]->()-[:WAREHOUSEZIP]->(:Zip)-[:ZIPLTL]->(ltl1:Ltl)-[:LTL]->(ltl2:Ltl)-[:LTLZIP]->(consumer:Zip)omni
WHERE warehouse.isSeller= true and item.sku = '1000000' and sku.inventory > 1 and
toInt(ltl1.weightLo) < 140 and 140 < toInt(ltl1.weightHi) and ltl1.ltlCode = '1000' and
toInt(ltl2.weightLo) < 140 and 140 < toInt(ltl2.weightHi) and ltl2.ltlCode = '1000' and
consumer.zip3 = '852' return p LIMIT 10

# where is item in stock.
MATCH p=(item:Sku)-[sku:SKUWAREHOUSE]->(warehouse)-[:WAREHOUSEZIP]->(:Zip)-[:ZIPLTL]->(ltl1:Ltl)
WHERE  item.sku = '1000000' and sku.inventory > 0 and
toInt(ltl1.weightLo) < 140 and 140 < toInt(ltl1.weightHi) and ltl1.ltlCode = '1000'
return p LIMIT 10

MATCH p=(item:Sku)-[sku:SKUWAREHOUSE]->(warehouse)-[:WAREHOUSEZIP]->(:Zip)-[:ZIPLTL]->(ltl1:Ltl)-[:LTL]->(ltl2:Ltl)-[:LTLZIP]->(consumer:Zip)
WHERE warehouse.isSeller= true and item.sku = '1000000' and sku.inventory > 1 and
toInt(ltl1.weightLo) < 140 and 140 < toInt(ltl1.weightHi) and ltl1.ltlCode = '1000' and
toInt(ltl2.weightLo) < 140 and 140 < toInt(ltl2.weightHi) and ltl2.ltlCode = '1000' and
consumer.zip3 = '138' return p LIMIT 10

MATCH p=(item:Sku)-[sku:SKUWAREHOUSE]->(warehouse)-[:SWEEP]->()-[:RESUPPLIES]->()-[:WAREHOUSEZIP]->(:Zip)-[:ZIPLTL]->(ltl1:Ltl)-[:LTL]->(ltl2:Ltl)-[:LTLZIP]->(consumer:Zip)
WHERE warehouse.isSeller= true and item.sku = '1000000' and sku.inventory > 1 and
toInt(ltl1.weightLo) < 140 and 140 < toInt(ltl1.weightHi) and ltl1.ltlCode = '1000' and
toInt(ltl2.weightLo) < 140 and 140 < toInt(ltl2.weightHi) and ltl2.ltlCode = '1000' and
consumer.zip3 = '852' return p LIMIT 10


MATCH c=(consumer:Zip) WHERE consumer.zip3='852'
MATCH p=(item:Sku)-[sku:SKUWAREHOUSE]->(warehouse)-[:SWEEP]->()-[:RESUPPLIES]->()-[:WAREHOUSEZIP]->(consumer:Zip)
WHERE item.sku = '1000000' and sku.inventory > 3 and consumer.zip3='852'
RETURN p AS shortestPath,
       reduce(cost=0, r IN relationships(p)| cost+r.cost) AS totalCost
       ORDER BY totalCost ASC
       LIMIT 1
UNION
MATCH q=(startNode)-[:LEAF]->(consumer)
RETURN q AS shortestPath,
       reduce(cost=0, r IN relationships(q)| cost+r.cost) AS totalCost
       ORDER BY totalCost ASC
       LIMIT 1
UNION
MATCH o=(startNode)-[:RESUPPLIES]->(needsResupply)-[:LEAF]->(consumer) RETURN o AS shortestPath,
       reduce(cost=0, r IN relationships(o)| cost+r.cost) AS totalCost
       ORDER BY totalCost ASC
       LIMIT 1



