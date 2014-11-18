clients = {}

broadcaster = require('sockjs').createServer()
broadcaster.on 'connection', (conn) ->
  console.log "got connection #{conn.id}!"
  clients[conn.id] = conn
  conn.on 'close', ->
    console.log "closed connection #{conn.id}!"
    delete clients[conn.id]

server = require('http').createServer()
broadcaster.installHandlers(server, prefix: '/broadcast')

server.listen(process.env.PORT || 5000)

broadcast = (channel, message) ->
  payload = {}
  payload[channel] = message

  for id, client of clients
    client.write JSON.stringify(payload)

  null

connectToRedis = ->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    client = require('redis').createClient(rtg.port, rtg.hostname)
    client.auth(rtg.auth.split(":")[1])
  else
    client = require('redis').createClient()

  client

redisClient = connectToRedis()

redisClient.on 'pmessage', (pattern, channel, message) ->
  console.log "Got from redis: #{channel} => #{message}"
  broadcast channel, message

redisClient.psubscribe 'sockjs-demo:*'
