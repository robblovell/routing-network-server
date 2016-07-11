Mongoose = require('mongoose')
Schema = require('mongoose').Schema
#RouteSchema = require('./routes')
ObjectId = Mongoose.Schema.Types.ObjectId

NodeSchema = new Schema(
    {
        transit: Boolean
        storage: Boolean
        leaf: Boolean
        consolidator: Boolean
        deconsolidator: Boolean
        routes: [{ type: ObjectId, ref: 'Route' }]
    },
    { strict: false }
)
module.exports = { model: Mongoose.model("Node", NodeSchema), schema: NodeSchema }