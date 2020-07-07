extends Node

var _player_scene = preload("res://player/Player.tscn")

func new_player(id: int = 0) -> Player:
	var player: Player = _player_scene.instance()

	if get_tree().network_peer != null:
		player.set_network_master(id)

	if id > 0:
		player.name += str(id)

	return player
