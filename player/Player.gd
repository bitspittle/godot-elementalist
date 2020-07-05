extends KinematicBody2D

class_name Player

enum State {
	IDLE,
	DUCKING,
	WALKING,
	JUMPING,
	JUMPING_DOWN,
	FALLING,
	LANDING,
	WINDING_UP,
	ATTACKING,
	CASTING,
	CLIMBING,
}

# Visible to controller
var vel = Vector2.ZERO
var state = State.IDLE
var next_state = State.IDLE
var selected_spell: Spell
onready var gem_wheel: GemWheel = $GemWheel
# End controller

var _prev_state = State.IDLE

onready var _pivot = $Pivot
onready var _player_sprite = $Pivot/PlayerSprite
onready var _platform_detector: Area2D = $PlatformDetector
onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _time = $TimeEffect

var _tmp_start_pos = Vector2.ZERO

func _ready():
	set_spell(Spells.NONE)
	_anim.play("idle")
	_tmp_start_pos = position

func _process(_delta):
	if state != next_state:
		if next_state == State.IDLE:
			if state == State.DUCKING:
				_anim.play_backwards("duck")
				_anim.queue("idle")
			else:
				_anim.play("idle")
		elif next_state == State.WALKING:
			_anim.play("walk")
		elif next_state == State.DUCKING:
			_anim.play("squat")
			_anim.queue("duck")
		elif next_state == State.JUMPING:
			_anim.play("jump")
			set_collision_mask_bit(Layers.PLATFORMS, false)
		elif next_state == State.JUMPING_DOWN:
			set_collision_mask_bit(Layers.PLATFORMS, false)

		elif next_state == State.FALLING:
			_anim.play("fall")
		elif next_state == State.LANDING:
			_anim.play("land")
		elif next_state == State.WINDING_UP:
			_anim.play("windup")
		elif next_state == State.ATTACKING:
			_anim.play("attack")
		elif next_state == State.CASTING:
			_anim.play("cast")
		elif next_state == State.CLIMBING:
			_anim.play("climb")

		# print("Changing: ", State.keys()[state], " -> ", State.keys()[next_state])
		_prev_state = state
		state = next_state
		next_state = state

	if state == State.CLIMBING:
		if _anim.is_playing() && vel == Vector2.ZERO:
			_anim.stop(false)
		elif !_anim.is_playing() && vel != Vector2.ZERO:
			_anim.play()

	elif state == State.JUMPING_DOWN:
		next_state = State.FALLING

func _physics_process(delta):
	if (vel.y >= 0 && !get_collision_mask_bit(Layers.PLATFORMS) && _platform_detector.get_overlapping_bodies().empty()):
		set_collision_mask_bit(Layers.PLATFORMS, true)

	if (vel.x != 0):
		_pivot.scale.x = sign(vel.x)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "land" || anim_name == "attack":
		next_state = State.IDLE

func _on_GemWheel_opening():
	# Turn off casting when inside the gem wheel, because
	# changing the spell means you might have a different
	# casting animation
	if state == State.CASTING:
		next_state = State.IDLE

func _on_GemWheel_spell_selected(spell):
	set_spell(spell)

func set_spell(spell: Spell):
	selected_spell = spell
	_player_sprite.get_material().set_shader_param("color_modulate", spell.color)

func reset():
	vel = Vector2.ZERO
	position = _tmp_start_pos
	next_state = State.IDLE
	set_collision_mask_bit(Layers.PLATFORMS, true)

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	# TODO: I'd like to move network logic into the controllers if possible
	# TODO: Helper util function because Godot's network API is not smart when
	#  there's no peer?
	if get_tree().network_peer == null || is_network_master():
		reset()
