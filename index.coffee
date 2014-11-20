connectToRedis = ->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    redis = require('redis').createClient(rtg.port, rtg.hostname)
    redis.auth(rtg.auth.split(":")[1])
  else
    redis = require('redis').createClient()
  redis

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
broadcaster.connect()

Subscriber = require('./subscriber')
subscriber = new Subscriber(connectToRedis())
subscriber.subscribe (channel, message) ->
  console.log "Got from redis: #{channel} => #{message}"
  broadcaster.broadcast channel, message
