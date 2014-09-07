window.D = React.DOM
window.h = highland

# Singular message view
# ------------------------------------------------------------------------------

MessageView = React.createClass

    remove: ->
        @props.onRemove()

    render: ->
        D.li({ key: @props.key, onClick: @remove },
            D.strong(null, @props.message.from, ": "),
            @props.message.body
        )

# Chat view with messages and input
# ------------------------------------------------------------------------------

ChatView = React.createClass

    # Setup

    getInitialState: ->
        messages: @props.messages or []

    componentWillMount: ->
        # Subscribe to incoming chats
        @props.chats_in.each @addMessage

    componentDidMount: ->
        @refs.input.getDOMNode().focus()

    # Changes

    # Removing a message
    removeMessage: (mid) ->
        @setState messages: _.reject @state.messages, (m) -> m.id == mid

    # Adding a message
    addMessage: (newMessage) ->
        @setState messages: @state.messages.concat [newMessage]

    # Actions

    # Creating a new message
    sendChat: (e) ->
        e.preventDefault()
        newMessage =
            from: @props.id
            body: @refs.input.state.value

        @refs.input.setState value: "" # Clear the input
        @props.chats_out.write newMessage # Send new message

    # Rendering

    render: ->
        message_views = @state.messages.map(@renderMessage)
        D.div(null,
            D.em(null, "Connected as ", this.props.id),
            D.ul(null, message_views),
            D.form({ onSubmit: @sendChat },
                D.input({ ref: "input", type: "text" })
            )
        )

    renderMessage: (message, i) ->
        MessageView
            key: i
            onRemove: @removeMessage.bind(this, message.id)
            message: message

# Chat streams
# ------------------------------------------------------------------------------

# The "write" stream for sending messages to the chat service
chats_out = h()
chats_out.each (c) -> remote 'chat', 'send', c, ->

# The "read" stream for receiving events from the chat service
chats_n = 0
chats_in = eventStream('chat', 'chat').doto (m) -> m.id = ++chats_n

# Initializing
# ------------------------------------------------------------------------------

window.chat = React.renderComponent(ChatView(
    messages: [{from: "admin", body: "Welcome to chat."}]
    id: Math.floor(Math.random() * 100)
    chats_in: chats_in
    chats_out: chats_out
), document.getElementById("chat"))

