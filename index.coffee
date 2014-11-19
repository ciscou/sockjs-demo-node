clients = {}

connectToRedis = ->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    client = require('redis').createClient(rtg.port, rtg.hostname)
    client.auth(rtg.auth.split(":")[1])
  else
    client = require('redis').createClient()
  client

send = (client, channel, message) ->
  payload = {}
  payload[channel] = message
  json = JSON.stringify(payload)
  for id, client of clients
    client.write json

broadcast = (channel, message) ->
  for id, client of clients
    send client, channel, message

redis = connectToRedis()

broadcaster = require('sockjs').createServer()
broadcaster.on 'connection', (client) ->
  console.log "got connection #{client.id}!"
  clients[client.id] = client
  client.on 'close', ->
    console.log "closed connection #{client.id}!"
    delete clients[client.id]
  console.log "fetching latest messages..."
  redis.lrange 'messages', 0, -1, (error, messages) ->
    if error?
      console.log error
      return
    console.log "got #{messages.length} latest messages"
    for message in messages.reverse()
      send client, 'latest', message

server = require('http').createServer()
broadcaster.installHandlers(server, prefix: '/broadcast')
server.listen(process.env.PORT || 5000)

subscriber = connectToRedis()
subscriber.on 'pmessage', (pattern, channel, message) ->
  console.log "Got from redis: #{channel} => #{message}"
  broadcast channel, message
subscriber.psubscribe 'sockjs-demo:*'
