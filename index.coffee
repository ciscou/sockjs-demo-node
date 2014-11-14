http = require('http')
sockjs = require('sockjs')
redis = require('redis')

clients = []

broadcaster = sockjs.createServer()
server = http.createServer()
broadcaster.on 'connection', (conn) ->
  console.log 'got connection!'
  clients.push conn

broadcaster.installHandlers(server, prefix: '/broadcast')
server.listen(process.env.PORT || 5000)

broadcast = (message) ->
  for client in clients
    client.write JSON.stringify(message)

redisClient = redis.createClient()
blpopLoop = ->
  redisClient.blpop 'sockjs-demo:messages', 0, (err, res) ->
    if err?
      console.log err
    else
      [key, value] = res
      message = {}
      message[key] = value
      broadcast message
    blpopLoop()
blpopLoop()
