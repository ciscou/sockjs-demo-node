class Publisher
  constructor: (redis) ->
    @redis = redis

  getLatestMessages: (callback) ->
    console.log "fetching latest messages..."
    @redis.lrange 'messages', 0, -1, (error, messages) ->
      if error?
        console.log error
        return
      console.log "got #{messages.length} latest messages"
      callback(messages)

  publish: (message) ->
    @redis.lpush 'messages', message, (err, l) =>
      if err?
        console.log err
        return
      @redis.ltrim 'messages', 0, 9
    @redis.publish 'sockjs-demo:messages', message

module.exports = Publisher
