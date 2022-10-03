extends Node


var players = []

var player_numbers = {
    
   }
var pid = 1

const tile = {
    "player": -1,
    "piece": -1,
    "cooldown": 0,
    "pid": 0
   }

const piece_positions = [
    [-1,-1, 0,-1,-1],
    [-1, 1,-1, 3,-1],
    [ 0,-1, 5,-1, 0],
    [-1, 2,-1, 4,-1],
    [-1,-1, 0,-1,-1]
   ]
const piece_cooldown = [
    [-1,-1, 5,-1,-1],
    [-1, 8,-1, 11,-1],
    [ 5,-1, 6,-1, 5],
    [-1, 10,-1, 12,-1],
    [-1,-1, 5,-1,-1]
   ]

var captures = [
        Vector2(-1,0),
        Vector2(0,-1),
        Vector2(1,0),
        Vector2(0,1)
   ]

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

var fall_test = [
    Vector2(-1,0),
    Vector2(0,-1),
    Vector2(1,0),
    Vector2(0,1),
#    Vector2(-1,-1),
#    Vector2(1,-1),
#    Vector2(1,1),
#    Vector2(-1,1)
   ]

var board = []
var fallboard = []

var board_size = 50

func _ready():
    get_tree().get_root().get_node("Main").game_started(get_instance_id())
    for i in len(players):
        player_numbers[players[i]["id"]] = i+1
    init_board()
    init_pieces()
    init_loot()
    send_board()
    $FallTime.start()

func disconnect_player(id):
    var in_game = -1
    for p in len(players):
        if players[p]["id"] == id:
            in_game = p
            break
    if in_game != -1:
        players.remove(in_game)
        capture_all(player_numbers[id],0)
        if len(players) == 0:
            get_tree().get_root().get_node("Main").game_ended(get_instance_id())
            call_deferred("queue_free")
        return true
    else:
        return false
    
    
func new_fall(delta):
    var fall = Vector2(randi()%board_size, randi()%board_size)
    for i in 50:
        if fallboard[fall.y][fall.x] < 2:
            break
        fall = Vector2(randi()%board_size, randi()%board_size)
    var do_fall = false
    if fallboard[fall.y][fall.x] <= 1:
        if fallboard[fall.y][fall.x] == 1:
            do_fall = true
        elif fallboard[fall.y][fall.x] == 0:
            for test in fall_test:
                if fall.x + test.x < 0 or fall.x + test.x >= board_size or fall.y+test.y < 0 or fall.y+test.y >= board_size:
                    do_fall = true
                    break
                if fallboard[fall.y+test.y][fall.x+test.x] > 0:
                    do_fall = true
                    break
        if do_fall:
            fallboard[fall.y][fall.x] += 1
            if fallboard[fall.y][fall.x] == 2:
                send_shake(fall.x,fall.y)
    for y in len(fallboard):
        for x in len(fallboard[0]):
            if fallboard[y][x] >= 2 and fallboard[y][x] < 22:
                fallboard[y][x] += delta
                if fallboard[y][x] >= 22:
                    if board[y][x]["piece"] != -1:
                        kill(x, y, 0)
                    send_drop(x,y)
                
func send_shake(x,y):
    var data = {
        "head": "shake_tile",
        "x": x,
        "y": y
        }
    for player in players:
        Networking.send_to(player["id"], data)
        
func send_drop(x,y):
    var data = {
        "head": "drop_tile",
        "x": x,
        "y": y
        }
    for player in players:
        Networking.send_to(player["id"], data)


func init_board():
    for y in board_size:
        var row = []
        var fallrow = []
        for x in board_size:
            row.append(tile.duplicate())
            fallrow.append(0)
        board.append(row)
        fallboard.append(fallrow)
    
func init_pieces():
    var p = 0
    var offset = randi()%360
    for player in players:
        var p_pos = (Vector2.ONE * (board_size/2) + Vector2(0,-15).rotated(deg2rad(offset + 360/len(players) * p))).round()
        for y in len(piece_positions):
            for x in len(piece_positions[0]):
                if piece_positions[y][x] != -1:
                    board[p_pos.y+y-2][p_pos.x+x-2] = {
                            "player": player_numbers[player["id"]],
                            "piece": piece_positions[y][x],
                            "cooldown": OS.get_ticks_msec() + (piece_cooldown[y][x] - 10)*1000,
                            "pid": pid
                       }
                    pid += 1
        p += 1


func init_loot():
    for i in len(players) * 6:
        add_loot(0)
    for i in len(players) * 1:
        add_loot(1)
    for i in len(players) * 2:
        add_loot(2)
    for i in len(players) * 1:
        add_loot(3)

func add_loot(piece):
    while true:
        var pos = Vector2(randi()%board_size, randi()%board_size)
        if board[pos.y][pos.x]["player"] != -1:
            continue
        var valid = true
        for y in 5:
            if pos.y - 2 + y < 0 or pos.y -2 + y >= board_size:
                continue
            for x in 5:
                if pos.x - 2 + x < 0 or pos.x -2 + x >= board_size:
                    continue
                if board[pos.y-2+y][pos.x-2+x]["player"] > 0:
                    valid = false
                    break
            if !valid:
                break
        if valid:
            board[pos.y][pos.x] = {
                "player": 0,
                "piece": piece,
                "cooldown": OS.get_ticks_msec() - 10*1000,
                "pid": pid
                }
            pid += 1
            break
                
            
func print_board():
    for row in board:
        var row_print = ""
        for cell in row:
            row_print += " " + str(cell["piece"])
            

func send_board():
    var pieces = []
    for y in len(board):
        for x in len(board[0]):
            if board[y][x]["player"] != -1:
                pieces.append(
                    {
                        "x": x,
                        "y": y,
                        "player": board[y][x]["player"],
                        "piece": board[y][x]["piece"],
                        "cooldown": board[y][x]["cooldown"],
                        "pid": board[y][x]["pid"]
                    })
    var names = {0: ""}      
    for player in players:
        names[player_numbers[player["id"]]] = player["name"] 
    for player in players:
        var data = {
            "head": "init_board",
            "size": board_size,
            "you": player_numbers[player["id"]],
            "pieces": pieces,
            "names": names
           }
        Networking.send_to(player["id"], data)


func try_move(p, piece, tox, toy):
    if fallboard[toy][tox] >= 22:
        return #Allready fallen
    for y in len(board):
        for x in len(board[0]):
            if board[y][x]["pid"] == piece:
                if board[y][x]["player"] == player_numbers[p]:
                    if board[y][x]["cooldown"] + 10*1000 <= OS.get_ticks_msec():
                        var ptype = board[y][x]["piece"]
                        var moves = movements[ptype]
                        var move = Vector2(tox-x, toy-y)
                        var legal = false
                        for dir in moves:
                            for m in dir:
                                if x + m.x >= 0 and x + m.x < board_size and y + m.y >= 0 and y + m.y < board_size:
                                    if m == move:
                                        if board[y+m.y][x+m.x]["player"] != player_numbers[p] and board[y+m.y][x+m.x]["player"] != 0:
                                            if ptype == 0 and board[y+m.y][x+m.x]["player"] != -1:
                                                break
                                            move(x,y,tox,toy)
                                            legal = true
                                            break
                                    if board[y+m.y][x+m.x]["player"] != -1:
                                        break
                            if legal:
                                break
                        if ptype == 0:
                            for m in soldier_eat:
                                if x + m.x >= 0 and x + m.x < board_size and y + m.y >= 0 and y + m.y < board_size:
                                    if m == move:
                                        if board[y+m.y][x+m.x]["player"] != player_numbers[p] and board[y+m.y][x+m.x]["player"] != 0  and board[y+m.y][x+m.x]["player"] != -1:                        
                                            move(x,y,tox,toy)
                                            legal = true
                return


func move(x,y,tox,toy):
    if board[toy][tox]["pid"] != 0:
        kill(tox,toy,board[y][x]["player"])
    for cap in captures:
        if tox + cap.x >= 0 and tox + cap.x < board_size and toy + cap.y >= 0 and toy + cap.y < board_size:
            if board[toy+cap.y][tox+cap.x]["player"] == 0:
                capture(tox+cap.x, toy+cap.y, board[y][x]["player"])
    board[toy][tox] = {
        "player": board[y][x]["player"],
        "piece": board[y][x]["piece"],
        "cooldown": OS.get_ticks_msec(),
        "pid": board[y][x]["pid"]
       }
    board[y][x] = {
        "player": -1,
        "piece": -1,
        "cooldown": 0,
        "pid": 0
       }
    
    var data = {
        "head": "move_piece",
        "pid": board[toy][tox]["pid"],
        "x": tox,
        "y": toy
        }
    for player in players:
        Networking.send_to(player["id"], data)

func kill(x,y,killer,cap_all=true):
    var data = {
        "head": "kill_piece",
        "pid": board[y][x]["pid"]
        }
    for player in players:
        Networking.send_to(player["id"], data)
    if board[y][x]["piece"] == 5 and cap_all:
        capture_all(board[y][x]["player"],killer)
        
    board[y][x] = {
        "player": -1,
        "piece": -1,
        "cooldown": 0,
        "pid": 0
       }


        
func capture_all(kill,killer):
    var players_alive = []
    for y in len(board):
        for x in len(board[0]):
            if board[y][x]["player"] == kill:
                if board[y][x]["piece"] == 5:
                    kill(x,y,0,false)
                else:
                    board[y][x]["player"] = killer
            if not board[y][x]["player"] in players_alive and board[y][x]["player"] != 0 and board[y][x]["player"] != -1:
                players_alive.append(board[y][x]["player"])
    if len(players_alive) == 1:
        you_win(players_alive[0])
    var data = {
        "head": "capture_all",
        "kill": kill,
        "killer": killer
        }
    for player in players:
        Networking.send_to(player["id"], data)

func you_win(p):
    var data = {
        "head": "you_win",
        "winner": p
        }
    for player in players:
        Networking.send_to(player["id"], data)
    
        
func capture(x,y,p):
    board[y][x]["player"] = p
    var data = {
        "head": "capture_piece",
        "pid": board[y][x]["pid"],
        "player": board[y][x]["player"]
        }
    for player in players:
        Networking.send_to(player["id"], data)
    
    
    
    


func _on_FallTime_timeout():
    new_fall(0.08)
