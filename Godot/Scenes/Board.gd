extends Node2D

export(PackedScene) var Tile
export(PackedScene) var Piece

var board_size = 50
var offset = Vector2(-board_size/2.0*44, 0)
var pieces = []

func make_board(size):
    var delay
    for y in size:
        for x in size:
            var tile = Tile.instance()
            tile.position = Vector2(x*22+y*22, y*11 - x*11) + offset
            tile.color = (x+y)%2
            delay = 0.5+(x+y*0.5)/20.0
            tile.delay = delay
            tile.coord = Vector2(x,y)
            $Tiles.add_child(tile)
    $Board_ready.start(delay+1)

func _on_Board_ready_timeout():
    set_pieces()

func clean_board():
    pieces = []
    for child in $Tiles.get_children():
        child.queue_free()

func set_pieces():
    for p in pieces:
        var piece = Piece.instance()
        piece.coord = Vector2(p["x"],p["y"])
        piece.type = int(p["piece"])
        piece.player = p["player"]
        piece.id = p["pid"]
        $Tiles.add_child(piece)
        if p["player"] == Global.you and int(p["piece"]) == 5:
            var coord = Vector2(p["x"],p["y"])
            get_tree().get_root().get_node("Main").set_camera(Vector2(coord.x*22+coord.y*22, coord.y*11 - coord.x*11) + offset)
            

    #$Camera2D.position = Vector2(coord.x*22+coord.y*22, coord.y*11 - coord.x*11) + offset

func move_piece(pid, tox, toy):
    var pieces = get_tree().get_nodes_in_group("Piece")
    for piece in pieces:
        if piece.id == pid:
            piece.move(Vector2(tox,toy))
            break

func kill_piece(pid):
    var pieces = get_tree().get_nodes_in_group("Piece")
    for piece in pieces:
        if piece.id == pid:
            piece.die()
            break

func capture_piece(pid, player):
    var pieces = get_tree().get_nodes_in_group("Piece")
    for piece in pieces:
        if piece.id == pid:
            piece.capture(player)
            break

func capture_all(kill, killer):
    var pieces = get_tree().get_nodes_in_group("Piece")
    for piece in pieces:
        if piece.player == kill:
            piece.capture(killer, false)
            
func shake_tile(coord):
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        if tile.coord == coord:
            tile.shake = true    
                
func drop_tile(coord):
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        if tile.coord == coord:
            tile.drop()
    
