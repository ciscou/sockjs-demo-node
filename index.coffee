clients = {}

broadcaster = require('sockjs').createServer()
server = require('http').createServer()
broadcaster.on 'connection', (conn) ->
  console.log "got connection #{conn.id}!"
  clients[conn.id] = conn
  conn.on 'close', ->
    console.log "closed connection #{conn.id}!"
    delete clients[conn.id]

broadcaster.installHandlers(server, prefix: '/broadcast')
server.listen(process.env.PORT || 5000)

broadcast = (key, value) ->
  message = {}
  message[key] = value

  for id, client of clients
    client.write JSON.stringify(message)

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

blpopLoop = ->
  redisClient.blpop 'sockjs-demo:messages', 10, (err, res) ->
    if err?
      console.log err
    else if res?
      [key, value] = res
      console.log "Got from redis: #{key} => #{value}"
      broadcast key, value
    else
      console.log "Timeout, no new messages in last 10 seconds"

    blpopLoop()

blpopLoop()
