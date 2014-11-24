class Message extends Backbone.Model
  defaults:
    body: ""

  sendToSockJs: (sock) ->
    sock.send @get 'body'

class Messages extends Backbone.Collection
  model: Message

class MessageView extends Backbone.View
  tagName: 'li'

  className: 'list-group-item'

  template: Handlebars.templates['message.hbs']

  render: ->
    @$el.html @template @model.toJSON()
    this

class MessagesView extends Backbone.View
  initialize: ->
    @listenTo @collection, 'add', @addMessage

  el: -> $('#messages')

  addMessage: (message) ->
    @$el.append new MessageView(model: message).render().el
    $("html, body").stop().animate({
      scrollTop: $(document).height() - $(window).height()
    }, 300, 'swing')

class MessageForm extends Backbone.View
  initialize: (attrs) ->
    @sock = attrs.sock

  events:
    "submit": "onSubmit"

  el: -> $("#new-message")

  onSubmit: (e) ->
    e.preventDefault()
    $input = @$("input#message-body")
    new Message(body: $input.val()).sendToSockJs(@sock)
    e.currentTarget.reset()
    $input.focus()

messages = new Messages

$ ->
  new MessagesView(collection: messages)

  wait = 1

  connect = ->
    messages.push(body: "connecting...")

    sock = new SockJS("/broadcast")

    sock.onopen = (e) ->
      wait = 1
      messages.push(body: "...connected")

    sock.onmessage = (e) ->
      messages.push(body: e.data)

    sock.onclose = (e) ->
      messages.push(body: "disconnected")
      messages.push(body: "trying to reconnect in " + wait + " seconds")
      setTimeout(connect, wait * 1000)
      wait *= 2

    new MessageForm(sock: sock)

  connect()
