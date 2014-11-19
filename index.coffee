connectToRedis = ->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    client = require('redis').createClient(rtg.port, rtg.hostname)
    client.auth(rtg.auth.split(":")[1])
  else
    client = require('redis').createClient()
  client

Updater = require('./updater')
updater = new Updater(connectToRedis())

Broadcaster = require('./broadcaster')
broadcaster = new Broadcaster
broadcaster.onConnect = (client) ->
  updater.sendLatestMessagesTo(broadcaster, client)
broadcaster.connect()

Subscriber = require('./subscriber')
subscriber = new Subscriber(connectToRedis())
subscriber.subscribe (channel, message) ->
  console.log "Got from redis: #{channel} => #{message}"
  broadcaster.broadcast channel, message
