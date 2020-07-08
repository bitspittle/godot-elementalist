extends Node

var _client: WebSocketClient = null

var _stage_scene = preload("res://stages/Stage.tscn")
var _stage: Stage = null

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_success")
	get_tree().connect("connection_failed", self, "_connected_failure")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")

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
	_stage.connect("ready", self, "_add_player_to_stage", [_stage, PlayerFactory.new_player(id)])
	get_tree().get_root().add_child(_stage)

func _add_player_to_stage(stage, player):
	stage.players.add_child(player)
	print("Added player: ", player.get_path())


func _connected_failure():
	print("Connection rejected")
	if _stage != null:
		# TODO: Graceful network recovery, back to main menu?
		get_tree().quit()

func _server_disconnected():
	print("Server disconnected")
	self.queue_free()


func _peer_connected(id):
	print("Connected: ", id)
	if id != NetGlobals.SERVER_ID:
		rpc_id(id, "register_player")

func _peer_disconnected(id):
	print("Disconnected: ", id)

	if id != NetGlobals.SERVER_ID:
		for player in _stage.players.get_children():
			if player.name.ends_with(id):
				player.queue_free()
				return

remote func register_player():
	var id = get_tree().get_rpc_sender_id()
	print("Registering ", id)
	_add_player_to_stage(_stage, PlayerFactory.new_player(id))

