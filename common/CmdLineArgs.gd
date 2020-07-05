class_name CmdLineArgs

static func is_set(arg: String) -> bool:
	var args = Array(OS.get_cmdline_args())
	for _arg in args:
		if _arg == arg || _arg.begins_with(arg + "="):
			return true

	return false

static func get_str_value(arg: String) -> String:
	var args = Array(OS.get_cmdline_args())
	for _arg in args:
		if _arg.begins_with(arg + "="):
			return _arg.split("=")[1]

	return ""

static func get_int_value(arg: String) -> int:
	return get_str_value(arg).to_int()

static func get_bool_value(arg: String) -> bool:
	return get_str_value(arg).to_lower() == "true"
