extends Node
## The audio lane's riot clip: the real World + CitySystem + CityView + CityCharacters (as the
## city_frame showcase builds them), a 300-person riot, Rivet circling it, and WorldAudio hung on
## the world (FX sink, Events hooks, city bed, radio). Record:
##   godot --rendering-driver d3d12 --path project --write-movie <f.avi> --fixed-fps 60
##     res://dev/audio/audio_riot.tscn -- --seconds=30 [--report=<file.json>]
## Headless runs work as a smoke test (the dummy audio driver).

const MASTER_SEED: int = 91
const RIOT: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const KNOWN: PackedStringArray = ["--seconds", "--report", "--demo"]
## --demo: a scripted tour of the sounds nothing fires yet (second -> what), see _demo().
const DEMO_AT: Dictionary = {
	5: "enter",
	9: "horn",
	11: "screech",
	13: "crash",
	15: "next",
	21: "wanted",
	25: "exit",
	26: "sting"
}

var _frames: int = 60 * 30
var _report: String = ""
var _n: int = 0
var _max_proj: int = 0
var _demo_on: bool = false
var _city: CitySystem = null
var _audio: AudioService = null
var _view: CityView = null
var _characters: CityCharacters = null


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN.has(flag):
			get_tree().quit(2)
			return
		if flag == "--demo":
			_demo_on = true
		elif flag == "--seconds":
			_frames = arg.get_slice("=", 1).to_int() * 60
		else:
			_report = arg.get_slice("=", 1)
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	add_child(world)
	_city = CitySystem.new(true)
	world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = RIOT
	_city.target = RIOT
	_city.spawner.riot_c = RIOT
	_city.spawner.targets = CityTargets.riot(300, 100)
	var view: CityView = CityView.new()
	add_child(view)
	view.setup(_city)
	_view = view
	_audio = WorldAudio.attach(world, world.context(), view, _city)
	_characters = CityCharacters.new(_city, view, world.context())
	await _characters.bake()
	await view.prewarm()


func _process(_delta: float) -> void:
	if _audio == null or _city == null:
		return
	_n += 1
	var t: float = _n / 60.0
	_city.target = RIOT + Vector2(cos(t * 0.3), sin(t * 0.3)) * 6.0
	_city.focus = _city.target
	var second: int = floori(_n / 60.0)
	if _demo_on and _n % 60 == 0 and DEMO_AT.has(second):
		var what: String = DEMO_AT[second]
		_demo(what)
	if _n % 30 == 0:
		_max_proj = maxi(_max_proj, _projectiles())
	if _n >= _frames:
		_done()


func _demo(what: String) -> void:
	var at: Vector2 = _city.target * SimConst.PX_PER_M
	var tick: int = _n
	if what == "enter":
		Events.vehicle_entered.emit(1)
	elif what == "exit":
		Events.vehicle_exited.emit(1)
	elif what == "wanted":
		Events.wanted_changed.emit(3)
	elif what == "sting":
		Events.contract_completed.emit(&"collect-call")
	elif what == "next":
		_radio().next()
	else:
		var id: StringName = {"horn": &"horn", "screech": &"tyre_screech", "crash": &"crash"}[what]
		_view.fx_triggers.fire(id, at, 0.0, tick)


func _radio() -> CarRadio:
	for n: Node in _audio.get_children():
		if n is CarRadio:
			return n
	return null


func _done() -> void:
	var out: Dictionary = {
		"frames": _n,
		"played": _audio.played,
		"dropped": _audio.dropped,
		"fx_fired": _view.fx_triggers.fired,
		"cops_near": _cops_within(20.0),
		"max_projectiles": _max_proj,
	}
	printerr("audio_riot: %s" % JSON.stringify(out))
	if _report != "":
		var f: FileAccess = FileAccess.open(_report, FileAccess.WRITE)
		if f != null:
			@warning_ignore("return_value_discarded")
			f.store_string(JSON.stringify(out, "  ", true))
	get_tree().quit(0)


func _cops_within(r_m: float) -> int:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var n: int = 0
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		var at: Vector2 = Vector2(snap[r + 4], snap[r + 5])
		if int(snap[r + 1]) == SimConst.K_COP and at.distance_to(_city.target) < r_m:
			n += 1
	return n


func _projectiles() -> int:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var n: int = 0
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			n = (snap.size() - r) / SimConst.SNAP_PROJ_STRIDE
			break
	return n
