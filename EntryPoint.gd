extends Node

func _ready():
	var title = "Elementalist"
	if OS.is_debug_build():
		title += " (DEBUG)"

	if CmdLineArgs.is_set("--server"):
		title = "[SERVER] " + title
		get_tree().change_scene("res://network/server/Server.tscn")
	else:
		get_tree().change_scene("res://network/client/MainMenu.tscn")

	OS.set_window_title(title)
