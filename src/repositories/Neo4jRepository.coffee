async = require('async')
request = require('superagent')
iRepository = require('./iRepository')
combyne = require('combyne')
neo4j = require('neo4j-driver').v1
uuid = require('uuid')
math = require('mathjs')

module.exports = class iRepository
    constructor: (@config) ->
        @buffer = null
        if !@config.url?
            @config.url = 'bolt://neo4j:macro7@localhost'
        if (@config.url.indexOf(':') > -1 and @config.url.indexOf('@') > -1)
            @config.user = @config.url.split("//")[1].split(":")[0]
            @config.pass = @config.url.split("//")[1].split("@")[0].split(":")[1]
            @config.url = @config.url.replace(@config.user+":"+@config.pass+"@","")

        @neo4j = neo4j.driver(@config.url, neo4j.auth.basic(@config.user, @config.pass))
        return

    find: (example, callback) ->
        # todo:: other types of queries, paging etc.
        cypher = "Match (n:#{example.type}) RETURN n"
        @run(cypher, {}, callback)

    run: (cypher, data, callback=null) ->
        if (@buffer? || !callback?)
            @buffer.run(cypher, data)
        else
            session = @neo4j.session()
            session.run(cypher, data)
            .then((result) =>
                session.close()
                if (result and result.records[0] and result.records[0]._fields)
                    # todo:: be consistent in returning results. Return an array of objects.
                    if (result.records.length == 1)
                        callback(null, JSON.stringify(result.records[0]._fields[0].properties))
                    else
                        results = []
                        for record in result.records
                            results.push(record._fields[0].properties)
                        callback(null, results)
                else
                    callback(null, "{}")
                return
            )
            .catch((error) =>
                console.log("Error:"+error)
                session.close()
                callback(error, null)
                return
            )
        return

    get: (example, callback) ->
        if (example.id == "" or example.id == null)
            callback(null,"{}")
            return
        cypher = "MATCH (n:#{example.type}) WHERE n.id = {id} RETURN n"
        @run(cypher, example, callback)


    add: (cypher, callback) ->
        throw new Error 'not implemented'

    setEdge: (params, edge, callback) =>
        makeUpsert = (params, data) =>
            ###
                MATCH (a:Zip {id: '019'}), (b:LtlCode {id: '019_11000_200_300'})
                MERGE (a)-[r:ZIPLTL {id: '019_019_11000_200_300', cost: '34', kind:'LTL' }]->(b)
                ON CREATE SET r.created=timestamp()
                ON MATCH SET r.updated=timestamp()
            ###

            data.id = uuid.v4() unless (data.id?)
            propstring = ((""+key+":'"+value+"', ") for key,value of data).reduce((t,s) -> t + s)
            propstring = propstring.slice(0,-2)
            properties = ((""+key+":{"+key+"}, ") for key,value of data).reduce((t,s) -> t + s)
            properties = properties.slice(0,-2) # remove the trailing comma.

            upsertString = "MATCH "+
                "(a:"+params.sourcekind+" {id:'"+params.sourceid+"'}), "+
                "(b:"+params.destinationkind+" {id:"+params.destinationid+"}) "+
                "MERGE (a)-[r:"+params.kind+" {"+propstring+"}]->(b) "+
                "ON CREATE SET r.created=timestamp() "+
                "ON MATCH SET r.updated=timestamp()"
            upsertString = combyne(upsertString).render(params)
#            console.log(upsertString)  if math.floor(math.random(0,500)) == 1

            upsertStatement = "MATCH "+
                "(a:"+params.sourcekind+" {id:{sourceid}}), "+
                "(b:"+params.destinationkind+" {id:{destinationid}}) "+
                "MERGE (a)-[r:"+params.kind+" {"+properties+"}]->(b) "+
                "ON CREATE SET r.created=timestamp() "+
                "ON MATCH SET r.updated=timestamp()"

            for key,value of params
                data[key] = value
#            console.log(upsertStatement)
            return [data, upsertStatement]

        [data, upsert] = makeUpsert(params, edge)
        if (@buffer? || !callback?)
            @buffer.run(upsert, data)
        else
            session = @neo4j.session()
            session.run(upsert, edge)
            .then((result) =>
                session.close()
                callback(null, result)
            )
            .catch((error) =>
                session.close()
                callback(error, null)
            )
        return


    set: (id, obj, callback) =>
        makeUpsert = (data) ->
            data.id = uuid.v4() unless (data.id?)
            properties = (("n."+key+" = {"+key+"}, ") for key,value of data).reduce((t,s) -> t + s)
            properties = properties.slice(0,-2) # remove the trailing comma.
            create = "n.created=timestamp(), "+properties
            update = "n.updated=timestamp(), "+properties
            #         1234567890123456789012345678901234567890

            upsertStatement = "MERGE (n:#{data.type} { id: {id} }) ON CREATE SET "+
                create+
                " ON MATCH SET "+
                update

            return [data, upsertStatement]

        obj.id = id if (id?)
        [data, upsert] = makeUpsert(obj)

        if (@buffer? || !callback?)
            @buffer.run(upsert, data)
        else
            session = @neo4j.session()
            session.run(upsert, data)
            .then((result) =>
                session.close()
                callback(null, result)
            )
            .catch((error) =>
                session.close()
                callback(error, null)
            )
        return

    delete: (id) ->


    pipeline: () ->
        @session = @neo4j.session()
        @buffer = @session.beginTransaction()
        return

    exec: (callback) =>
        @buffer.commit()
        .subscribe({
            onCompleted: () =>
                @session.close()
                @buffer = null
                callback(null, "success")

                return
            onError: (error) =>
                @session.close()
                @buffer = null
                callback(error, null)
                return
        })