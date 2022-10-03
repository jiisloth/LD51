extends Node


var you = 0
var names = {}

var piece_clicked = false
var tile_clicked = false

func _process(delta):
    if tile_clicked:
        tile_clicked.select()
    elif piece_clicked:
        piece_clicked.select()
    piece_clicked = false
    tile_clicked = false
