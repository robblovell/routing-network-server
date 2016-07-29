express = require('express')
path = require('path')
cors = require('cors')

favicon = require('serve-favicon')
logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
routes = require('./routes/index')
config = require('./config/configuration')

app = express()

# view engine setup
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')

# uncomment after placing your favicon in /public
app.use(favicon(path.join(__dirname, 'public/images', 'favicon.ico')))
#app.use(logger('dev'))
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(require('stylus').middleware(path.join(__dirname, 'public')))
app.use(express.static(path.join(__dirname, 'public')))

app.use('/', routes)
config = require('./config/configuration')

mongoose = require('mongoose')
mongoose.Promise = require('bluebird')
mongoose.connect(config.db) # connect to our database

code= require('./models/code')
Codes = require('./controllers/codes')(app, code.model)

item= require('./models/item')
Items = require('./controllers/items')(app, item.model)

node= require('./models/node')
Nodes = require('./controllers/nodes')(app, node.model)

route= require('./models/route')
Routes = require('./controllers/routes')(app, route.model)

Resources = {
  Codes:Codes
  Items:Items
  Nodes:Nodes
  Routes:Routes
}

swagger = require('./controllers/swagger')(app, Resources, '/api', config)

timeout = require('connect-timeout')

app.use(timeout(config.timeout))
haltOnTimedout = (req, res, next) ->
  if (!req.timedout)
    next()
app.use(haltOnTimedout)

# catch 404 and forward to error handler
#app.use((req, res, next) ->
#  err = new Error('Not Found')
#  err.status = 404
#  next(err)
#)
# error handlers
# development error handler
# will print stacktrace
if (app.get('env') == 'development' or app.get('env') == 'local')
# development error handleripho
# will print stacktrace
  app.use((err, req, res, next) ->
    if (err?)
      res.status(err.status || 500)
      res.render('error', {
        message: err.message,
        error: err
      })

  )
else
# production error handler
# no stacktraces leaked to user
  app.use((err, req, res, next) ->
    if (err?)
      res.status(err.status || 500)
      res.render('error', {
        message: err.message,
        error: {}
      })
  )

# production error handler
# no stacktraces leaked to user
#app.use((err, req, res, next) ->
#  res.status(err.status || 500)
#  res.render('error', {
#    message: err.message,
#    error: {}
#  })
#)

module.exports = app