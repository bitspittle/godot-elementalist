tool
extends Control

class_name PercentBar

export(Color, RGB) var fill_color = Color.white setget set_fill_color
export(Color, RGB) var empty_color = Color(.2, .2, .2) setget set_empty_color

export(int) var border_width = 1 setget set_border_width
export(float, 0, 1, 0.1) var percent = 1 setget set_percent

onready var fill_color_rect = $FillColorRect
onready var empty_color_rect = $EmptyColorRect

func _ready():
	_update_ui()

func set_fill_color(value):
	fill_color = value
	_update_ui()

func set_empty_color(value):
	empty_color = value
	_update_ui()

func set_border_width(value):
	border_width = value
	_update_ui()

func set_percent(value):
	percent = clamp(value, 0, 1)
	_update_percent()

func _update_ui():
	if not is_inside_tree():
		return

	# Colors
	fill_color_rect.color = fill_color
	empty_color_rect.color = empty_color

	# Border
	fill_color_rect.rect_position.x = border_width
	empty_color_rect.rect_position.x = border_width
	fill_color_rect.rect_position.y = border_width
	empty_color_rect.rect_position.y = border_width
	fill_color_rect.margin_right = -border_width
	empty_color_rect.margin_right = -border_width
	fill_color_rect.margin_bottom = -border_width
	empty_color_rect.margin_bottom = -border_width

	_update_percent()

func _update_percent():
	if not is_inside_tree():
		return

	var max_width = rect_size.x - border_width * 2
	fill_color_rect.margin_right = -border_width - (max_width - max_width * percent)


func _on_PercentBar_resized():
	_update_percent()
