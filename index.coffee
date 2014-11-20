connectToRedis = ->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    redis = require('redis').createClient(rtg.port, rtg.hostname)
    redis.auth(rtg.auth.split(":")[1])
  else
    redis = require('redis').createClient()
  redis

express = require('express')
app = express()
app.use express.static('public')
server = app.listen(process.env.PORT || 5000)

Publisher = require('./publisher')
publisher = new Publisher(connectToRedis())

Broadcaster = require('./broadcaster')
broadcaster = new Broadcaster
broadcaster.onNewSession = (session) ->
  publisher.getLatestMessages (messages) ->
    for message in messages.reverse()
      session.send 'latest', message
  session.onMessage = (message) ->
    publisher.publish message
broadcaster.connect(server)

Subscriber = require('./subscriber')
subscriber = new Subscriber(connectToRedis())
subscriber.subscribe (channel, message) ->
  console.log "Got from redis: #{channel} => #{message}"
  broadcaster.broadcast channel, message
