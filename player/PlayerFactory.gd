extends Node

var _player_scene = preload("res://player/Player.tscn")

func new_player(id: int = 0, player_name: String = "") -> Player:
	var player: Player = _player_scene.instance()
	player.player_name = player_name

	if get_tree().network_peer != null:
		player.set_network_master(id)

	if id > 0:
		player.name += str(id)

	return player
