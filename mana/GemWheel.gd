extends Node2D

class_name GemWheel

onready var _anim = $AnimationPlayer

enum State {
	HIDDEN,
	ANIMATING_IN,
	SHOWN,
	ANIMATING_OUT,
}

var _state = State.HIDDEN
var _cursor_pos = Vector2.ZERO

onready var _gemN = $Pivot/GemN
onready var _gemNE = $Pivot/GemNE
onready var _gemE = $Pivot/GemE
onready var _gemSE = $Pivot/GemSE
onready var _gemS = $Pivot/GemS
onready var _gemSW = $Pivot/GemSW
onready var _gemW = $Pivot/GemW
onready var _gemNW = $Pivot/GemNW
onready var _cursor = $Cursor

func _ready():
	_anim.play("hide")
	_gemN.color = Spells.LIST[0].color
	_gemNE.color = Spells.LIST[1].color
	_gemE.color = Spells.LIST[2].color
	_gemSE.color = Spells.LIST[3].color
	_gemS.color = Spells.LIST[4].color
	_gemSW.color = Spells.LIST[5].color
	_gemW.color = Spells.LIST[6].color
	_gemNW.color = Spells.LIST[7].color

func _process(_delta):
	if _state == State.HIDDEN && Input.is_action_just_pressed("show_gem_wheel"):
		get_tree().paused = true
		_cursor_pos = Vector2.ZERO
		_state = State.ANIMATING_IN
		_anim.play("in")

	elif _state == State.SHOWN && not Input.is_action_pressed("show_gem_wheel"):
		_state = State.ANIMATING_OUT
		_anim.play_backwards("in")
		_anim.queue("hide") # No-op but used as a signal to unpause

	if _state == State.SHOWN:
		var cursor_pos = Vector2(
			Input.get_action_strength("player_right") - Input.get_action_strength("player_left"),
			Input.get_action_strength("player_down") - Input.get_action_strength("player_up")
		).normalized() * _gemE.position.x

		if _cursor_pos != cursor_pos:
			_cursor_pos = cursor_pos
			if _cursor_pos != Vector2.ZERO:
				_cursor.visible = true
				_cursor.position = _cursor_pos
			else:
				_cursor.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "in": # Could be from playing forwards OR backwards...
		if _state == State.ANIMATING_IN:
			_state = State.SHOWN

	elif anim_name == "hide":
		get_tree().paused = false
		_state = State.HIDDEN
