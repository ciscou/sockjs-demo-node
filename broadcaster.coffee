class Broadcaster
  constructor: ->
    @clients = {}

  onConnect: (client) ->

  connect: (callback) ->
    self = this

    sockjs = require('sockjs').createServer()

    sockjs.on 'connection', (client) ->
      console.log "got connection #{client.id}!"
      self.addClient(client)

      client.on 'close', ->
        console.log "closed connection #{client.id}!"
        self.removeClient(client)

      self.onConnect(client)

    server = require('http').createServer()
    sockjs.installHandlers(server, prefix: '/broadcast')
    server.listen(process.env.PORT || 5000)

  addClient: (client) ->
    @broadcast 'info', "got connection #{client.id}"
    @clients[client.id] = client
    @send client, 'info', "There are #{Object.keys(@clients).length} clients connected"

  removeClient: (client) ->
    @broadcast 'info', "closed connection #{client.id}!"
    delete @clients[client.id]

  broadcast: (channel, message) ->
    for id, client of @clients
      @send client, channel, message

  send: (client, channel, message) ->
    payload = {}
    payload[channel] = message
    json = JSON.stringify(payload)
    client.write json

module.exports = Broadcaster
