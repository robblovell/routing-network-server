_ = require('lodash')

module.exports = (app, resources, spec='/spec', config) ->
    paths = {}
    definitions = {}
    _.each(resources, (resource) ->

        swagger = resource.swagger()
        if (swagger.paths["/items"]?)
            swagger.paths["/items"].get.parameters.push({
                    name: 'query',
                    in: 'query',
                    description: 'Query by example. Pass a JSON object to find, for example: {"age": {"$gte": 21, "$lte": 65}.',
                    type: 'string',
                    required: false,
                    default: ''
                }
            )
        paths = _.assign(paths, swagger.paths)
        definitions = _.assign(definitions, swagger.definitions)
    )
#    for path,verbs of paths
#        if verbs?
#            for key, verb of verbs
#                if verb.parameters
#                    for parameter,i in verb.parameters
#                        if parameter.name? and parameter.name is 'count'
#                            verb.parameters.splice(i, 1)
#                            break
    # Define the specification.
    specification = {
        swagger: '2.0',
        info: {
            description: 'Network Persister',
            version: config.version,
            title: 'Network Persister',
            contact: {
                name: 'Robb Lovell'
            },
#            license: {
#                name: 'MIT',
#                url: 'http://opensource.org/licenses/MIT'
#            }
        },
        host: config.host,
        basePath: config.basepath,
        schemes: [config.scheme],
        definitions: definitions,
        paths: paths
#        authorizations: {
#            oauth2: [
#                {scope: "full"
#                }
#            ]
#        }
    }

    # Show the specification at the URL.
    app.get(spec, (req, res, next) ->
        res.json(specification)
    )