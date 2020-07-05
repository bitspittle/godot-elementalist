extends Node

var _client: WebSocketClient = null

var _stage_scene = preload("res://stages/Stage.tscn")
var _player_scene = preload("res://player/Player.tscn")
var _player_controller_local = preload("res://player/PlayerControllerLocal.tscn")

var _stage: Stage = null

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_success")
	get_tree().connect("connection_failed", self, "_connected_failure")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func connect_to_server(ip: String, port: int) -> void:
	_client = WebSocketClient.new()

	var prefix = "ws://"
	var url = prefix + ip + ":" + str(port)
	print("Connecting to: ", url, "...")
	var error = _client.connect_to_url(url, PoolStringArray(), true)

	get_tree().set_network_peer(_client)

func _process(delta):
	if _client == null:
		return

	if _client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
	|| _client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
		_client.poll()


func _connected_success():
	print("Connection successful")
	_stage = _stage_scene.instance()

	var player: Player = _player_scene.instance()
	var id = get_tree().get_network_unique_id()
	player.name += id
	player.set_network_master(id)
	player.controller
	_stage.add_child(player)
	get_parent().add_child(_stage)

func _connected_failure():
	print("Connection rejected")

func _server_disconnected():
	print("Server disconnected")
	self.queue_free()


func _peer_connected(id):
	print("Connected: ", id)

	var players = _stage.players
	var player: Player = _player_scene.instance()
	player.name += id
	players.add_child(player)

func _peer_disconnected(id):
	print("Disconnected: ", id)
