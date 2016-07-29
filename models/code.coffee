Mongoose = require('mongoose')
Schema = require('mongoose').Schema

CodeSchema = new Schema(
    {
        zip: String
        city: String
        state: String
        latitude: String
        longitude: String
        timezone: String
        dst: String
    },
    { strict: false }
)
module.exports = { model: Mongoose.model("Code", CodeSchema), schema: CodeSchema }

#
#'{"zip":"85281","city":"Tempe","state":"AZ",
#"latitude":"33.426885","longitude":"-111.92733",
#"timezone":"-7","dst":"0"}')
