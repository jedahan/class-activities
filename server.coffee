port = process.env.PORT or 5000

# koa, from the makers of express
koa = require 'koa'
time = require 'koa-response-time'
logger = require 'koa-logger'
router = require 'koa-router'
body = require 'koa-better-body'
send = require 'koa-send'

# directories to store images
static_dir = __dirname + '/static'
image_dir = static_dir + '/image'

# nedb is a simple datastore like sqlite, but with mongodb syntax
nedb = require 'nedb'
wrap = require 'co-nedb'
db = new nedb filename: 'activities.db', autoload: true
activities = wrap db

app = koa()
app.use time()
app.use logger()
app.use router(app)

# POST /activities title='my cool activity' tags='this,that,the other' description='# omg\n markdown\n * yes\n *yes'
app.post '/activities', body({multipart: true, formidable: {uploadDir: image_dir}}), ->
  title = @request.body.fields.title
  tags = @request.body.fields.tags
  description = @request.body.fields.description
  images = @request.body.files

  @body = yield activities.insert {title, tags, description}

# GET /trees
app.get '/activities', ->
  @body = yield activities.find {}

app.get /.*/, ->
  yield send @, @path, { root: static_dir }

app.listen port, ->
  console.log "[#{process.pid}] listening on :#{port}"
  console.log
