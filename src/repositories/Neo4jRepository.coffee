async = require('async')
request = require('superagent')
iRepository = require('./iRepository')

neo4j = require('neo4j-driver').v1
uuid = require('uuid')

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

    find: (query, callback) ->


    get: (example, callback) ->
        if (example.id == "" or example.id == null)
            callback(null,"{}")
            return
        cypher = "MATCH (n:#{example.type}) WHERE n.id = {id} RETURN n"
        session = @neo4j.session()
        session.run(cypher, example)
            .then((result) =>
                session.close()
                if (result and result.records[0] and result.records[0]._fields)
                    callback(null, JSON.stringify(result.records[0]._fields[0].properties))
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


    add: (cypher, callback) ->
        make = (json) ->
            return (callback) ->

        if (@buffer? || !callback?)
            @buffer.push(make( json))
        else
            throw new Error 'not implemented'
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

        obj.id = id if (id)
        if (@buffer? || !callback?)
            [data, upsert] = makeUpsert(obj)
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

    exec: (callback) =>
        @buffer.commit()
        .subscribe({
            onCompleted: () =>
                @session.close()
                callback(null, "success")
                return
            onError: (error) =>
                @session.close()
                callback(error, null)
                return
        })