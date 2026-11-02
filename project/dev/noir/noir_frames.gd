class_name NoirFrames
extends Node
## D-Noir A/B frames (lane noir): the real World + CitySystem + CityView, the same seed and the
## same moments, printed in D4 and in D-Noir back to back, at 32, 48 and 64 px/m, for three
## scenes (the junction riot, a street with crowd, the roofs). The world is paused (process off)
## while one moment is shot in both looks, so the pair is the same frame. Windowed only.
## Usage: godot --path project res://dev/noir/noir_frames.tscn -- --out=<dir>

const KNOWN_FLAGS: PackedStringArray = ["--out", "--scenes", "--crowd"]
const MASTER_SEED: int = 91
const JUNCTION: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const SCENES: Dictionary[String, Vector2] = {
	"junction": JUNCTION,
	"street": JUNCTION + Vector2(-22.0, 0.0),
	"roofs": JUNCTION + Vector2(22.0, 26.0),
}
const ZOOMS: Array[float] = [1.0, 1.5, 2.0]
const SETTLE_FRAMES: int = 90
const CROWD_SHADER: String = "res://assets/shaders/look_noir_crowd.gdshader"
const RAIN_PHASE: float = 37.0

var _out: String = "user://noir"
var _only: String = ""
var _crowd_ink: bool = false
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
		elif flag == "--crowd":
			_crowd_ink = arg.ends_with("=ink")
		else:
			_only = arg.substr(flag.length() + 1)
	_ok(DirAccess.make_dir_recursive_absolute(_out) == OK)
	# The rigs redraw on sim ticks only: with --crowd=ink the noir part print is on for the whole
	# run and the world is NOT paused for the shots (the pair is then a few ticks apart).
	PartMaterials.set_noir(_crowd_ink)
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
	var built: Array = build_city(self)
	_world = built[0]
	_view = built[1]
	_city = built[2]
	_view.noir.fixed_phase = RAIN_PHASE
	_characters = built[3]


## The junction riot city (seed 91) under `host`, the noir pass on: [World, CityView,
## CitySystem, CityCharacters]. Shared with the fight clip.
static func build_city(host: Node) -> Array:
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	host.add_child(world)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	city.steer_by_input = false
	city.focus = JUNCTION
	city.target = JUNCTION
	var t: CityTargets = CityTargets.riot(110, 16)
	t.cars = 40
	t.police_cars = 4
	city.spawner.targets = t
	city.spawner.riot_c = JUNCTION
	var view: CityView = CityView.new()
	host.add_child(view)
	view.setup(city)
	view.set_noir(true)
	var chars: CityCharacters = CityCharacters.new(city, view, world.context())
	return [world, view, city, chars]


func _scene(scene: String, focus: Vector2) -> int:
	_city.focus = focus
	_city.target = focus
	var n: int = 0
	for zoom: float in ZOOMS:
		_view.zoom = zoom
		_world.process_mode = Node.PROCESS_MODE_INHERIT
		for i: int in SETTLE_FRAMES:
			await get_tree().process_frame
		if not _crowd_ink:
			_world.process_mode = Node.PROCESS_MODE_DISABLED
		var ppm: int = roundi(zoom * SimConst.PX_PER_M)
		for look: String in ["d4", "noir"]:
			_view.set_noir(look == "noir")
			if _crowd_ink:
				_ink_crowd()
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


## Experiment (--crowd=ink): the baked crowd as ink silhouettes with a lit-side white rim.
func _ink_crowd() -> void:
	var people: MultiMeshInstance2D = _view.crowd.nodes[SimConst.RL_PEDS]
	var old: ShaderMaterial = people.material as ShaderMaterial
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = load(CROWD_SHADER) as Shader
	m.set_shader_parameter(&"cols", old.get_shader_parameter(&"cols"))
	m.set_shader_parameter(&"rows", old.get_shader_parameter(&"rows"))
	people.material = m
	printerr(
		"noir_frames: crowd shader %s (was %s)" % [m.shader.resource_path, old.shader.resource_path]
	)
