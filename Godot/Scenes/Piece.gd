extends Node2D


var coord = Vector2.ZERO
var selected = false
var type = 0

var player = 0
var id = 0
var can_move = false

var current_tile = null
var dead = false

var new_pos = Vector2()
var old_pos = Vector2()
var moving = 0

var movements = [
    [
        [Vector2(-1,0)],
        [Vector2(0,-1)],
        [Vector2(1,0)],
        [Vector2(0,1)]
       ],
    [
        [Vector2(-1,0),Vector2(-2,0),Vector2(-3,0),Vector2(-4,0),Vector2(-5,0),Vector2(-6,0),Vector2(-7,0)],
        [Vector2(0,-1),Vector2(0,-2),Vector2(0,-3),Vector2(0,-4),Vector2(0,-5),Vector2(0,-6),Vector2(0,-7)],
        [Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0),Vector2(5,0),Vector2(6,0),Vector2(7,0)],
        [Vector2(0,1),Vector2(0,2),Vector2(0,3),Vector2(0,4),Vector2(0,5),Vector2(0,6),Vector2(0,7)]
        
       ],
    [
        [Vector2(-1,2)],[Vector2(-1,-2)],
        [Vector2(2,-1)],[Vector2(-2,-1)],
        [Vector2(1,2)],[Vector2(1,-2)],
        [Vector2(2,1)],[Vector2(-2,1)]
       ],
    [
        [Vector2(-1,-1),Vector2(-2,-2),Vector2(-3,-3),Vector2(-4,-4),Vector2(-5,-5),Vector2(-6,-6),Vector2(-7,-7)],
        [Vector2(1,-1),Vector2(2,-2),Vector2(3,-3),Vector2(4,-4),Vector2(5,-5),Vector2(6,-6),Vector2(7,-7)],
        [Vector2(1,1),Vector2(2,2),Vector2(3,3),Vector2(4,4),Vector2(5,5),Vector2(6,6),Vector2(7,7)],
        [Vector2(-1,1),Vector2(-2,2),Vector2(-3,3),Vector2(-4,4),Vector2(-5,5),Vector2(-6,6),Vector2(-7,7)]
        
       ],
    [
        
        [Vector2(-1,-1),Vector2(-2,-2),Vector2(-3,-3),Vector2(-4,-4),Vector2(-5,-5),Vector2(-6,-6),Vector2(-7,-7)],
        [Vector2(1,-1),Vector2(2,-2),Vector2(3,-3),Vector2(4,-4),Vector2(5,-5),Vector2(6,-6),Vector2(7,-7)],
        [Vector2(1,1),Vector2(2,2),Vector2(3,3),Vector2(4,4),Vector2(5,5),Vector2(6,6),Vector2(7,7)],
        [Vector2(-1,1),Vector2(-2,2),Vector2(-3,3),Vector2(-4,4),Vector2(-5,5),Vector2(-6,6),Vector2(-7,7)],
        [Vector2(-1,0),Vector2(-2,0),Vector2(-3,0),Vector2(-4,0),Vector2(-5,0),Vector2(-6,0),Vector2(-7,0)],
        [Vector2(0,-1),Vector2(0,-2),Vector2(0,-3),Vector2(0,-4),Vector2(0,-5),Vector2(0,-6),Vector2(0,-7)],
        [Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0),Vector2(5,0),Vector2(6,0),Vector2(7,0)],
        [Vector2(0,1),Vector2(0,2),Vector2(0,3),Vector2(0,4),Vector2(0,5),Vector2(0,6),Vector2(0,7)]
        
       ],
    [
        [Vector2(-1,0)],
        [Vector2(0,-1)],
        [Vector2(1,0)],
        [Vector2(0,1)],
        [Vector2(-1,-1)],
        [Vector2(1,-1)],
        [Vector2(1,1)],
        [Vector2(-1,1)]
       ],
   ]
var soldier_eat = [
    Vector2(-1,-1),
    Vector2(1,-1),
    Vector2(1,1),
    Vector2(-1,1)
   ]

func _ready():
    $Sprite.frame_coords.x = type
    $Sprite/PieceHighlight.frame_coords.x = type
    $Sprite.frame_coords.y = player
    set_pos()
    $Sprite/Info/Name.text = Global.names[str(player)]
    $Sprite/Info/Name/Name.text = Global.names[str(player)]
    if player == 0:
        can_move = true
        $Sprite/Info/Bar.hide()
        $Sprite/Info.hide()
    else:
        match int(type):
            0:
                $Movable.start(3)
            1:
                $Movable.start(6)
            2:
                $Movable.start(8)
            3:
                $Movable.start(9)
            4:
                $Movable.start(10)
            5:
                $Movable.start(2)
    match int(type):
        0:
            $Clicked.stream = load("res://sounds/pawn.mp3")
            $DeathSound.stream = load("res://sounds/pawn.mp3")
        1:
            $Sprite/Info.rect_position.y = -24
            $Clicked.stream = load("res://sounds/rook.mp3")
            $DeathSound.stream = load("res://sounds/rook.mp3")
        2:
            $Sprite/Info.rect_position.y = -25
            $Clicked.stream = load("res://sounds/knight.mp3")
            $DeathSound.stream = load("res://sounds/knight.mp3")
        3:
            $Sprite/Info.rect_position.y = -32
            $Clicked.stream = load("res://sounds/bishop.mp3")
            $DeathSound.stream = load("res://sounds/bishop.mp3")
        4:
            $Sprite/Info.rect_position.y = -32
            $Clicked.stream = load("res://sounds/queen.mp3")
            $DeathSound.stream = load("res://sounds/queen.mp3")
        5:
            $Sprite/Info.rect_position.y = -36
            $Clicked.stream = load("res://sounds/king.mp3")
            $DeathSound.stream = load("res://sounds/king.mp3")


func set_pos():
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        if tile.coord == coord:
            current_tile = tile
            tile.taken = player
            position = tile.position + Vector2(0,22)
            new_pos = position
            old_pos = position
            break

var blink = 0

func _process(delta):
    if position != new_pos:
        moving += delta*1.5
        if moving >= 1:
            moving = 1
            position = new_pos
            old_pos = new_pos
            $Sprite.position = Vector2(0,-41)
            $Land.pitch_scale = 0.8 + randf()*0.4
            $Land.play()
            if current_tile and weakref(current_tile).get_ref():
                current_tile.get_node("AnimationPlayer").play("Land")
        else:
            position = old_pos.linear_interpolate(new_pos, moving) 
            $Sprite.position = Vector2(0,-41) - Vector2(0, -4*pow(moving-0.5,2)+1)*20
    else:
        if current_tile and weakref(current_tile).get_ref():
            $Sprite.position = current_tile.get_node("Sprite").position + Vector2(0,-48)

    if can_move:
        if selected and player == Global.you:
            blink += delta
            if blink > 0.5:
                $Sprite/PieceHighlight.frame_coords.y = 1
            if blink > 1:
                $Sprite/PieceHighlight.frame_coords.y = 0
                blink = 0 
        else:
            blink = 0
            $Sprite/PieceHighlight.frame_coords.y = 0
    else:
        $Sprite/Info/Bar/BarEmpty/BarFull.anchor_right = 1 - $Movable.time_left/10
        $Sprite/PieceHighlight.frame_coords.y = 1
            
    


func highlight_tiles():
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        tile.highlight(false)
    for moves in movements[type]:
        var blocked = false
        for move in moves:
            for tile in tiles:
                if tile.coord == coord + move:
                    if type != 0:
                        tile.highlight(true, player)
                    else:
                        tile.highlight(true, player, true)
                        
                    if tile.taken != -1 or tile.taken == Global.you:
                        blocked = true
                    break
            if blocked:
                break
    if type == 0:
        for move in soldier_eat:
            for tile in tiles:
                if tile.coord == coord + move:
                    tile.highlight(true, player, false, true)
            
        

func send_move(c):
    var data = {
        "head": "try_move",
        "pid": id,
        "x": c.x,
        "y": c.y
       }
    Networking.send_data(data)


func move(c):
    selected = false
    $Movable.start(10)
    $Sprite/Info/Bar.show()
    can_move = false
    var old_coord = coord
    coord = c
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        if tile.coord == old_coord:
            tile.taken = -1
            
        elif tile.coord == coord:
            current_tile = tile
            tile.taken = player
            moving = 0
            new_pos = tile.position + Vector2(0,22)
            old_pos = position

func die():
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        if tile.coord == coord:
            tile.taken = -1
            break
    dead = true
    $Sprite/Info.hide()
    $Sprite/PieceHighlight.hide()
    $DeathSound.play()
    $Death.start()

func capture(p, play=true):
    if play:
        $Clicked.pitch_scale = 0.8 + randf()*0.4
        $Clicked.play()
    player = p
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        if tile.coord == coord:
            tile.taken = player
            break
    $Sprite.frame_coords.y = player
    $Sprite/Info/Name.text = Global.names[str(player)]
    $Sprite/Info/Name/Name.text = Global.names[str(player)]
    $Sprite/Info.show()
    

func _on_Movable_timeout():
    $Sprite/Info/Bar.hide()
    can_move = true


func _on_Death_timeout():
    queue_free()


func _on_Clicky_input_event(viewport, event, shape_idx):
    if (event is InputEventMouseButton):
        if event.button_index == BUTTON_LEFT and event.pressed:
            if dead:
                return
            Global.piece_clicked = self


func select():
    $Clicked.pitch_scale = 0.8 + randf()*0.4
    $Clicked.play()
    var pieces = get_tree().get_nodes_in_group("Piece")
    for piece in pieces:
        piece.selected = false
    if player == Global.you:
        selected = true
    highlight_tiles()
    
