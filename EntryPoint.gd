extends Node

func _ready():
	if CmdLineArgs.is_set("--server"):
		get_tree().change_scene("res://network/server/Server.tscn")
	else:
		get_tree().change_scene("res://network/client/MainMenu.tscn")
