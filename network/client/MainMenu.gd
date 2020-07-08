extends Control

onready var _local_button = $LocalButton
onready var _name_edit = $NameEdit
onready var _remote_button = $RemoteButton

var _client_scene = preload("res://network/client/Client.tscn")
var _stage_scene = preload("res://stages/Stage.tscn")

func _ready():
	_name_edit.text = ""
	_update_connect_enabled()
	_local_button.grab_focus()
	get_tree().connect("connected_to_server", self, "_connected_success")

func _on_NameEdit_text_changed(new_text):
	_update_connect_enabled()

func _update_connect_enabled():
	_remote_button.disabled = true
	if _name_edit.text != "":
		_remote_button.disabled = false

func _on_SinglePlayerButton_pressed():
	var stage: Stage = _stage_scene.instance()
	stage.connect("ready", self, "_on_Stage_ready", [stage])
	get_tree().get_root().add_child(stage)

func _on_Stage_ready(stage):
	var player = PlayerFactory.new_player()
	stage.players.add_child(player)
	self.queue_free()

func _on_MultiplayerButton_pressed():
	var ip = CmdLineArgs.get_str_value("--ip")
	var port = CmdLineArgs.get_int_value("--port")

	if ip == "":
		if OS.is_debug_build():
			ip = NetGlobals.LOCALHOST
		else:
			ip = NetGlobals.SERVER_IP
	if port == 0:
		port = NetGlobals.PORT

	var client = _client_scene.instance()
	get_tree().get_root().add_child(client)
	client.connect_to_server(ip, port, _name_edit.text)

func _connected_success():
	self.queue_free()

