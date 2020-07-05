extends PlayerController

class_name PlayerControllerRemote

func _physics_process(delta):
	# TODO, interpolate with timestamps
	player.position += player.vel * delta

puppet func set_physics(pos: Vector2, vel: Vector2):
	player.vel = vel
	player.position = pos

puppet func set_next_state(value):
	player.next_state = value

puppet func set_spell_index(index):
	if index >= 0:
		player.set_spell(player.gem_wheel.spells[index])
	else:
		player.set_spell(Spells.NONE)
