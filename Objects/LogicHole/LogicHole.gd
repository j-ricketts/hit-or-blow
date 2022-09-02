extends Spatial

class_name LogicHole

export (bool) var pin_set setget set_pin, get_pin
export (int) var hole_level
export (int) var hole_row
export (bool) var hole_active = false

signal pin_set(is_set)

var click_area = load("res://Objects/LogicHole/LogicHole.tscn")
var pin = load("res://Objects/Pin/Pin.tscn")
var pin_instance
var game_vars : GameVars

func set_pin(val):
	pin_set = val
	
	if pin_set:
		pin_instance = pin.instance()
		pin_instance.initialise(game_vars.selected_pin)
		pin_instance.name = "Pin"
		add_child(pin_instance)
	else:
		pin_instance.queue_free()
	#pin_instance.translation = self.translation
	
	emit_signal("pin_set", val)
	
func get_pin():
	return pin_set

func _init(level, row, pos, game_vars):
	hole_level = level
	hole_row = row
	self.game_vars = game_vars
	
	
	add_child(click_area.instance())
	#var click_area_instance = click_area.instance()
	get_node("LogicHole").connect("input_event", self, "_on_LogicHole_input_event")
	
	self.translation = pos
	
	

func _on_LogicHole_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed == true:
		if hole_active:
			set_pin(!get_pin())
			
		#print("%d, %d" % [level, row])
		#place_pin(level, row)
