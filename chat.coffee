somata = require 'somata'

# A service that just publishes everything it receives
chat_service = new somata.Service 'chat',
    send: (chat, cb) ->
        chat_service.publish 'chat', chat
        cb null, 'ok'

