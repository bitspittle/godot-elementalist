extends PlayerController

class_name PlayerControllerLocal

const WALKING_ACCELERATION = 512
const MAX_WALKING_SPEED = 100
const FRICTION = .25
const GRAVITY = 1000
const JUMP_FORCE = 150

const MAX_CLIMBING_SPEED = 80

var SLOPE_THRESHOLD = deg2rad(46)

var DEFAULT_SNAP_VECTOR = Vector2.DOWN * 40.0 # Make sure we snip hard if walking down sleep slopes
var _snap_vector = DEFAULT_SNAP_VECTOR

var _tmp_start_pos = Vector2.ZERO

onready var _jump_timer = $JumpTimer

func set_player(value: Player):
	.set_player(value)
	_tmp_start_pos = player.position

func _process(delta):
	# TODO: Delete this, it's debug code only
	if Input.is_action_pressed("ui_cancel") or player.position.y > 500:
		player.vel = Vector2.ZERO
		player.position = _tmp_start_pos
		player.next_state = Player.State.IDLE
		player.set_collision_mask_bit(Layers.PLATFORMS, true)

func _physics_process(delta):
	if player.state != Player.State.CLIMBING:
		_physics_process_walking(delta)
	else:
		_physics_process_climbing(delta)

func _physics_process_walking(delta):
	var x_input = 0

	if player.state == Player.State.IDLE \
	|| player.state == Player.State.WALKING \
	|| player.state == Player.State.JUMPING \
	|| player.state == Player.State.FALLING \
	|| player.state == Player.State.LANDING:
		x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")

	if x_input != 0:
		if player.state == Player.State.IDLE:
			player.next_state = Player.State.WALKING

		if sign(x_input) != sign(player.vel.x):
			player.vel.x = 0 # quick turnaround

		player.vel.x += x_input * WALKING_ACCELERATION * delta
		player.vel.x = clamp(player.vel.x, -MAX_WALKING_SPEED, MAX_WALKING_SPEED)

	else:
		if player.state == Player.State.WALKING:
			player.next_state = Player.State.IDLE
		player.vel.x = 0

	player.vel.y += GRAVITY * delta
	player.vel.y = player.move_and_slide_with_snap(player.vel, _snap_vector, Vector2.UP, true, 4, SLOPE_THRESHOLD).y
	_snap_vector = DEFAULT_SNAP_VECTOR

	# Re-enable platforms as long as we're fallling and aren't currently intersecting with anything
	if (player.vel.y >= 0 && player.state != Player.State.FALLING && !player.is_on_floor()):
		player.next_state = Player.State.FALLING

	if Input.is_action_just_pressed("player_jump"):
		if player.is_on_floor():
			if not player.state == Player.State.DUCKING:
				_snap_vector = Vector2.ZERO
				_jump_timer.start()
				player.next_state = Player.State.JUMPING
			else:
				player.next_state = Player.State.JUMPING_DOWN

	elif player.state != Player.State.DUCKING \
	&& player.state != Player.State.WINDING_UP \
	&& player.state != Player.State.ATTACKING \
	&& Input.is_action_pressed("player_down"):
		if player.is_on_floor():
			player.next_state = Player.State.DUCKING
			player.vel.x = 0

	elif player.state == Player.State.DUCKING \
	&& !Input.is_action_pressed("player_down"):
		player.next_state = Player.State.IDLE

	elif player.state == Player.State.FALLING \
	&& player.is_on_floor():
		player.next_state = Player.State.LANDING

	elif (player.state == Player.State.IDLE || player.state == Player.State.WALKING || player.state == Player.State.ATTACKING || player.state == Player.State.LANDING) \
	&& Input.is_action_just_pressed("player_attack"):
		player.next_state = Player.State.WINDING_UP

	elif (player.state == Player.State.WINDING_UP) \
	&& Input.is_action_just_released("player_attack"):
		player.next_state = Player.State.ATTACKING

	elif (player.state == Player.State.DUCKING) \
	&& Input.is_action_just_pressed("player_attack"):
		player.next_state = Player.State.ATTACKING

	elif Input.is_action_just_pressed("player_cast") \
	&& player.selected_spell != Spells.NONE \
	&& player.is_on_floor():
		player.next_state = Player.State.CASTING

	elif player.state == Player.State.CASTING \
	&& Input.is_action_just_released("player_cast"):
		player.next_state = Player.State.IDLE

	if (!_jump_timer.is_stopped()):
		if Input.is_action_pressed("player_jump"):
			player.vel.y = -JUMP_FORCE
		else:
			_jump_timer.stop()

func _physics_process_climbing(delta):
	var x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var y_input = Input.get_action_strength("player_down") - Input.get_action_strength("player_up")

	var input = Vector2(x_input, y_input)
	if input != Vector2.ZERO:
		player.vel = input.normalized() * MAX_CLIMBING_SPEED * delta
		player.position += player.vel
	else:
		player.vel = Vector2.ZERO
