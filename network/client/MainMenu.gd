extends Control

onready var _local_button = $LocalButton
onready var _name_edit = $NameEdit
onready var _remote_button = $RemoteButton

onready var _client = $Client

func _ready():
	_name_edit.text = ""
	_update_connect_enabled()
	_local_button.grab_focus()

func _on_NameEdit_text_changed(new_text):
	_update_connect_enabled()

func _update_connect_enabled():
	_remote_button.disabled = true
	if _name_edit.text != "":
		_remote_button.disabled = false

func _on_SinglePlayerButton_pressed():
	get_tree().change_scene("res://world/World.tscn")

func _on_MultiplayerButton_pressed():
	_client.connect_to_server(NetworkGlobals.IPV4, NetworkGlobals.PORT)
