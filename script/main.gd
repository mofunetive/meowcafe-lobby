extends Control
class_name MainLobby
var websocket_url = "ws://127.0.0.1:4399"
var messageToSend = ""
var player_id = ""

var other_player_node = preload("res://Scenes/characters/player/OtherPlayer.tscn")
var other_players = {}

var isConnect = false
var delay_counter = 0
var delay_time = 5

@onready var _client: WebSocketClient = $WebSocketClient
@export var player_instance: PackedScene
@onready var main_player = $Player

var last_position = Vector2()  # ติดตามตำแหน่งสุดท้าย

func _connect_to_game():
	var error = _client.connect_to_websocket(websocket_url)
	if error != OK:
		print("Error connecting to websocket: %s" % [websocket_url])
	isConnect = true

func _ready() -> void: 
	_connect_to_game()

func _process(_delta):
	if isConnect:
		if main_player.position != last_position:
			send_position()
			last_position = main_player.position
		delay_counter += 1
		if delay_counter >= delay_time:
			delay_counter = 0

func _on_websocket_message_received(message):
	var json = JSON.parse_string(message)
	if typeof(json) == TYPE_DICTIONARY:
		if json["type"] == "initial_id":
			$Player.get_node("Label").text = json["id"]
			player_id = json["id"]
			print("Player ID received:", player_id)
			return
		elif (json["id"] == player_id):
			return
		
		match json["type"]:
			"player_joined":
				_add_player(json["id"], json["pos"])
			"player_left":
				_remove_player(json["id"])
			"update_pos":
				_update_player_position(json["id"], json["pos"])

	# print("Message received: %s" % message)

func _on_websocket_client_connection_close():
	var ws = _client.get_socket()
	print("Client disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])

func _on_websocket_client_connection_to_server():
	print("Client connected to server....")

func _on_send_message_pressed() -> void:
	print("Sending message")
	var dict = {"id": "1234", "data": "hello world"}
	var jsonData = JSON.stringify(dict)
	_client.send(jsonData)

func _add_player(id, player_position):
	if id in other_players:
		print("_add_player return")
		return

	var player = other_player_node.instantiate()
	player.id = id
	player.get_node("Label").text = id
	player.player_direction = Vector2(player_position[0], player_position[1])
	add_child(player)
	other_players[id] = player

func _remove_player(id):
	if id in other_players:
		other_players[id].queue_free()
		other_players.erase(id)

func _update_player_position(id, player_position):
	if id in other_players:
		print("_update_player_position", other_players[id], Vector2(player_position[0], player_position[1]))
		other_players[id].position = Vector2(player_position[0], player_position[1])

func send_position():
	var data = JSON.stringify({ "type": "update_pos", "id": player_id, "pos": [main_player.position.x, main_player.position.y]})
	_client.send(data)
