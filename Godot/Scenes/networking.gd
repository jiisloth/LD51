extends Node

# The URL we will connect to
var websocket_url = "wss://chess.hellokopter.com"
#var websocket_url = "ws://localhost:60129"

# Our WebSocketClient instance
var _client = WebSocketClient.new()

var connect = false

func _ready():
    # Connect base signals to get notified of connection open, close, and errors.
    _client.connect("connection_closed", self, "_closed")
    _client.connect("connection_error", self, "_closed")
    _client.connect("connection_established", self, "_connected")
    # This signal is emitted when not using the Multiplayer API every time
    # a full packet is received.
    # Alternatively, you could check get_peer(1).get_available_packets() in a loop.
    _client.connect("data_received", self, "_on_data")

func connect_to_server():
    set_process(true)
    var err = _client.connect_to_url(websocket_url, PoolStringArray(["ludus"]))
    connect = true
    if err != OK:
        set_process(false)

func disconnect_from_server():
    get_tree().get_root().get_node("Main").disconnected(true)
    connect = false
    _client.disconnect_from_host(1000, "")
    set_process(false)

func _closed(was_clean = false):
    # was_clean will tell you if the disconnection was correctly notified
    # by the remote peer before closing the socket.
    if connect:
        get_tree().get_root().get_node("Main").disconnected(false)
    set_process(false)

func _connected(proto = ""):
    # This is called on connection, "proto" will be the selected WebSocket
    # sub-protocol (which is optional)
    get_tree().get_root().get_node("Main").connected()
    # You MUST always use get_peer(1).put_packet to send data to server,
    # and not put_packet directly when not using the MultiplayerAPI.
    
func join_game(name):
    var data = {
        "head": "join",
        "name": name
       }
    
    _client.get_peer(1).put_packet(pack(data))

func _on_data():
    # Print the received packet, you MUST always use get_peer(1).get_packet
    # to receive data from server, and not get_packet directly when not
    # using the MultiplayerAPI.
    var pkt = _client.get_peer(1).get_packet()
    var data = unpack(pkt)
    if typeof(data) == TYPE_DICTIONARY:
        if data.has("head"):
            match data["head"]:
                "init_board":
                    get_tree().get_root().get_node("Main").init_board(data)
                "move_piece":
                    get_tree().get_root().get_node("Main").move_piece(data)
                "kill_piece":
                    get_tree().get_root().get_node("Main").kill_piece(data)
                "capture_piece":
                    get_tree().get_root().get_node("Main").capture_piece(data)
                "capture_all":
                    get_tree().get_root().get_node("Main").capture_all(data)
                "shake_tile":
                    get_tree().get_root().get_node("Main").shake_tile(data)
                "drop_tile":
                    get_tree().get_root().get_node("Main").drop_tile(data)
                "lobby_state":
                    get_tree().get_root().get_node("Main").update_lobby(data)
                "you_win":
                    get_tree().get_root().get_node("Main").you_win(data)
                    

func _process(delta):
    # Call this in _process or _physics_process. Data transfer, and signals
    # emission will only happen when calling this function.
    _client.poll()

func send_data(data):
    _client.get_peer(1).put_packet(pack(data))

func unpack(data):
    return parse_json(data.get_string_from_utf8())

func pack(data):
    return to_json(data).to_utf8()
