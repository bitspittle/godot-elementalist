class_name NetUtils

# Workaround that node.is_network_master returns false in single player mode
static func is_master(node: Node) -> bool:
	return node.get_tree().network_peer == null || node.is_network_master()
