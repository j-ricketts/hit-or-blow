extends Node

class_name PinAnimator

var pin : Spatial = get_parent()

var _PIN_HOLD_HEIGHT = 0.15
var _PIN_REMOVE_HEIGHT = 0.6 # How high the pin is brought up before it is destroyed

var remove_pin_pos_tween : CurveTween 
var hold_pin_rot_tween : CurveTween
var hold_pin_pos_tween : CurveTween
var place_pin_rot_tween : CurveTween
var place_pin_pos_tween : CurveTween
var generate_pin_pos_tween : CurveTween

enum PinState {PLACED, HOLDING, MOVING, PLACING, REMOVING, REMOVED}
var remove_queued : bool = false
var state = PinState.PLACED setget set_state, get_state

var _tween_manager : TweenManager

signal anim_update(val, property)

func set_state(new_state):
	state = new_state
	
	if self.state == PinState.PLACING:
		do_place_anim()
	elif self.state == PinState.REMOVED:
		pin.queue_free()

	
	#print(PinState.keys()[state])

func get_state():
	return state

func do_holding_anim():
	#print(pin)
	
	_tween_manager.play_tween("HoldPinPosTween", 0.5, 
		pin.translation, Vector3(pin.translation.x, _PIN_HOLD_HEIGHT, pin.translation.z))
	_tween_manager.play_tween("HoldPinRotTween", 0.5, 
		pin.rotation, Vector3(deg2rad(-30), 0, deg2rad(10)), false)


func do_move_place_anim(hole_pos : Vector3):
	pin.visible = true
	#
	var move_first =true
	if hole_pos.x == pin.translation.x and hole_pos.z == pin.translation.z:
		move_first = false
		
	if !move_first:
		set_state(PinState.PLACING)
	else:
		set_state(PinState.MOVING)
		_tween_manager.play_tween("HoldPinPosTween", 0.5, 
			pin.translation, Vector3(hole_pos.x, _PIN_HOLD_HEIGHT, hole_pos.z))


func _on_tween_completed(tween_name):
	if tween_name == "HoldPinPosTween" and self.state == PinState.PLACED:
		set_state(PinState.HOLDING)
	elif tween_name == "HoldPinPosTween" and self.state == PinState.MOVING:
		set_state(PinState.PLACING)
	elif tween_name == "RemovePinPosTween":
		set_state(PinState.REMOVED)
	elif tween_name == "PlacePinRotTween":
		set_state(PinState.PLACED)
		
	if remove_queued:
		do_remove_anim()

	

func do_place_anim():
	
	_tween_manager.play_tween("PlacePinPosTween",
		0.5, pin.translation, Vector3(pin.translation.x, 0, pin.translation.z))
	_tween_manager.play_tween("PlacePinRotTween",
		0.2, pin.rotation, Vector3(0,0,0),false)


func remove():
	#self._tween_manager.connect("tween_completed", self, "_on_tween_completed")
	do_remove_anim()
	
	
func do_remove_anim():
	if self.state == PinState.MOVING:
		remove_queued = true
		return
	remove_queued = false
	set_state(PinState.REMOVING)
	_tween_manager.play_tween("RemovePinPosTween",
		0.2, pin.translation, Vector3(pin.translation.x, _PIN_REMOVE_HEIGHT, pin.translation.z))

func do_generate_pin_anim(hole_pos, place=false, delay=0.2):
	pin.visible = false
	pin.translation = hole_pos + Vector3(0, self._PIN_REMOVE_HEIGHT, 0)
	pin.rotation = Vector3(deg2rad(-30), 0, deg2rad(10))
	yield(get_tree().create_timer(delay), "timeout")
	pin.visible = true
	if state == PinState.PLACING or state == PinState.MOVING: # We started to place a pin before it had a chance to generate,
								  # so do not play the generation animation.
		return
	
	
	#pin.rotation = Vector3(deg2rad(-30), 0, deg2rad(10))
	if place:
			_tween_manager.play_tween("GeneratePinPosTween", 0.5, 
			Vector3(pin.translation.x, _PIN_REMOVE_HEIGHT, pin.translation.z),
			hole_pos)
			_tween_manager.play_tween("HoldPinRotTween", 0.5, 
			pin.rotation, Vector3(0, 0, 0), false)
	else:
		
		_tween_manager.play_tween("GeneratePinPosTween", 0.5, 
				Vector3(pin.translation.x, _PIN_REMOVE_HEIGHT, pin.translation.z),
				Vector3(pin.translation.x, _PIN_HOLD_HEIGHT, pin.translation.z))
		_tween_manager.play_tween("HoldPinRotTween", 0.5, 
			pin.rotation, Vector3(deg2rad(-30), 0, deg2rad(10)), false)


func _load_tween(tween_name, property):
	var tweens_root_node = get_node("/root/Spatial/Storage")
	_tween_manager.load_tween(
		tweens_root_node.get_node(tween_name), pin, property, self)
	
		#print(state)

func _on_update(val, property):
	emit_signal("anim_update", val, property)


func initialise():
	pin = get_parent()
	#print(pin)
	self._tween_manager = TweenManager.new()
	self._tween_manager.connect("tween_completed", self, "_on_tween_completed")
	self._tween_manager.connect("update", self, "_on_update")
	self._load_tween("HoldPinPosTween", "translation")
	self._load_tween("RemovePinPosTween", "translation")
	self._load_tween("GeneratePinPosTween", "translation")
	self._load_tween("HoldPinRotTween", "rotation")
	self._load_tween("PlacePinPosTween", "translation")
	self._load_tween("PlacePinRotTween", "rotation")

