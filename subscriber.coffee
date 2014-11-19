class Subscriber
  constructor: (redis) ->
    @redis = redis

  subscribe: (callback) ->
    @redis.on 'pmessage', (pattern, channel, message) ->
      callback channel, message
    @redis.psubscribe 'sockjs-demo:*'

module.exports = Subscriber
