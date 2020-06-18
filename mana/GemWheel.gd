extends Node2D

class_name GemWheel

onready var _anim = $AnimationPlayer

func _ready():
	_anim.play("hide")
	$Pivot/GemN.color = GameColors.WATER
	$Pivot/GemNE.color = GameColors.LIGHTNING
	$Pivot/GemE.color = GameColors.AIR
	$Pivot/GemSE.color = GameColors.STONE
	$Pivot/GemS.color = GameColors.FIRE
	$Pivot/GemSW.color = GameColors.POISON
	$Pivot/GemW.color = GameColors.NATURE
	$Pivot/GemNW.color = GameColors.LIFE

func _process(_delta):
	if Input.is_action_just_pressed("player_cast"):
		get_tree().paused = true
		_anim.play("in")
		
	elif Input.is_action_just_released("player_cast"):
		_anim.play_backwards("in")
		_anim.queue("hide") # No-op but used as a signal to unpause

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide":
		get_tree().paused = false
