extends Node2D

class_name GemWheel

signal opening()
signal spell_selected(spell)

onready var _anim = $AnimationPlayer

enum State {
	HIDDEN,
	ANIMATING_IN,
	SHOWN,
	ANIMATING_OUT,
}

var _state = State.HIDDEN
var _cursor_pos = Vector2.ZERO

# Order goes E, SE, S, ..., SE (matching degrees on an inverted y-axis)
# Opposite elements are on opposite sides and defensive spells are on the left
var _spells = [Spells.AIR, Spells.STONE, Spells.FIRE, Spells.POISON, Spells.NATURE, Spells.LIFE, Spells.WATER, Spells.LIGHTNING]
onready var _gems = [$Pivot/GemE, $Pivot/GemSE, $Pivot/GemS, $Pivot/GemSW, $Pivot/GemW, $Pivot/GemNW, $Pivot/GemN, $Pivot/GemNE]
onready var _cursor = $Cursor

func _ready():
	_anim.play("hide")

	for i in _spells.size():
		_gems[i].color = _spells[i].color

func _process(_delta):
	if _state == State.HIDDEN && Input.is_action_just_pressed("show_gem_wheel"):
		get_tree().paused = true
		_cursor_pos = Vector2.ZERO
		_state = State.ANIMATING_IN
		_anim.play("in")
		emit_signal("opening")

	elif _state == State.SHOWN && not Input.is_action_pressed("show_gem_wheel"):
		_state = State.ANIMATING_OUT
		_anim.play_backwards("in")
		_anim.queue("hide") # No-op but used as a signal to unpause

	if _state == State.SHOWN:
		var cursor_pos = Vector2(
			Input.get_action_strength("player_right") - Input.get_action_strength("player_left"),
			Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
		).normalized() * _gems[0].position.x

		if _cursor_pos != cursor_pos:
			_cursor_pos = cursor_pos
			if _cursor_pos != Vector2.ZERO:
				_cursor.visible = true
				_cursor.position = _cursor_pos
				emit_signal("spell_selected", _spells[_vec_to_gem_index(_cursor_pos)])
			else:
				_cursor.visible = false
				emit_signal("spell_selected", Spells.NONE)

func _vec_to_gem_index(vec: Vector2) -> int:
	var index = int(round(vec.angle() / (2 * PI) * 8))
	if index < 0:
		index += 8

	return index

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "in": # Could be from playing forwards OR backwards...
		if _state == State.ANIMATING_IN:
			_state = State.SHOWN

	elif anim_name == "hide":
		get_tree().paused = false
		_state = State.HIDDEN
