extends Node

onready var _tween = $Tween

const DEFAULT_DURATION = 0.1
var _target = 1.0

func scale(percent: float, duration: float = DEFAULT_DURATION) -> void:
	_tween.stop_all()
	_tween.interpolate_property(self, "_target", 1.0, percent, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()

func restore(duration: float = DEFAULT_DURATION) -> void:
	_tween.stop_all()
	_tween.interpolate_property(self, "_target", Engine.time_scale, 1.0, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()
	
func _process(_delta):
	if not _tween.is_active(): return
	
	Engine.time_scale = _target
