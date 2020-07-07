extends Node

var _server: WebSocketServer = null
var _clients = {}
var _stage: Stage = null

var _stage_scene = preload("res://stages/Stage.tscn")

func _ready():
	var port = CmdLineArgs.get_int_value("--port")
	if port == 0:
		port = NetGlobals.PORT

	print("Server will listen on port: ", port)

	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")

	_server = WebSocketServer.new()
	_server.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(_server)
	print("Server created and listening for clients")

func _process(delta):
	if _server.is_listening():
		_server.poll()

func _peer_connected(id):
	print("Connected: ", id)

	if _clients.size() == 0:
		_stage = _stage_scene.instance()
		get_tree().get_root().add_child(_stage)
	_clients[id] = null

	var player = PlayerFactory.new_player(id)
	if _stage.is_inside_tree():
		_add_player_to_stage(_stage, player)
	else:
		_stage.connect("ready", self, "_add_player_to_stage", [_stage, player])

func _add_player_to_stage(stage, player):
	var players = _stage.players
	players.add_child(player)

	print("Added player: ", player.get_path())

func _peer_disconnected(id):
	print("Disconnected: ", id)
	_clients.erase(id)

	for player in _stage.players.get_children():
		if player.name.ends_with(id):
			player.queue_free()

	if _clients.size() == 0:
		_stage.queue_free()
		_stage = null
