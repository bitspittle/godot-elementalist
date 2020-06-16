extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 100
const FRICTION = .25
const GRAVITY = 1000
const JUMP_FORCE = 150

var SLOPE_THRESHOLD = deg2rad(46)
var DEFAULT_SNAP_VECTOR = Vector2.DOWN * 100.0 # Make sure we snip hard if walking down sleep slopes

var _vel = Vector2.ZERO
var _snap_vector = DEFAULT_SNAP_VECTOR

onready var _pivot = $Pivot
onready var _platform_detector: Area2D = $PlatformDetector
onready var _jump_timer: Timer = $JumpTimer

var _tmp_start_pos: Vector2

func _ready():
	_tmp_start_pos = position
	
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		_vel = Vector2.ZERO
		position = _tmp_start_pos
		set_collision_mask_bit(Constants.LAYER_PLATFORMS, true)


func _physics_process(delta):
	var last_vel_y = _vel.y
	var tmp_last_collision_mask = get_collision_mask_bit(Constants.LAYER_PLATFORMS)
	var x_input = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")

	if x_input != 0:
		if sign(x_input) != sign(_vel.x):
			_vel.x = 0 # quick turnaround
			_pivot.scale.x = sign(x_input)

		_vel.x += x_input * ACCELERATION * delta
		_vel.x = clamp(_vel.x, -MAX_SPEED, MAX_SPEED)

	else:
		_vel.x = 0

	_vel.y += GRAVITY * delta
	_vel.y = move_and_slide_with_snap(_vel, _snap_vector, Vector2.UP, true, 4, SLOPE_THRESHOLD).y
	_snap_vector = DEFAULT_SNAP_VECTOR

	# Re-enable platforms as long as we're fallling and aren't currently intersecting with anything
	if (_vel.y >= 0 && !get_collision_mask_bit(Constants.LAYER_PLATFORMS) && _platform_detector.get_overlapping_bodies().empty()):
		set_collision_mask_bit(Constants.LAYER_PLATFORMS, true)

	if Input.is_action_just_pressed("player_jump"):
		if is_on_floor():
			if not Input.is_action_pressed("player_down"):
				_snap_vector = Vector2.ZERO
				_jump_timer.start()
			set_collision_mask_bit(Constants.LAYER_PLATFORMS, false)
	
	if (!_jump_timer.is_stopped()):
		if Input.is_action_pressed("player_jump"):
			_vel.y = -JUMP_FORCE
		else:
			_jump_timer.stop()

