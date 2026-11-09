extends Node
## scratch: RigStress for 600 ticks under --view, then one rendered frame to --png-out.

var _rigs: CharacterRigs = null
var _stress: RigStress = null
var _cam: Camera2D = null
var _frame: int = 0
var _out: String = ""


func _ready() -> void:
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--png-out="):
			_out = a.substr(10)
	get_window().size = Vector2i(1280, 720)
	_cam = Camera2D.new()
	add_child(_cam)
	_cam.zoom = Vector2(2.0, 2.0)
	_cam.make_current()
	var bus: EventBus = EventBus.new()
	var data: DataStore = DataStore.new()
	add_child(bus)
	add_child(data)
	_rigs = CharacterRigs.new()
	add_child(_rigs)
	_rigs.setup(World.build_context(bus, data, 9))
	_stress = RigStress.new(_rigs, 50)


func _process(_d: float) -> void:
	_frame += 1
	if _frame == 2:
		_stress.run(600)
		_cam.position = _rigs.focus
	elif _frame == 10:
		var img: Image = get_viewport().get_texture().get_image()
		var err: int = img.save_png(_out)
		printerr("framecmp: saved %s err=%d size=%s" % [_out, err, img.get_size()])
		get_tree().quit()
