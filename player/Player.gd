extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 100
const FRICTION = .25
const GRAVITY = 1000
const JUMP_FORCE = 150

var SLOPE_THRESHOLD = deg2rad(46)
var DEFAULT_SNAP_VECTOR = Vector2.DOWN * 40.0 # Make sure we snip hard if walking down sleep slopes

enum State {
	IDLE,
	DUCKING,
	WALKING,
	JUMPING,
	FALLING,
	LANDING,
	WINDING_UP,
	ATTACKING,
	CASTING,
	CLIMBING,
}

var _vel = Vector2.ZERO
var _snap_vector = DEFAULT_SNAP_VECTOR

var _state = State.IDLE
var _next_state = State.IDLE

onready var _pivot = $Pivot
onready var _player_sprite = $Pivot/PlayerSprite
onready var _platform_detector: Area2D = $PlatformDetector
onready var _jump_timer: Timer = $JumpTimer
onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _time = $TimeEffect
onready var _gem_wheel = $GemWheel

var _selected_spell: Spell
var _tmp_start_pos: Vector2

func _ready():
	_set_spell(Spells.NONE)
	_anim.play("idle")
	_tmp_start_pos = position

func _process(_delta):
	if Input.is_action_pressed("ui_cancel") or position.y > 500:
		_vel = Vector2.ZERO
		position = _tmp_start_pos
		set_collision_mask_bit(Layers.PLATFORMS, true)

	if _state != _next_state:
		if _next_state == State.IDLE:
			if _state == State.DUCKING:
				_anim.play_backwards("duck")
				_anim.queue("idle")
			else:
				_anim.play("idle")
		elif _next_state == State.WALKING:
			_anim.play("walk")
		elif _next_state == State.DUCKING:
			_anim.play("duck")
		elif _next_state == State.JUMPING:
			_anim.play("jump")
		elif _next_state == State.FALLING:
			_anim.play("fall")
		elif _next_state == State.LANDING:
			_anim.play("land")
		elif _next_state == State.WINDING_UP:
			_anim.play("windup")
		elif _next_state == State.ATTACKING:
			_anim.play("attack")
		elif _next_state == State.CASTING:
			_anim.play("cast")
		elif _next_state == State.CLIMBING:
			_anim.play("climb")

		_state = _next_state

func _physics_process(delta):
	if _state != State.DUCKING:
		var x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
		if x_input != 0:
			if _state == State.IDLE:
				_next_state = State.WALKING

			if sign(x_input) != sign(_vel.x):
				_vel.x = 0 # quick turnaround
				_pivot.scale.x = sign(x_input)

			_vel.x += x_input * ACCELERATION * delta
			_vel.x = clamp(_vel.x, -MAX_SPEED, MAX_SPEED)

		else:
			if _state == State.WALKING:
				_next_state = State.IDLE
			_vel.x = 0

	_vel.y += GRAVITY * delta
	_vel.y = move_and_slide_with_snap(_vel, _snap_vector, Vector2.UP, true, 4, SLOPE_THRESHOLD).y
	_snap_vector = DEFAULT_SNAP_VECTOR

	# Re-enable platforms as long as we're fallling and aren't currently intersecting with anything
	if (_vel.y >= 0 && _state != State.FALLING && not is_on_floor()):
		_next_state = State.FALLING

	if (_vel.y >= 0 && !get_collision_mask_bit(Layers.PLATFORMS) && _platform_detector.get_overlapping_bodies().empty()):
		set_collision_mask_bit(Layers.PLATFORMS, true)

	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if not _state == State.DUCKING:
				_snap_vector = Vector2.ZERO
				_jump_timer.start()
				_next_state = State.JUMPING
			set_collision_mask_bit(Layers.PLATFORMS, false)

	elif _state != State.DUCKING && Input.is_action_pressed("player_down"):
		if is_on_floor():
			_next_state = State.DUCKING
			_vel.x = 0

	elif _state == State.DUCKING && not Input.is_action_pressed("player_down"):
		_next_state = State.IDLE

	elif _state == State.FALLING && is_on_floor():
		_next_state = State.LANDING

	elif (_state == State.IDLE || _state == State.WALKING || _state == State.ATTACKING || _state == State.LANDING) && Input.is_action_just_pressed("player_attack"):
		_next_state = State.WINDING_UP

	elif _state == State.WINDING_UP && Input.is_action_just_released("player_attack"):
		_next_state = State.ATTACKING

	elif Input.is_action_just_pressed("player_cast") && _selected_spell != Spells.NONE && is_on_floor():
		_next_state = State.CASTING

	elif _state == State.CASTING && Input.is_action_just_released("player_cast"):
		_next_state = State.IDLE

	if (!_jump_timer.is_stopped()):
		if Input.is_action_pressed("player_jump"):
			_vel.y = -JUMP_FORCE
		else:
			_jump_timer.stop()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "land" or anim_name == "attack":
		_next_state = State.IDLE


func _on_GemWheel_opening():
	if _state == State.CASTING:
		_next_state = State.IDLE

func _on_GemWheel_spell_selected(spell):
	_set_spell(spell)

func _set_spell(spell: Spell):
	_selected_spell = spell
	_player_sprite.get_material().set_shader_param("color_modulate", spell.color)


