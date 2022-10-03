extends Node2D


var color = 0
var delay = 0
var coord = Vector2(0,0)

var selected = false
var taken = -1

var dead = false
var shake = false

# Called when the node enters the scene tree for the first time.
func _ready():
    $Sprite.frame = color
    $Timer.start(delay)

var shage = 0
func _process(delta):
    if shake and not dead:
        shage += delta
        if shage > 0.1:
            shage = 0
            $Sprite.position.x = randi()%5 -2


func _on_Timer_timeout():
    $AnimationPlayer.play("Spawn")


func highlight(do=true, p=Global.you, soldiermove=false, soldiereat=false):
    if not do:
        $Sprite.frame_coords.y = 0
        selected = false
    else:
        if taken != -1:
            if taken == p or soldiermove:
                if not soldiereat:
                    $Sprite.frame_coords.y = 2
            else:
                $Sprite.frame_coords.y = 4
                selected = true
        elif not soldiereat:
            if p == Global.you:
                $Sprite.frame_coords.y = 1
                selected = true
            else:
                $Sprite.frame_coords.y = 3
                
        
    


func _on_Clicky_input_event(viewport, event, shape_idx):
    if (event is InputEventMouseButton && event.pressed):
        if event.button_index == BUTTON_LEFT and event.pressed:
            if selected and not dead:
                Global.tile_clicked = self
            
func select():
    var pieces = get_tree().get_nodes_in_group("Piece")
    for piece in pieces:
        if piece.selected:
            if piece.can_move:
                piece.send_move(coord)
            else:
                $Error.play()
            break
    var tiles = get_tree().get_nodes_in_group("Tile")
    for tile in tiles:
        tile.highlight(false)
            

func drop():
    dead = true
    $Sprite.frame_coords.y = 0
    selected = false
    $AnimationPlayer.play("Drop")


func _on_AnimationPlayer_animation_finished(anim_name):
    if anim_name == "Drop":
        queue_free()
