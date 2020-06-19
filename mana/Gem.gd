extends Node2D

export var color: Color = Color(1.0, 1.0, 1.0, 1.0) setget _set_color

onready var _sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_color(color)


func _set_color(value: Color):
	color = value
	if _sprite == null: return

	_sprite.get_material().set_shader_param("color_modulate", value)

