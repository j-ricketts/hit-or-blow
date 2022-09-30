extends Spatial

class_name Board

var pin = load("res://Objects/Pin/Pin.tscn")
var hit_pin = load("res://Objects/HitPin/hit_pin.tscn")
var blow_pin = load("res://Objects/BlowPin/blow_pin.tscn")

export (Array) var levels = []
export (int) var selected_pin = 0

enum Status {MISS, BLOW, HIT}

var game_vars : GameVars = GameVars.new()
var win_target : Array

var win_target_dict = {}
var _pin_container : Node

var _board_logic : BoardLogic = BoardLogic.new()

func _generate_random_target():
	win_target = self._board_logic.generate_random_target()
	
	for x in range(len(win_target)):
		var pin_instance = pin.instance()
		var pos = get_node("W%d" % [x+1]).translation
		add_child(pin_instance)
		pin_instance.initialise_1(win_target[x], pos, false)
		
		pin_instance.name = "Pin"
		
		pin_instance.translation = pos
		

func _create_status_pin(type):
	var pin : Spatial
	if type == Status.HIT:
		pin = hit_pin.instance()
	else:
		pin = blow_pin.instance()
		
	return pin

func _place_hit_and_blows(level):
	var pin_nums : Array =levels[level].get_placed_pin_nums()
	
	var statuses = self._board_logic.calc_hit_and_blows(pin_nums)
		
	for x in range(len(statuses)):
		var status = statuses[-x-1]
		var pos = get_node("S%dH%d" % [level+1, x+1]).translation
		var pin = self._create_status_pin(status)
		self._pin_container.add_child(pin)
		pin.initialise(pos, true, false)
		yield(get_tree().create_timer(0.1), "timeout")
	
func _place_logic_select(pin_num):
	var pos = get_node("P%d" %  (pin_num+1) ).translation
	var logic_select = LogicSelect.new(pin_num, pos, game_vars)
	self.add_child(logic_select)
	logic_select.generate_new_pin()
	
func place_logic_selects():
	for pin_num in range(6):
		_place_logic_select(pin_num)
	
	
func _create_levels():
	for x in range(1, 9):
		var level : Level = Level.new(x, self, game_vars)
		level.connect("level_completed", self, "_on_level_completed")
		levels[x-1] = level
		
	levels[0].set_active(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.get_parent())
	self.get_parent().call_deferred("add_child", game_vars)
	
	
	_pin_container = Spatial.new()
	_pin_container.name = "PinContainer"
	
	add_child(_pin_container)
	
	game_vars.name = "GameVars"
	
	levels.resize(8)
		
	#$Cover.open()
	place_logic_selects()
	_create_levels()
	
	
	self._generate_random_target()
	
func reset():
	for level in levels:
		level.remove_pins()
			
	for n in _pin_container.get_children():
		n.get_node("PinAnimator").do_remove_anim()
		yield(get_tree().create_timer(0.1), "timeout")
		
	levels[0].set_active(true)

func advance_level():
	levels[game_vars.curr_level].set_active(false)
	game_vars.curr_level += 1
	if game_vars.curr_level >= len(levels):
		game_vars.curr_level = 0
		return 0
	
	levels[game_vars.curr_level].set_active(true)
		
	return 1

func _on_level_completed():
	_place_hit_and_blows(game_vars.curr_level)
	if !advance_level():
		reset()
