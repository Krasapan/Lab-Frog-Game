class_name AttrLinkSettings
var node: String
var attr: String
var timed_value: String
var value: float

func _init(node: String, attr: String, timed_value: String, value: float):
	self.node = node
	self.attr = attr
	self.timed_value = timed_value
	self.value = value
