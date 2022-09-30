extends MeshInstance

var _tween_manager :TweenManager

func close():
	self._tween_manager.play_tween("PlacePinPosTween", 3, 
		self.rotation, 
		Vector3(deg2rad(90),deg2rad(-90),deg2rad(-90) ))
	
func open():
	self._tween_manager.play_tween("PlacePinPosTween", 3, 
		self.rotation, 
		Vector3(deg2rad(-53.32),deg2rad(90),deg2rad(90) ))


func _load_tween(tween_name, property):
	var tweens_root_node = get_node("/root/Spatial/Storage")
	_tween_manager.load_tween(
		tweens_root_node.get_node(tween_name), self, property, self)
	
		#print(state)

func _ready():
	self._tween_manager = TweenManager.new()
	self._load_tween("PlacePinPosTween", "rotation")
