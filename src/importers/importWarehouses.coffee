Importer = require('./nodes/WarehouseImporter')

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

config.nodeIdName = 'ConsolidatedWarehouseID'
importer = new Importer(config)

module.exports = importer


