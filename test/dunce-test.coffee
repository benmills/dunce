vows     = require 'vows'
http     = require 'http'
events   = require 'events'
assert   = require 'assert'
{spawn}   = require 'child_process'

vows.describe('Dunce Server').addBatch
  'It will start up a server on port 4000':
    topic: ->
      promise = new events.EventEmitter()
      dunce = spawn './bin/dunce'
      dunce.stdout.on 'data', (data) ->
        promise.emit 'success', data.toString()
        dunce.kill()

      dunce.stderr.on 'data', (data) ->
      dunce.on 'exit', (data) ->
      return promise

    'it will output that it started': (topic) ->
      assert.equal topic, '=> \033[32mStarting Dunce\033[39m on port \033[34m4000\033[39m\n'
      
  'It will start up a server on a user defined port':
    topic: ->
      promise = new events.EventEmitter()
      dunce = spawn './bin/dunce', ['-p', '3005']
      dunce.stdout.on 'data', (data) ->
        promise.emit 'success', data.toString()
        dunce.kill()

      dunce.stderr.on 'data', (data) ->
      dunce.on 'exit', (data) ->
      return promise

    'it will output that it started': (topic) ->
      assert.equal topic, '=> \033[32mStarting Dunce\033[39m on port \033[34m3005\033[39m\n'

.export(module)

