extends Node

var _server: WebSocketServer = null
var _clients = {}
var _stage: Stage = null

var _stage_scene = preload("res://stages/Stage.tscn")
var _player_scene = preload("res://player/Player.tscn")

func start():
	var port = CmdLineArgs.get_int_value("--port")
	if port == 0:
		port = NetworkGlobals.PORT

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
	_clients[id] = null
	if _clients.size() == 1:
		_stage = _stage_scene.instance()
		get_parent().add_child(_stage)

	var players = _stage.players
	var player = _player_scene.instance()
	player.name += id
	players.add_child(player)

func _peer_disconnected(id):
	print("Disconnected: ", id)
	_clients.erase(id)

	for player in _stage.players:
		if player.name.ends_with(id):
			player.queue_free()

	if _clients.size() == 0:
		_stage.queue_free()
		_stage = null
