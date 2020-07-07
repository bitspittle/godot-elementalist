extends Node

# A dictionary that gets synced regularly across a network connection

# Prerequisite:
# Create a SyncDict in your scene
#
# # From the master scene:
# onready var _data = $SyncedData
# func some_func():
#	if is_network_master():
#		# Setting data on puppets is harmless but best avoided
#		# to limit places the data gets set.
# 		_data.values["pos"] = position
#
# # From the puppet scene:
# func _ready():
# 	_data.connect("values_updated", self, "_on_data_updated")
# func _on_data_updated(): # will only be triggered on puppet
#	 position = _data.values["pos"]

class_name SyncDict

signal vaules_changed

export var reliable = false
export var throttle_msec = 30 # Ignored if reliable
var values = {}
# Convenient shorthand for syncdicts that only contain a single value
var value = null setget _set_value, _get_value

var _new_peers = []
var _timestamp = 0
var _last_values = {}
var _remaining_msec = 0.0

func _set_value(v):
	self.values["_"] = v

func _get_value():
	return self.values["_"]

func _ready():
	get_tree().connect("network_peer_connected", self, "_peer_connected")

func _peer_connected(id):
	_new_peers.append(id)

func _process(delta):
	if values.empty() || !NetUtils.is_master(self):
		return

	if !_new_peers.empty():
		for id in _new_peers:
			rpc_id(id, "_receive", _create_payload())
		_new_peers.clear()

	if reliable:
		if _last_values.hash() != values.hash():
			_last_values = values.duplicate()
			rpc("_receive", _create_payload())
	else:
		_remaining_msec -= delta
		if _remaining_msec <= 0:
			_remaining_msec = throttle_msec / 1000.0
			if _last_values.hash() != values.hash():
				_last_values = values.duplicate()
				rpc_unreliable("_receive", _create_payload())

func _create_payload():
	return [OS.get_ticks_msec(), values]

puppet func _receive(payload) -> void:
	var other_timestamp = payload[0]
	var other_values = payload[1]
	if other_timestamp > _timestamp:
		_timestamp = other_timestamp
		values = other_values
		if _last_values.hash() != values.hash():
			_last_values = values.duplicate()
			emit_signal("vaules_changed")
