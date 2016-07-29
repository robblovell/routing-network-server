Papa = require('babyparse')
Redis = require('ioredis')
redis = new Redis('redis://127.0.0.1:6379/0')

fs = require('fs');

contents = fs.readFileSync('../../data/warehouses.csv', 'utf8');
#console.log(contents);

config = {
    delimiter: ","	# auto-detect
    newline: ""	# auto-detect
    header: true
    dynamicTyping: false
    preview: 0
    encoding: "UTF-8"
    worker: false
    comments: false
    step: undefined
#    complete: undefined
#    error: undefined
    download: false
    skipEmptyLines: false
#    chunk: undefined,
    fastMode: false,
#    beforeFirstChunk: undefined,
#    withCredentials: undefined
}

result = Papa.parse(contents, config)
data = result.data
pipeline = redis.pipeline()
for warehouse in data
    id = warehouse.ConsolidatedWarehouseID
#    console.log(warehouse)
    console.log(id)
    pipeline.set(id, JSON.stringify(warehouse))

pipeline.exec( (err, results) ->
    console.log("Done: ")
    console.log(JSON.stringify(results))
)

return

