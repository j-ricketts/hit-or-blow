extends Object
class_name TweenManager

var loaded_tweens = {}
var _playing_tweens : Dictionary = {}

signal tween_completed(object_name)
signal update(val, property)

func tween_update(val, obj, property):
	#print(obj.name)
	#obj.set(property, val)
	emit_signal("update", val, property)


func _on_tween_completed(object, _key):
	emit_signal("tween_completed", object.name)

func load_tween(tween_ref : CurveTween, obj, property, storage_loc):
	var tween : CurveTween = tween_ref.duplicate()
	var loaded_tween_inst = tween
	loaded_tweens[tween.name] = loaded_tween_inst
	tween.connect("curve_tween", self, "tween_update", [obj, property])
	tween.connect("tween_completed", self,"_on_tween_completed")
	storage_loc.add_child(tween)

# 
func play_tween(tween_name, duration, start_val, end_val, interrupt_other_tweens=true):
	if interrupt_other_tweens:
		for tween_name in _playing_tweens:
			_playing_tweens[tween_name].stop_all()
			
	var tween : CurveTween = loaded_tweens[tween_name]
	tween.play(duration, start_val, end_val)
	self._playing_tweens[tween_name] = tween
	
	
	
