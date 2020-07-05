extends Node

var _server: WebSocketServer = null
var _clients = {}

func _ready():
	var port = NetworkGlobals.PORT
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

func _peer_disconnected(id):
	print("Disconnected: ", id)
	_clients.erase(id)
