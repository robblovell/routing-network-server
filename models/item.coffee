Mongoose = require('mongoose')
Schema = require('mongoose').Schema
ObjectId = Mongoose.Schema.Types.ObjectId

NodeCostsSchema = new Schema(
    {
        node: {
            type: ObjectId
            ref: 'Node'
            index: true
            require: true
        },
        cost: Number
    }
    { strict: false }
)
RouteCostsSchema = new Schema(
    {
        route: {
            type: ObjectId
            ref: 'Route'
            index: true
            require: true
        },
        cost: Number
    }
    { strict: false }
)

ContextSchema = new Schema(
    {
        seller: { type: String, index: true }
        sku: { type: String, index: true }
    },
    { strict: false }
)

ItemSchema = new Schema(
    {
        nodes: [NodeCostsSchema],
        routes: [RouteCostsSchema]
        context: [ContextSchema]
    },
    { strict: false }
)
module.exports = { model: Mongoose.model("Item", ItemSchema), schema: ItemSchema }