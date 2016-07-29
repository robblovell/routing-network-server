mongoose = require('mongoose')
Resource = require('resourcejs')

module.exports = (app, model) ->
    resource = Resource(app, '', 'Routes', model).patch({
        before: (req, res, next) ->
            traverse = require('helpers/traverse')

            if not(req.body? and req.body[0]? and req.body[0].op?)
                result = traverse(req.body[0],'', [])
                req.body[0] = result[0]
            next()
    }).get().put().post().delete().index({
        before: (req, res, next) ->
            if (req.query.query?)
                req.modelQuery = this.model.find(JSON.parse(req.query.query))
                req.query.query = null
            next()
            return
    })

    return resource
