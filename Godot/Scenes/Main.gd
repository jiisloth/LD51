extends Node2D

var ingame = false
var menufade = -1
var fade_in = false
var fadestate = 0
const fadetime = 0.6
var lobby = []

func init_board(data):
    Global.you = data["you"]
    Global.names = data["names"]
    $Board.make_board(data["size"])
    $Board.pieces = data["pieces"]
    ingame = true
    $Menu.hide()
    lobby = []

func _ready():
    fade_in = $Menu/MenuFader/Main



func move_piece(data):
    $Board.move_piece(data["pid"],data["x"],data["y"])

func kill_piece(data):
    $Board.kill_piece(data["pid"])
    
func capture_piece(data):
    $Board.capture_piece(data["pid"], data["player"])
    
func capture_all(data):
    $Board.capture_all(data["kill"], data["killer"])
    if data["kill"] == Global["you"]:
        $Overlay/End.text = "Game Over!"
        $Lose.play()
        $Overlay.show()

func shake_tile(data):
    $Board.shake_tile(Vector2(data["x"],data["y"]))
    
func drop_tile(data):
    $Board.drop_tile(Vector2(data["x"],data["y"]))
    
func you_win(data):
    if data["winner"] == Global["you"]:
        $Overlay/End.text = "You Are Victorious!"
        $Win.play()
        $Overlay.show()

func set_camera(pos):
    $Camera2D.position = pos


func click():
    $Click.pitch_scale = 0.7 + randf()*0.6
    $Click.play()

func _process(delta):
    if len(lobby) == 1:
        $Menu/MenuFader/Lobby/LobbyTime.text = "Waiting for players.."
    elif len(lobby) >= 2:
        $Menu/MenuFader/Lobby/LobbyTime.text = "Starting in.. " + str(round($Menu/MenuFader/Lobby/LobbyTime/Timer.time_left)) + " s"

    if ingame:
        var mouse = get_viewport().get_mouse_position()
        var window = get_viewport_rect().size
        var cam_move = Vector2(0,0)
        if mouse.x < window.x*0.05:
            cam_move.x = -1#-75 + mouse.x
        elif mouse.x > window.x - window.x*0.05:
            cam_move.x = 1#75 - (window.x - mouse.x)
        if mouse.y < window.x*0.05:
            cam_move.y = -1#-75 + mouse.y
        elif mouse.y > window.y - window.x*0.05:
            cam_move.y = 1#75 - (window.y - mouse.y)
        if Input.is_action_pressed("left"):
            cam_move.x += -1
        if Input.is_action_pressed("right"):
            cam_move.x += 1
        if Input.is_action_pressed("up"):
            cam_move.y += -1
        if Input.is_action_pressed("down"):
            cam_move.y += 1
        
        $Camera2D.position += cam_move * 800 * delta
        if $Camera2D.position.x < $Camera2D.limit_left:
            $Camera2D.position.x = $Camera2D.limit_left
        if $Camera2D.position.x > $Camera2D.limit_right:
            $Camera2D.position.x = $Camera2D.limit_right
        if $Camera2D.position.y < $Camera2D.limit_top:
            $Camera2D.position.y = $Camera2D.limit_top
        if $Camera2D.position.y > $Camera2D.limit_bottom:
            $Camera2D.position.y = $Camera2D.limit_bottom
        $Camera2D.position = Vector2($Camera2D.position.x, $Camera2D.position.y).round()
        
        
        if Input.is_action_just_pressed("Escape"):
            for child in $Menu/MenuFader.get_children():
                child.hide()
            $Menu/MenuFader/InGame.show()
            $Menu/MenuFader.modulate.a = 1
            $Menu.show()
    if fade_in:
        menufade += delta
        if menufade < fadetime and fadestate == 0:
            $Menu/MenuFader.modulate.a = min(1 - menufade/fadetime,1)
            $Menu/Logo.modulate.a = 1 - menufade/fadetime
        if menufade < fadetime and fadestate == 1:
            $Menu/MenuFader.modulate.a = menufade/fadetime
            $Menu/Logo.modulate.a = menufade/fadetime
        if menufade >= fadetime:
            fadestate += 1
            match fadestate:
                1:
                    for child in $Menu/MenuFader.get_children():
                        child.hide()
                    fade_in.show()
                    $Menu/Logo.show()
                    menufade = 0
                2:
                    $Menu/MenuFader.modulate.a = 1
                    $Menu/Logo.modulate.a = 1
                    menufade = 0
                    fade_in = false
                    fadestate = 0
                    

func update_lobby(data):
    lobby = data["players"]
    var t = data["time"]
    var plabels = $Menu/MenuFader/Lobby/Lobby.get_children()
    $Menu/MenuFader/Lobby/HSeparator/LobbyPlayers.text = "Players: " + str(len(lobby)) + "/8"
    if len(lobby) >= 2:
        $Menu/MenuFader/Lobby/LobbyTime/Timer.stop()
        $Menu/MenuFader/Lobby/LobbyTime/Timer.start(t)
                
    for plabel in plabels:
        plabel.text = ""
    for p in len(lobby):
        plabels[p].text = lobby[p]["name"]
        if lobby[p]["ready"]:
            plabels[p].theme = load("res://misc/ready.tres")
        else:
            plabels[p].theme = load("res://misc/notready.tres")
    
    

func disconnected(clean=false):
    for child in $Menu/MenuFader.get_children():
        child.hide()
    if clean:
        fade_in = $Menu/MenuFader/Main
    else:
        fade_in = $Menu/MenuFader/NoConnect
        
    $Menu.show()
    ingame = false
    $Camera2D.position = Vector2(0,0)
    $Board.clean_board()
    $Overlay.hide()
 

func connected():
    fade_in = $Menu/MenuFader/Play
    fadestate = 0
       


func _on_Play_pressed():
    if fade_in and fadestate == 0:
        return
    click()
    fade_in = $Menu/MenuFader/Connecting
    Networking.connect_to_server()


func _on_Back_pressed():
    if fade_in and fadestate == 0:
        return
    click()
    $Menu/MenuFader/Lobby/Ready.pressed = false
    fade_in = $Menu/MenuFader/Main
    Networking.disconnect_from_server()


func _on_LineEdit_text_changed(new_text):
    if new_text.strip_edges() != "":
        $Menu/MenuFader/Play/Join.disabled = false
    else:
        $Menu/MenuFader/Play/Join.disabled = true
        
        


func _on_Join_pressed():
    if fade_in and fadestate == 0:
        return
    click()
    fade_in = $Menu/MenuFader/Lobby
    Networking.join_game($Menu/MenuFader/Play/LineEdit.text.strip_edges().json_escape())
    


func _on_Ready_pressed():
    if fade_in and fadestate == 0:
        return
    click()
    var data = {
        "head": "ready",
        "value": $Menu/MenuFader/Lobby/Ready.pressed
       }
    Networking.send_data(data)


func _on_Resume_pressed():
    click()
    $Menu/MenuFader/InGame.hide()
    $Menu.hide()


func _on_Button_mouse_entered():
    $Select.pitch_scale = 0.7 + randf()*0.6
    $Select.play()


func _on_Guide_pressed():
    if fade_in and fadestate == 0:
        return
    click()
    fade_in = $Menu/MenuFader/Guide
