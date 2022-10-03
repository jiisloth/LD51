extends Node


export(PackedScene) var Game

var lobby = []


func _ready():
    log_to_file("Server started")
    randomize()

func connect_player(id, data):
    lobby.append({"id": id, "name": data["name"], "ready": false})
    send_lobby_state()
    if len(lobby) == 2:
        $Timer.stop()
        $Timer.start(180)
    if len(lobby) == 8:
        start_game()

func set_ready(id, data):
    var all_ready = true
    for p in lobby:
        if p["id"] == id:
            p["ready"] = data["value"]
        if not p["ready"]:
            all_ready = false
    send_lobby_state()
    if all_ready and len(lobby) > 1:
        start_game() 

func send_lobby_state():
    var lobbystate = []
    for p in lobby:
        lobbystate.append({"name": p["name"], "ready": p["ready"]})
    for p in lobby:
        var data = {
            "head": "lobby_state",
            "players": lobbystate,
            "time": $Timer.time_left
           }
        Networking.send_to(p["id"], data)

func _on_Timer_timeout():
    if len(lobby) > 1:
        start_game()

func start_game():
    $Timer.stop()
    var game = Game.instance()
    game.players = lobby.duplicate()
    lobby = []
    $Games.add_child(game)

func try_move(id, data):
    for game in $Games.get_children():
        for p in game.players:
            if p["id"] == id:
                game.try_move(id, data["pid"], data["x"], data["y"])
                break


func disconnect_player(id):
    var in_lobby = -1
    for p in len(lobby):
        if lobby[p]["id"] == id:
            in_lobby = p
            break
    if in_lobby != -1:
        lobby.remove(in_lobby)
        send_lobby_state()
    else:
        for game in $Games.get_children():
            if game.disconnect_player(id):
                break
    log_to_file(str(id) + " disconnected")
    
    
func player_connected(id):
    log_to_file(str(id) + " connected")
    
func game_started(id):
    log_to_file(str(id) + " started")
    
func game_ended(id):
    log_to_file(str(id) + " ended")


func log_to_file(content):
    var file = File.new()
    file.open("user://game_log.log", File.WRITE_READ)
    file.seek_end()
    file.store_string("\n")
    file.store_string(str(OS.get_unix_time()) + " - " + str(content))
    file.close()
