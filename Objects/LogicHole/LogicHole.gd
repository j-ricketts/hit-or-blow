extends Spatial

class_name LogicHole

export (bool) var pin_set setget set_pin, get_pin
export (int) var hole_level
export (int) var hole_row
export (bool) var hole_active = false

signal pin_set(is_set)

var click_area = load("res://Objects/LogicHole/LogicHole.tscn")
var pin = load("res://Objects/Pin/Pin.tscn")
var pin_instance : Spatial
var game_vars : GameVars

func set_pin(val):
	if game_vars.selected_pin == -1:
		return
	
	pin_set = val
	
	if pin_set:
		var logic_select : LogicSelect = get_parent().get_node("LogicSelect%d"%game_vars.selected_pin)
		var pos = logic_select.pin_instance.global_transform.origin
		
		self.pin_instance = logic_select.remove_pin_from_select()
		
		add_child(pin_instance)
		self.pin_instance.global_transform.origin = pos
		#pin_instance.set_global_position( pos)
		pin_instance.get_node("PinAnimator").do_move_place_anim(Vector3(0,0,0))
		
		logic_select.generate_new_pin()
	else:
		pin_instance.get_node("PinAnimator").remove()
		
	#pin_instance.translation = self.translation
	
	emit_signal("pin_set", val)
	
func get_pin():
	return pin_set

func _init(level, row, pos, game_vars):
	hole_level = level
	hole_row = row
	self.game_vars = game_vars
	self.name = "LogicHoleL%dR%d" % [level, row]
	
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
