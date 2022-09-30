extends Spatial

class_name Pin

var _pin_animator : PinAnimator

func place(pos):
	_pin_animator.do_move_place_anim(pos)
	
func remove():
	_pin_animator.remove()
	
func hold():
	_pin_animator.do_holding_anim()

func _update_pin_property(val, property):
	self.set(property, val)
	
func initialise(pos, play_generate_anim=true, holding=true):
	_pin_animator = PinAnimator.new()
	add_child(_pin_animator)
	_pin_animator.initialise()
	_pin_animator.connect("anim_update", self, "_update_pin_property")

	if play_generate_anim:
		_pin_animator.do_generate_pin_anim(pos, !holding)
	else:
		translation = pos
