Mongoose = require('mongoose')
Schema = require('mongoose').Schema
ObjectId = Mongoose.Schema.Types.ObjectId

RouteSchema = new Schema(
    {
        from: {
            type: ObjectId
            ref: 'Node'
            index: true
            require: true
        }
        to: {
            type: ObjectId
            ref: 'Node'
            index: true
            require: true
        }
    },
    { strict: false }
)
module.exports = { model: Mongoose.model("Route", RouteSchema), schema: RouteSchema }