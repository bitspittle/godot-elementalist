extends Node2D

class_name GemWheel

onready var _anim = $AnimationPlayer

func _ready():
	_anim.play("hide")

func _process(delta):
	if Input.is_action_just_pressed("player_cast"):
		get_tree().paused = true
		_anim.play("in")
		
	elif Input.is_action_just_released("player_cast"):
		_anim.play_backwards("in")
		_anim.queue("hide") # No-op but used as a signal to unpause

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide":
		get_tree().paused = false
