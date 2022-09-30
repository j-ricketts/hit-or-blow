# Contains just the game logic for the board. The purpose of this class is to
# abstract the board logic from the visuals.

extends Node

class_name BoardLogic
enum Status {MISS, BLOW, HIT}
var win_target : Array

func calc_hit_and_blows(pin_nums : Array):
	var placed_pins = []
	
	# For each pin number, create a list of hole numbers where that pin was placed.
	# For example, if the place pins are
	# (1)
	# (1)
	# (5)
	# (2)
	# then placed_pins will be
	# [[], [2, 3], [0], [], [], [1]]
	placed_pins.resize(6)
	for x in range(len(placed_pins)):
		placed_pins[x] = []
	for pin_index in range(len(pin_nums)):
		var pin_num = pin_nums[pin_index]
		if pin_num != -1:
			placed_pins[pin_num].append(pin_index)
	
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

	return statuses

func generate_random_target() -> Array:
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
	
	return win_target
