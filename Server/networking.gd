extends Node

# The port we will listen to
const PORT = 60129
# Our WebSocketServer instance
var _server = WebSocketServer.new()

func _ready():
    # Connect base signals to get notified of new client connections,
    # disconnections, and disconnect requests.
    _server.connect("client_connected", self, "_connected")
    _server.connect("client_disconnected", self, "_disconnected")
    _server.connect("client_close_request", self, "_close_request")
    # This signal is emitted when not using the Multiplayer API every time a
    # full packet is received.
    # Alternatively, you could check get_peer(PEER_ID).get_available_packets()
    # in a loop for each connected peer.
    _server.connect("data_received", self, "_on_data")
    # Start listening on the given port.
    var err = _server.listen(PORT, PoolStringArray(["ludus"]))
    if err != OK:
        print("Unable to start server")
        set_process(false)
    else:
        print("Started server")

func _connected(id, proto):
    # This is called when a new peer connects, "id" will be the assigned peer id,
    # "proto" will be the selected WebSocket sub-protocol (which is optional)
    get_tree().get_root().get_node("Main").player_connected(id)
    print("Client %d connected with protocol: %s" % [id, proto])

func _close_request(id, code, reason):
    # This is called when a client notifies that it wishes to close the connection,
    # providing a reason string and close code.
    print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
    # This is called when a client disconnects, "id" will be the one of the
    # disconnecting client, "was_clean" will tell you if the disconnection
    # was correctly notified by the remote peer before closing the socket.
    get_tree().get_root().get_node("Main").disconnect_player(id)
    print("Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _on_data(id):
    # Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
    # and not get_packet directly when not using the MultiplayerAPI.
    var pkt = _server.get_peer(id).get_packet()
    var data = unpack(pkt)
    if typeof(data) == TYPE_DICTIONARY:
        if data.has("head"):
            match data["head"]:
                "join":
                    get_tree().get_root().get_node("Main").connect_player(id, data)
                "try_move":
                    get_tree().get_root().get_node("Main").try_move(id, data)
                "ready":
                    get_tree().get_root().get_node("Main").set_ready(id, data)
                    
                    
    

func _process(delta):
    # Call this in _process or _physics_process.
    # Data transfer, and signals emission will only happen when calling this function.
    _server.poll()
    
func send_to(id, data):
    _server.get_peer(id).put_packet(to_json(data).to_utf8())
    
    

func unpack(data):
    return parse_json(data.get_string_from_utf8())

func pack(data):
    return to_json(data).to_utf8()
