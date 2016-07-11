
traverse = (jsonObj, path, result) ->
    if (typeof jsonObj == "object")
        for p, v of jsonObj
            result.push({op: 'replace', path: path+"/"+p, value: v})
            traverse(v, path+"/"+p, result)
    return result
module.exports = traverse