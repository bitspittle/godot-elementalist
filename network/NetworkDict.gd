# A dictionary with a timestamp for sending across the net

# To send:
# var data = NetworkDict.new()
# data.values["pos"] = Vector2(1, 2)
# data.rpc(some_node, "set_data")
#
# To receive:
# var _data = NetworkDict.new()
# func set_data(data):
#	if _data.update(data):
#		... data is up to date here

class_name NetworkDict

var throttle_msec = 0
var timestamp = 0
var values = {}
var last_values = {}

func rpc(target: Node, method: String) -> void:
	if _pre_send():
		target.rpc(method, [timestamp, values])

func rpc_unreliable(target: Node, method: String) -> void:
	if _pre_send():
		target.rpc_unreliable(method, [timestamp, values])

func _pre_send() -> bool:
	var new_timestamp = OS.get_ticks_msec()
	if (new_timestamp - timestamp) < throttle_msec:
		return false

	timestamp = new_timestamp
	if last_values.hash() != values.hash():
		last_values = values.duplicate()
		return true
	return false


func update(other) -> bool:
	var other_timestamp = other[0]
	var other_values = other[1]
	if other_timestamp > timestamp:
		timestamp = other_timestamp
		values = other_values
		last_values = values
		return true
	else:
		print("OUT OF ORDER")

	return false
