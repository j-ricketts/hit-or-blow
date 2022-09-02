extends Spatial

class_name Board

var pin = load("res://Objects/Pin/Pin.tscn")
var hit_pin = load("res://Objects/HitPin/hit_pin.tscn")
var blow_pin = load("res://Objects/BlowPin/blow_pin.tscn")

export (Array, Array) var holes = []
export (int) var selected_pin = 0

var game_vars : GameVars = GameVars.new()
var win_target : Array

var win_target_dict = {}

func _generate_random_target():
	randomize()

	# The probability of choosing a target with two of the same pin
	# should be much lower than choosing one with all unique pins.
	var random_list = range(6)
	random_list.shuffle()
	win_target = random_list.slice(0,2)
	
	var contains_double = randf() < 0.1
	if !contains_double:
		win_target.append(random_list[3])
	else:
		win_target.append(randi() % win_target.size())
	
	for pin_num in win_target:
		if not win_target_dict.has(pin_num):
			win_target_dict[pin_num] = 1
		else:
			win_target_dict[pin_num] += 1
	print(win_target_dict)
	
	for x in range(len(win_target)):
		var pin_instance = pin.instance()
		pin_instance.initialise(win_target[x])
		pin_instance.name = "Pin"
		var pos = get_node("W%d" % [x+1]).translation
		pin_instance.translation = pos
		add_child(pin_instance)
		

enum Status {MISS, BLOW, HIT}

func _place_hit_and_blows(level):
	var placed_pins = []
	placed_pins.resize(6)
	for x in range(len(placed_pins)):
		placed_pins[x] = []
	for pin_index in range(len(holes[level])):
		var logic_hole = holes[level][pin_index]
		if logic_hole.pin_instance:
			placed_pins[logic_hole.pin_instance.pin_number].append(pin_index)
	
	var statuses = []
	for win_index in range(len(win_target)):
		var pin_num = win_target[win_index]
		var status = Status.MISS
		var chosen_pin
		for x in range(len(placed_pins[pin_num])):
			var pin_index = placed_pins[pin_num][x]
			if win_index == pin_index:
				status = Status.HIT
				chosen_pin = x
				break
			else:
				status = Status.BLOW
				chosen_pin = x
		
		if status != Status.MISS:
			placed_pins[pin_num].remove(chosen_pin)
			statuses.append(status)
	
	statuses.sort()
		
	for x in range(len(statuses)):
		var status = statuses[x]
		if status == Status.HIT:
			var pos = get_node("S%dH%d" % [level+1, x+1]).translation
			var hit_pin_instance = hit_pin.instance()	
			self.add_child(hit_pin_instance)
			hit_pin_instance.translation = pos
		else:
			var pos = get_node("S%dH%d" % [level+1, x+1]).translation
			var blow_pin_instance = blow_pin.instance()	
			self.add_child(blow_pin_instance)
			blow_pin_instance.translation = pos

func place_pin(level, row):
	var pin_instance = pin.instance()
	self.add_child(pin_instance)
	
	var pos = get_node("L%dR%d" % [level, row]).translation
	
	pin_instance.translation = pos
	
func place_pin_selects():
	for pin_num in range(6):
		var pos = get_node("P%d" %  (pin_num+1) ).translation
		var logic_select = LogicSelect.new(pin_num, pos, game_vars)
		self.add_child(logic_select)
	
func create_logic_hole(level, row):
	var pos = get_node("L%dR%d" % [level, row]).translation
	var logic_hole_instance : LogicHole = LogicHole.new(level, row, pos, game_vars)
	
	holes[level-1][row-1] = logic_hole_instance
	self.add_child(logic_hole_instance)
	if level == 1:
		logic_hole_instance.hole_active = true
	
	logic_hole_instance.connect("pin_set", self, "_on_pin_set")
	
	#click_area_instance.connect("input_event", self, "_on_Area_input_event", [level, row])
	
func create_logic_holes():
	for x in range(1,9):
		for y in range(1,5):
			create_logic_hole(x, y)
	



# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.get_parent())
	self.get_parent().call_deferred("add_child", game_vars)
	game_vars.name = "GameVars"
	
	holes.resize(8)
	for x in range(len(holes)):
		holes[x] = []
		holes[x].resize(4)
		
	place_pin_selects()
	create_logic_holes()
	
	
	self._generate_random_target()
	
	
func advance_level():
	for logic_hole in holes[game_vars.curr_level]:
		logic_hole.hole_active = false
	game_vars.curr_level += 1
	for logic_hole in holes[game_vars.curr_level]:
		logic_hole.hole_active = true

func _on_pin_set(is_set):
	
	var all_set = true
	for logic_hole in holes[game_vars.curr_level]:
		all_set = all_set and logic_hole.pin_set
	if all_set:
		_place_hit_and_blows(game_vars.curr_level)
		advance_level()
	
