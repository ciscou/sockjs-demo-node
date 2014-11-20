Session = require('./session')

class Broadcaster
  constructor: ->
    @sessions = {}

  onNewSession: (session) ->

  connect: (server) ->
    sockjs = require('sockjs').createServer()

    sockjs.on 'connection', (client) =>
      console.log "got connection #{client.id}!"
      @broadcast 'info', "got connection #{client.id}"
      session = @addClient(client)

      client.on 'close', =>
        console.log "closed connection #{client.id}!"
        @removeClient(client)

      @onNewSession(session)

    sockjs.installHandlers(server, prefix: '/broadcast')

  addClient: (client) ->
    session = new Session(client)
    @sessions[client.id] = session
    session.send 'info', "There are #{Object.keys(@sessions).length} clients connected"

    session

  removeClient: (client) ->
    delete @sessions[client.id]
    @broadcast 'info', "closed connection #{client.id}!"

  broadcast: (channel, message) ->
    for id, session of @sessions
      session.send channel, message

module.exports = Broadcaster
