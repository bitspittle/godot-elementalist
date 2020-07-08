extends KinematicBody2D

class_name Player

const WALKING_ACCELERATION = 512
const MAX_WALKING_SPEED = 100
const FRICTION = .25
const GRAVITY = 1000
const JUMP_FORCE = 150

const MAX_CLIMBING_SPEED = 80

var SLOPE_THRESHOLD = deg2rad(46)

var DEFAULT_SNAP_VECTOR = Vector2.DOWN * 40.0 # Make sure we snip hard if walking down sleep slopes

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

var _selected_spell: Spell

var _vel = Vector2.ZERO
var _snap_vector = DEFAULT_SNAP_VECTOR

var _prev_state = State.IDLE
var _state = State.IDLE
var _next_state = State.IDLE

onready var _pivot = $Pivot
onready var _player_sprite = $Pivot/PlayerSprite
onready var _gem_wheel: GemWheel = $GemWheel
onready var _platform_detector: Area2D = $PlatformDetector
onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _camera: Camera2D = $Pivot/Camera2D
onready var _jump_timer = $JumpTimer

onready var _sync_posvel = $Sync/PosVel
onready var _sync_state = $Sync/State
onready var _sync_spell = $Sync/SpellIndex

var _tmp_start_pos = Vector2.ZERO

func _ready():
	set_spell(Spells.NONE)
	_anim.play("idle")
	_tmp_start_pos = position

	if NetUtils.is_master(self):
		_camera.make_current()

func _process(_delta):
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
			_anim.play("squat")
			_anim.queue("duck")
		elif _next_state == State.JUMPING:
			_anim.play("jump")
			set_collision_mask_bit(Layers.PLATFORMS, false)
		elif _next_state == State.JUMPING_DOWN:
			set_collision_mask_bit(Layers.PLATFORMS, false)

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

		# print("Changing: ", State.keys()[state], " -> ", State.keys()[next_state])
		_sync_state.value = _next_state
		_prev_state = _state
		_state = _next_state
		_next_state = _state

	if _state == State.CLIMBING:
		if _anim.is_playing() && _vel == Vector2.ZERO:
			_anim.stop(false)
		elif !_anim.is_playing() && _vel != Vector2.ZERO:
			_anim.play()

	elif _state == State.JUMPING_DOWN:
		_next_state = State.FALLING

func _physics_process(delta):
	if _vel.y >= 0 \
	&& !get_collision_mask_bit(Layers.PLATFORMS) \
	&& _platform_detector.get_overlapping_bodies().empty():
		set_collision_mask_bit(Layers.PLATFORMS, true)

	if (_vel.x != 0):
		_pivot.scale.x = sign(_vel.x)

	if NetUtils.is_master(self):
		if _state != State.CLIMBING:
			_physics_process_walking(delta)
		else:
			_physics_process_climbing(delta)

		_sync_posvel.values["pos"] = position.round()
		_sync_posvel.values["vel"] = _vel.round()
	else:
		# TODO: Interpolate?
		position += _vel * delta


master func _physics_process_walking(delta):
	var x_input = 0

	if _state == State.IDLE:
		if Input.is_action_just_pressed("show_gem_wheel"):
			_gem_wheel.open()
		elif Input.is_action_just_released("show_gem_wheel"):
			_gem_wheel.close()

	if _gem_wheel.is_active():
		return

	if _state == State.IDLE \
	|| _state == State.WALKING \
	|| _state == State.JUMPING \
	|| _state == State.FALLING \
	|| _state == State.LANDING:
		x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")

	if x_input != 0:
		if _state == State.IDLE:
			_next_state = State.WALKING

		if sign(x_input) != sign(_vel.x):
			_vel.x = 0 # quick turnaround

		_vel.x += x_input * WALKING_ACCELERATION * delta
		_vel.x = clamp(_vel.x, -MAX_WALKING_SPEED, MAX_WALKING_SPEED)

	else:
		if _state == State.WALKING:
			_next_state = State.IDLE
		_vel.x = 0

	_vel.y += GRAVITY * delta
	_vel.y = move_and_slide_with_snap(_vel, _snap_vector, Vector2.UP, true, 4, SLOPE_THRESHOLD).y
	_snap_vector = DEFAULT_SNAP_VECTOR

	# Re-enable platforms as long as we're fallling and aren't currently intersecting with anything
	if (_vel.y >= 0 && _state != State.FALLING && !is_on_floor()):
		_next_state = State.FALLING

	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if not _state == State.DUCKING:
				_snap_vector = Vector2.ZERO
				_jump_timer.start()
				_next_state = State.JUMPING
			else:
				_next_state = State.JUMPING_DOWN

	elif _state != State.DUCKING \
	&& _state != State.WINDING_UP \
	&& _state != State.ATTACKING \
	&& Input.is_action_pressed("player_down"):
		if is_on_floor():
			_next_state = State.DUCKING
			_vel.x = 0

	elif _state == State.DUCKING \
	&& !Input.is_action_pressed("player_down"):
		_next_state = State.IDLE

	elif _state == State.FALLING \
	&& is_on_floor():
		_next_state = State.LANDING

	elif (_state == State.IDLE || _state == State.WALKING || _state == State.ATTACKING || _state == State.LANDING) \
	&& Input.is_action_just_pressed("player_attack"):
		_next_state = State.WINDING_UP

	elif (_state == State.WINDING_UP) \
	&& Input.is_action_just_released("player_attack"):
		_next_state = State.ATTACKING

	elif (_state == State.DUCKING) \
	&& Input.is_action_just_pressed("player_attack"):
		_next_state = State.ATTACKING

	elif Input.is_action_just_pressed("player_cast") \
	&& _selected_spell != Spells.NONE \
	&& is_on_floor():
		_next_state = State.CASTING

	elif _state == State.CASTING \
	&& Input.is_action_just_released("player_cast"):
		_next_state = State.IDLE

	if (!_jump_timer.is_stopped()):
		if Input.is_action_pressed("player_jump"):
			_vel.y = -JUMP_FORCE
		else:
			_jump_timer.stop()

master func _physics_process_climbing(delta):
	var x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var y_input = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")

	var input = Vector2(x_input, y_input)
	if input != Vector2.ZERO:
		_vel = input.normalized() * MAX_CLIMBING_SPEED * delta
		position += _vel
	else:
		_vel = Vector2.ZERO


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "land" || anim_name == "attack":
		_next_state = State.IDLE

func _on_GemWheel_spell_selected(spell):
	_sync_spell.value = _gem_wheel.spells.find(spell)
	set_spell(spell)

func set_spell(spell: Spell):
	_selected_spell = spell
	_player_sprite.get_material().set_shader_param("color_modulate", spell.color)

func _reset():
	_vel = Vector2.ZERO
	position = _tmp_start_pos
	_next_state = State.IDLE
	set_collision_mask_bit(Layers.PLATFORMS, true)

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if NetUtils.is_master(self):
		_reset()

func _on_PosVel_vaules_changed():
	position = _sync_posvel.values["pos"]
	_vel = _sync_posvel.values["vel"]

func _on_State_vaules_changed():
	_next_state = _sync_state.value

func _on_SpellIndex_vaules_changed():
	var index = _sync_spell.value
	if index >= 0:
		set_spell(_gem_wheel.spells[index])
	else:
		set_spell(Spells.NONE)
