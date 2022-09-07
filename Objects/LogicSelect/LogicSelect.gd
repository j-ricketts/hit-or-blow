extends Spatial

class_name LogicSelect

export (bool) var selected = false setget set_selected, get_selected
export (bool) var pin_num = 0

signal pin_set(is_set)

var click_area = load("res://Objects/LogicSelect/LogicSelect.tscn")
var pin = load("res://Objects/Pin/Pin.tscn")
var pin_instance: Pin 
var game_vars : GameVars


func set_selected(val):	
	if val and not selected:
		game_vars.selected_pin = self.pin_num
		self.pin_instance.get_node("PinAnimator").do_holding_anim()
	elif not val and selected:
		self.pin_instance.get_node("PinAnimator").do_move_place_anim(Vector3(0,0,0), false)

	# Deselecting by clicking the pin we are holding
	if not val and game_vars.selected_pin == self.pin_num:
		game_vars.selected_pin = -1

	selected = val

	
	
func get_selected():
	return selected

func _init(pin_num, pos, game_vars : GameVars):
	self.game_vars = game_vars
	self.pin_num = pin_num
	self.name = "LogicSelect%d" % pin_num
	
	
	add_child(click_area.instance())
	self.translation = pos
	
	pin_instance = pin.instance()
	pin_instance.initialise(pin_num)
	pin_instance.name = "SelectPin"
	add_child(pin_instance)
	
	#var click_area_instance = click_area.instance()
	get_node("LogicSelect").connect("input_event", self, "_on_LogicSelect_input_event")
	game_vars.connect("selected_pin_changed", self, "_on_curr_pin_changed")
	

func _on_curr_pin_changed(old_pin_num, new_pin_num):
	if new_pin_num != self.pin_num:
		self.set_selected(false)

# Places the pin in the specified hole, and generates a new one for selection.
func remove_pin_from_select():
	remove_child(pin_instance)
#		pin_instance.initialise(game_vars.selected_pin)
	pin_instance.name = "Pin"
	
	var temp_pin = self.pin_instance
	self.pin_instance = null
	
	return temp_pin
	
func generate_new_pin():
	
	var new_pin = pin.instance()
	new_pin.initialise(pin_num)
	new_pin.name = "SelectPin"
	
	add_child(new_pin)
	self.pin_instance = new_pin
	
	
	new_pin.get_node("PinAnimator").do_generate_pin_anim(self.translation)
	

func _on_LogicSelect_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed == true:
		
		set_selected(!get_selected())
			
		#print("%d, %d" % [level, row])
		#place_pin(level, row)
