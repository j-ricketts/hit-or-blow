extends Spatial

class_name LogicSelect

export (bool) var selected = false
export (bool) var pin_num = 0

signal pin_set(is_set)

var click_area = load("res://Objects/LogicSelect/LogicSelect.tscn")
var pin = load("res://Objects/Pin/Pin.tscn")
var pin_instance: Pin 
var game_vars : GameVars


func _init(pin_num, pos, game_vars):
	self.game_vars = game_vars
	self.pin_num = pin_num
	
	
	
	add_child(click_area.instance())
	self.translation = pos
	
	pin_instance = pin.instance()
	pin_instance.initialise(pin_num)
	pin_instance.name = "Pin"
	add_child(pin_instance)
	
	#var click_area_instance = click_area.instance()
	get_node("LogicSelect").connect("input_event", self, "_on_LogicSelect_input_event")
	
	
	
	

func _on_LogicSelect_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed == true:
		game_vars.selected_pin = self.pin_num
			
		#print("%d, %d" % [level, row])
		#place_pin(level, row)
