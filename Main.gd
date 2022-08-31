extends Spatial

var pin = load("res://Objects/Pin/Pin.tscn")
var click_area = load("res://Objects/ClickArea/ClickArea.tscn")

func place_pin(level, row):
	var pin_instance = pin.instance()
	$hitblow_board11.add_child(pin_instance)
	
	var pos = get_node("hitblow_board11/L%dR%d" % [level, row]).translation
	
	pin_instance.translation = pos
	
func place_pin_selects():
	for x in range(1, 7):
		var pin_instance = pin.instance()
		$hitblow_board11.add_child(pin_instance)
		var pos = get_node("hitblow_board11/P%d" % x).translation
		pin_instance.translation = pos
	
func create_click_hitbox(level, row):
	var click_area_instance = click_area.instance()
	$hitblow_board11.add_child(click_area_instance)
	var pos = get_node("hitblow_board11/L%dR%d" % [level, row]).translation
	click_area_instance.translation = pos
	click_area_instance.connect("input_event", self, "_on_Area_input_event", [level, row])
	
func create_click_hitboxes():
#	for x in range(1, 7):
#		var pos = get_node("hitblow_board11/P%d" % x).translation
#		create_click_hitbox(pos)

	for x in range(1,9):
		for y in range(1,5):
			create_click_hitbox(x, y)
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	Area.new()
	place_pin_selects()
#	for x in range(1,9):
#		for y in range(1,5):
#			place_pin(x,y)
	
	create_click_hitboxes()
	
	


func _on_Area_input_event(camera, event, position, normal, shape_idx, level, row):
	if event is InputEventMouseButton and event.pressed == true:
		print("%d, %d" % [level, row])
		place_pin(level, row)
	
