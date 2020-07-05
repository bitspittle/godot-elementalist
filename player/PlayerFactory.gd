extends Node

var _player_scene = preload("res://player/Player.tscn")
var _controller_local_scene = preload("res://player/PlayerControllerLocal.tscn")
var _controller_remote_scene = preload("res://player/PlayerControllerRemote.tscn")

func new_player(id: int = 0, is_local = true) -> Player:
	var player: Player = _player_scene.instance()
	var controller: PlayerController
	if is_local:
		controller = _controller_local_scene.instance()
	else:
		controller = _controller_remote_scene.instance()
	controller.name = "PlayerController"

	controller.player = player
	if get_tree().network_peer != null:
		controller.set_network_master(id)

	if id > 0:
		player.name += str(id)
	player.add_child(controller)

	return player
