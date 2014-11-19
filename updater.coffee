class Updater
  constructor: (redis) ->
    @redis = redis

  sendLatestMessagesTo: (broadcaster, client) ->
    console.log "fetching latest messages..."
    @redis.lrange 'messages', 0, -1, (error, messages) ->
      if error?
        console.log error
        return
      console.log "got #{messages.length} latest messages"
      for message in messages.reverse()
        broadcaster.send client, 'latest', message

module.exports = Updater
