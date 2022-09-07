extends Node

class_name PinAnimator

var pin : Pin = get_parent()

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
var state = PinState.PLACED

var _tween_manager : TweenManager
 

func do_holding_anim():
	#print(pin)
	
	_tween_manager.play_tween("HoldPinPosTween", 0.5, 
		pin.translation, Vector3(pin.translation.x, _PIN_HOLD_HEIGHT, pin.translation.z))
	_tween_manager.play_tween("HoldPinRotTween", 0.5, 
		pin.rotation, Vector3(deg2rad(-30), 0, deg2rad(10)), false)


func do_move_place_anim(hole_pos : Vector3, move_first=true):
	pin.visible = true
	
	
	if !move_first:
		do_place_anim()
	else:
		state = PinState.MOVING
		_tween_manager.play_tween("HoldPinPosTween", 0.5, 
			pin.translation, Vector3(hole_pos.x, _PIN_HOLD_HEIGHT, hole_pos.z))


func _on_tween_completed(tween_name):
	if tween_name == "HoldPinPosTween" and self.state == PinState.PLACED:
		self.state = PinState.HOLDING
	elif tween_name == "RemovePinPosTween":
		self.state = PinState.REMOVED
	elif tween_name == "PlacePinRotTween":
		self.state = PinState.PLACED

	if self.state == PinState.MOVING:
		do_place_anim()
	elif self.state == PinState.REMOVED:
		pin.queue_free()
	elif remove_queued and state == PinState.PLACED:
		do_remove_anim()

func do_place_anim():
	state = PinState.PLACING
	_tween_manager.play_tween("PlacePinPosTween",
		0.5, pin.translation, Vector3(pin.translation.x, 0, pin.translation.z))
	_tween_manager.play_tween("PlacePinRotTween",
		0.2, pin.rotation, Vector3(0,0,0),false)


func remove():
	#self._tween_manager.connect("tween_completed", self, "_on_tween_completed")
	do_remove_anim()
	
	
func do_remove_anim():
	if self.state == PinState.PLACING or self.state == PinState.MOVING:
		remove_queued = true
		return

	_tween_manager.play_tween("RemovePinPosTween",
		0.2, pin.translation, Vector3(pin.translation.x, _PIN_REMOVE_HEIGHT, pin.translation.z))

func do_generate_pin_anim(hole_pos):
	pin.visible = false
	pin.translation = Vector3(0, 0.6, 0)
	pin.rotation = Vector3(deg2rad(-30), 0, deg2rad(10))
	yield(get_tree().create_timer(0.2), "timeout")
	pin.visible = true
	if state == PinState.PLACING or state == PinState.MOVING: # We started to place a pin before it had a chance to generate,
								  # so do not play the generation animation.
		return
	
	pin.translation = Vector3(0, _PIN_REMOVE_HEIGHT, 0)
	#pin.rotation = Vector3(deg2rad(-30), 0, deg2rad(10))
	
	_tween_manager.play_tween("GeneratePinPosTween", 0.5, 
			Vector3(pin.translation.x, _PIN_REMOVE_HEIGHT, pin.translation.z),
			Vector3(0, _PIN_HOLD_HEIGHT, 0))
	_tween_manager.play_tween("HoldPinRotTween", 0.5, 
		pin.rotation, Vector3(deg2rad(-30), 0, deg2rad(10)), false)



func _load_tween(tween_name, property):
	var tweens_root_node = get_node("/root/Spatial/Storage")
	_tween_manager.load_tween(
		tweens_root_node.get_node(tween_name), pin, property, self)
	
		#print(state)

func _ready():
	pin = get_parent()
	#print(pin)
	self._tween_manager = TweenManager.new()
	self._tween_manager.connect("tween_completed", self, "_on_tween_completed")
	self._load_tween("HoldPinPosTween", "translation")
	self._load_tween("RemovePinPosTween", "translation")
	self._load_tween("GeneratePinPosTween", "translation")
	self._load_tween("HoldPinRotTween", "rotation")
	self._load_tween("PlacePinPosTween", "translation")
	self._load_tween("PlacePinRotTween", "rotation")
	
	
