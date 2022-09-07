extends Node

class_name GameVars

signal selected_pin_changed

export (int) var selected_pin = -1 setget set_selected_pin, get_selected_pin
export (int) var curr_level = 0

func get_selected_pin():
	return selected_pin
	
func set_selected_pin(pin_num):
	var old_pin_num = selected_pin
	selected_pin = pin_num
	self.emit_signal("selected_pin_changed", old_pin_num, pin_num)
