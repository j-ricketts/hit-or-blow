extends Node

class_name Level

var holes : Array  = []

var NUM_HOLES = 4
var _level_num : int
var _game_vars : GameVars

signal level_completed()


func _create_logic_hole(board, row):
	var pos = board.get_node("L%dR%d" % [_level_num, row]).translation
	var logic_hole_instance : LogicHole = LogicHole.new(_level_num, row, pos, _game_vars)
	
	holes[row-1] = logic_hole_instance
	board.add_child(logic_hole_instance)

	logic_hole_instance.connect("pin_set", self, "_on_pin_set")

func set_active(val):
	for logic_hole in holes:
		logic_hole.hole_active = val	

func get_num_holes():
	return NUM_HOLES

# Returns the pin numbers of the placed pins from bottom to top.
# A missing pin has pin number -1.
func get_placed_pin_nums():
	var pin_nums : Array = []
	for pin_index in len(holes):
		var pin_num = holes[pin_index].pin_instance.pin_number
		pin_nums.append(pin_num)
	return pin_nums

func remove_pins():
	for y in range(len(holes)-1, -1, -1):
		holes[y].set_pin(false)
		yield(get_tree().create_timer(0.1), "timeout")

func _init(level_num, board : Spatial, game_vars):
	holes.resize(NUM_HOLES)
	
	self._level_num = level_num
	self._game_vars = game_vars
	for x in range(1, NUM_HOLES+1):
		_create_logic_hole(board, x)

func _check_complete():
	var all_set = true
	for logic_hole in holes:
		all_set = all_set and logic_hole.pin_set
		
	if all_set:
		emit_signal("level_completed")
	

func _on_pin_set(_is_set):
	_check_complete()
		
