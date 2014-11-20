class Session
  constructor: (client) ->
    @client = client
    @client.on 'data', (message) =>
      console.log "got from client #{@client.id}: #{message}"
      @onMessage message

  onMessage: (message) ->

  send: (channel, message) ->
    payload = {}
    payload[channel] = message
    json = JSON.stringify(payload)
    @client.write json

module.exports = Session
