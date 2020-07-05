extends Node

var _client: WebSocketClient = null

var _stage_scene = preload("res://stages/Stage.tscn")
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
	var id = get_tree().get_network_unique_id()
	_stage.connect("ready", self, "_on_Stage_connected", [_stage, PlayerFactory.new_player(id, true)])
	get_parent().add_child(_stage)

func _on_Stage_connected(stage, player):
	stage.add_child(player)

func _connected_failure():
	print("Connection rejected")

func _server_disconnected():
	print("Server disconnected")
	self.queue_free()


func _peer_connected(id):
	print("Connected: ", id)

	var player = PlayerFactory.new_player(id, false)
	var players = _stage.players
	_stage.add_child(player)

func _peer_disconnected(id):
	print("Disconnected: ", id)

	for player in _stage.players:
		if player.name.ends_with(id):
			player.queue_free()
			return
