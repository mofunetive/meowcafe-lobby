extends Control

var websocket_url = "ws://127.0.0.1:4399"
var messageToSend = ""

@onready var _client: WebSocketClient = $WebSocketClient

func _connect_to_game():
	var error = _client.connect_to_websocket(websocket_url)

	if error != OK:
		print("Error connecting to websocket: %s" % [websocket_url])

func _ready() -> void:
	_connect_to_game()

func _on_websocket_message_received(message):
	print("Message received: %s" % message)

func _on_websocket_client_connection_close():
	var ws = _client.get_socket()
	print("Client disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])

func _on_websocket_client_connection_to_server():
	print("Client connected to server....")

func _process(_delta):
	pass


func _on_send_message_pressed() -> void:
	pass # Replace with function body.
