extends Node
## D-Noir A/B frames (lane noir): the real World + CitySystem + CityView, the same seed and the
## same moments, printed in D4 and in D-Noir back to back, at 32, 48 and 64 px/m, for three
## scenes (the junction riot, a street with crowd, the roofs). The world is paused (process off)
## while one moment is shot in both looks, so the pair is the same frame. Windowed only.
## Usage: godot --path project res://dev/noir/noir_frames.tscn -- --out=<dir>

const KNOWN_FLAGS: PackedStringArray = ["--out", "--scenes"]
const MASTER_SEED: int = 91
const JUNCTION: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const SCENES: Dictionary[String, Vector2] = {
	"junction": JUNCTION,
	"street": JUNCTION + Vector2(-22.0, 0.0),
	"roofs": JUNCTION + Vector2(22.0, 26.0),
}
const ZOOMS: Array[float] = [1.0, 1.5, 2.0]
const SETTLE_FRAMES: int = 90
const RAIN_PHASE: float = 37.0

var _out: String = "user://noir"
var _only: String = ""
var _world: World = null
var _city: CitySystem = null
var _view: CityView = null
var _characters: CityCharacters = null


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			printerr("noir_frames: unknown argument %s" % arg)
			get_tree().quit(2)
			return
		if flag == "--out":
			_out = arg.substr(flag.length() + 1)
		else:
			_only = arg.substr(flag.length() + 1)
	_ok(DirAccess.make_dir_recursive_absolute(_out) == OK)
	_build()
	await _characters.bake()
	await _view.prewarm()
	var saved: int = 0
	for scene: String in SCENES:
		if _only != "" and not _only.split(",").has(scene):
			continue
		saved += await _scene(scene, SCENES[scene])
	printerr("noir_frames: saved %d frames to %s" % [saved, _out])
	get_tree().quit(0 if saved > 0 else 1)


func _build() -> void:
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	_city = CitySystem.new(true)
	_world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = JUNCTION
	_city.target = JUNCTION
	var t: CityTargets = CityTargets.riot(110, 16)
	t.cars = 40
	t.police_cars = 4
	_city.spawner.targets = t
	_city.spawner.riot_c = JUNCTION
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	_view.set_noir(true)
	_view.noir.fixed_phase = RAIN_PHASE
	_characters = CityCharacters.new(_city, _view, _world.context())


func _scene(scene: String, focus: Vector2) -> int:
	_city.focus = focus
	_city.target = focus
	var n: int = 0
	for zoom: float in ZOOMS:
		_view.zoom = zoom
		_world.process_mode = Node.PROCESS_MODE_INHERIT
		for i: int in SETTLE_FRAMES:
			await get_tree().process_frame
		_world.process_mode = Node.PROCESS_MODE_DISABLED
		var ppm: int = roundi(zoom * SimConst.PX_PER_M)
		for look: String in ["d4", "noir"]:
			_view.set_noir(look == "noir")
			for i: int in 3:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var img: Image = get_viewport().get_texture().get_image()
			var file: String = "%s-%s-%dppm.png" % [scene, look, ppm]
			if img.save_png(_out.path_join(file)) == OK:
				n += 1
	return n


func _ok(cond: bool) -> void:
	if not cond:
		printerr("noir_frames: cannot create %s" % _out)
