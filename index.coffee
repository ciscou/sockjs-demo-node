http = require('http')
sockjs = require('sockjs')

broadcaster = sockjs.createServer()
server = http.createServer()
broadcaster.installHandlers(server, prefix: '/broadcast')
server.listen(process.env.PORT || 5000)
