extends Pin

class_name PlayPin

export (int) var pin_number setget set_pin_num, get_pin_num




var pin_colours : Array = [Color.chartreuse,
							Color.brown,
							Color.coral,
							Color.cornflower,
							Color.gold,
							Color.fuchsia]

func set_pin_num(val):
	if val < 0 or val >= len(pin_colours):
		print("WARNING: pin number %d out of range. pin_number was not set.")
		return
	pin_number = val;
	var newMat : SpatialMaterial = SpatialMaterial.new()
	newMat.roughness = 0.4
	newMat.albedo_color = pin_colours[val]
	
	self.get_node("Cylinder002").set_surface_material(0, newMat)

	
func get_pin_num():
	return pin_number
	


func initialise_1(pin_number, pos, play_generate_anim=true, holding=true):
	set_pin_num(pin_number)
	.initialise(pos, play_generate_anim, holding)
