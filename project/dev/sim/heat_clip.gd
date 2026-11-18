extends Node
## n18 police: a clip of the streamed city's police at a forced heat (items 3-5 evidence). The
## real World + CitySystem + CityHeat + CityView (as dev/showcase/city_frame.gd builds them) on
## the sandbox's street targets; the camera parked on the last-seen point A. At --heat-at the
## script does what a witnessed kill at A does (CityHeat: level, last-seen A) and moves Rivet to B,
## 60 m off and out of every cop's sight, so the ladder answers A alone. Saves a PNG every --every
## ticks and timeline.json (heat, engaged cops, cops within 4 m of A, per saved tick).
## Windowed only (a renderer). Usage (one tick per frame):
##   godot --rendering-driver d3d12 --path project --fixed-fps 60 --resolution 1280x720
##     --position 0,1440 res://dev/sim/heat_clip.tscn -- --out=<abs dir> [--level=1]
##     [--police=living|pre] (pre: the pre-n18 sim police, set_heat -1, the same patrol)
##     [--heat-at=180] [--seconds=30] [--every=4] [--zoom=1] (1 = 32 px/m)
##     [--watch=a|block] (block: the camera moves to the heat 3 roadblock once it stands)

const KNOWN_FLAGS: PackedStringArray = [
	"--out",
	"--level",
	"--police",
	"--heat-at",
	"--seconds",
	"--every",
	"--zoom",
	"--view",
	"--watch"
]
const MASTER_SEED: int = 18
## A: a sandbox street west of the start; B: where Rivet goes once heat is up.
const A: Vector2 = CitySystem.START
const B: Vector2 = CitySystem.START + Vector2(4.0, 60.0)
const NEAR_M: float = 4.0

var _out: String = ""
var _level: int = 1
var _living: bool = true
var _heat_at: int = 180
var _seconds: float = 30.0
var _every: int = 4
var _zoom: float = 1.0
var _city: CitySystem = null
var _heat: CityHeat = null
var _view: CityView = null
var _label: Label = null
var _rows: Array[Dictionary] = []
var _raised: bool = false
var _watch_block: bool = false


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	_city = CitySystem.new(true)
	world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = A
	_city.target = A
	_heat = CityHeat.new(_city)
	world.add_system(_heat)
	_heat.tune.living = _living
	_view = CityView.new()
	_view.zoom = _zoom
	add_child(_view)
	_view.setup(_city)
	var characters: CityCharacters = CityCharacters.new(_city, _view, world.context())
	await characters.bake()
	await _view.prewarm()
	_view.add_child(HeatClipMark.new(A * SimConst.PX_PER_M))
	_label = _make_label()
	add_child(world)
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		get_tree().quit(2)
		return
	await _record(world)


func _record(world: World) -> void:
	var total: int = _heat_at + roundi(_seconds * SimClock.TICK_RATE)
	var saved: int = 0
	while true:
		await RenderingServer.frame_post_draw
		var tick: int = world.context().clock.tick()
		if tick >= _heat_at and not _raised:
			_raise()
		if tick >= total:
			break
		if _watch_block and _heat.roadblock.placed > 0:
			_city.focus = _heat.roadblock.at
		if tick % _every != 0:
			continue
		var row: Dictionary = _sample(tick)
		_label.text = (
			"t%d  heat %d  engaged %d  near A %d (squad %d)  block %d, queued %d  (%s)"
			% [
				tick,
				row["level"],
				row["engaged"],
				row["near"],
				row["squad_near"],
				row["block"],
				row["queued"],
				_arm()
			]
		)
		var img: Image = get_viewport().get_texture().get_image()
		if img != null and img.save_png(_out.path_join("f_%05d.png" % saved)) == OK:
			saved += 1
	var f: FileAccess = FileAccess.open(_out.path_join("timeline.json"), FileAccess.WRITE)
	var ok: bool = f != null and f.store_string(JSON.stringify({"rows": _rows, "A": [A.x, A.y]}))
	Log.info("heat_clip", "saved %d frames to %s" % [saved, _out])
	get_tree().quit(0 if ok and saved > 0 else 1)


## What a witnessed kill at A does (CityHeat.step: raise, last-seen); then Rivet leaves for B.
func _raise() -> void:
	_heat.last_seen = A
	_heat.ever_seen = true
	_heat.meter.set_level(_level)
	_city.target = B
	_raised = true


func _sample(tick: int) -> Dictionary:
	var near: int = 0
	var cars: int = 0
	var cops: Array = []
	var snap: PackedFloat64Array = _city.sim.snapshot()
	for k: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[k] >= SimConst.SNAP_PROJ_BASE:
			break
		var p: Vector2 = Vector2(snap[k + 4], snap[k + 5])
		if int(snap[k + 1]) == SimConst.K_PCAR and p.distance_to(A) <= 15.0 and snap[k + 8] < 0.5:
			cars += 1
		if int(snap[k + 1]) != SimConst.K_COP or int(snap[k + 2]) == SimConst.M_DEAD:
			continue
		cops.append([snapped(p.x, 0.01), snapped(p.y, 0.01)])
		if p.distance_to(A) <= NEAR_M:
			near += 1
	var row: Dictionary = {
		"tick": tick,
		"level": _heat.meter.level,
		"engaged": _city.sim.flow_stats()[SimConst.FS_ENGAGED],
		"near": near,
		"cars_stopped": cars,
		"cops": cops,
	}
	row.merge(HeatClipCount.heat3(_city.sim, _heat.roadblock, snap, A))
	_rows.append(row)
	return row


func _arm() -> String:
	return "living police" if _living else "pre-n18 police"


func _make_label() -> Label:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var l: Label = Label.new()
	l.position = Vector2(16, 12)
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color.BLACK)
	l.add_theme_color_override("font_outline_color", Color.WHITE)
	l.add_theme_constant_override("outline_size", 6)
	layer.add_child(l)
	return l


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		var v: String = arg.substr(flag.length() + 1)
		match flag:
			"--out":
				_out = v
			"--level":
				_level = clampi(v.to_int(), 0, 3)
			"--police":
				_living = v != "pre"
			"--heat-at":
				_heat_at = maxi(1, v.to_int())
			"--seconds":
				_seconds = v.to_float()
			"--every":
				_every = maxi(1, v.to_int())
			"--zoom":
				_zoom = v.to_float()
			"--watch":
				_watch_block = v == "block"
			"--view":
				pass  # ViewMode.shared() reads it
			_:
				printerr("heat_clip: unknown argument %s" % arg)
				return false
	if _out == "":
		printerr("heat_clip: needs --out=<abs dir>")
		return false
	return true
