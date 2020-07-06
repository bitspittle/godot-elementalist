extends PlayerController

class_name PlayerControllerRemote

var _physics_data = NetworkDict.new()

func _physics_process(delta):
	# TODO, interpolate with timestamps?
	player.position += player.vel * delta

puppet func set_physics(physics_data):
	if _physics_data.update(physics_data):
		player.position = _physics_data.values["pos"]
		player.vel = _physics_data.values["vel"]

puppet func set_next_state(value):
	player.next_state = value

puppet func set_spell_index(index):
	print(player.get_path(), " -> ", index)
	if index >= 0:
		player.set_spell(player.gem_wheel.spells[index])
	else:
		player.set_spell(Spells.NONE)
