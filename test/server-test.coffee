vows     = require 'vows'
http     = require 'http'
events   = require 'events'
assert   = require 'assert'
{Dunce}  = require '..'

vows.describe('Dunce Server').addBatch
  'when creating a server':
    topic: -> new Dunce(null, process.cwd()+"/test")

    'it has a httpServer': (topic) ->
      assert.isObject topic.server
      assert.isFunction topic.server.listen
      assert.isFunction topic.server.close

    'it has a documentRoot': (topic) ->
      assert.equal(topic.documentRoot, process.cwd()+"/test")

    'it can listen':
      topic: (topic) ->
        promise = new events.EventEmitter()
        topic.callback = (req, res) ->
          promise.emit('success', {req,res})
        topic.listen(4000)
        http.get
          host: 'localhost'
          port: 4000
          path: '/'
        return promise

      'and will have a request and response': (objs) ->
        {req,res} = objs
        assert.isObject req
        assert.isObject res
        assert.equal req.method, 'GET'

  'when running a server':
    topic: ->
      server = Dunce.createServer(null, process.cwd()+"/test")
      server.listen(5000)
      return server

    "it will respond to '/'":
      topic: (topic) ->
        promise = new events.EventEmitter()

        http.get {
          host:'localhost', port:5000, path:'/'
        }, (res) ->
          promise.emit 'success', res

        return promise

      'it will have respond statusCode of 200': (topic) ->
        assert.equal topic.statusCode, 200

      'it will respond':
        topic: (topic) ->
          promise = new events.EventEmitter()
          data = ""
          topic.on 'data', (c) -> data += c
          topic.on 'end', ->
            promise.emit 'success', data
          return promise

        'with parsed PHP': (topic) ->
          assert.equal(topic, "go go php")

    "it will respond to '/test.php'":
      topic: (topic) ->
        promise = new events.EventEmitter()

        http.get {
          host:'localhost', port:5000, path:'/test.php'
        }, (res) ->
          promise.emit 'success', res

        return promise

      'it will have respond statusCode of 200': (topic) ->
        assert.equal topic.statusCode, 200

      'it will respond':
        topic: (topic) ->
          promise = new events.EventEmitter()
          data = ""
          topic.on 'data', (c) -> data += c
          topic.on 'end', ->
            promise.emit 'success', data
          return promise

        'with parsed PHP': (topic) ->
          assert.equal(topic, "this is test.php")


.export(module)
