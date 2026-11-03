extends Node
## REAL-GAME cop close-up (d5-cast item 2): the same World + CitySystem + CityView + crowd as
## city_frame (seed 91, a riot at its first focus), settled at 32 px/m, then the camera follows the
## nearest live cop to the riot centre and shoots it at each zoom. The riot centre and the police
## target stay put, so only the bubble centre (the camera) moves. Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/cop_close.tscn -- --out=<dir>
##   [--police=<n>] [--settle=<frames>] [--zooms=<z>,...]  (12, 120, 2,4: 64 and 128 px/m)

const MASTER_SEED: int = 91
const RIOT: Vector2 = Vector2(64.0 * 8 + 42.0, 64.0 * 8 + 8.0)
const FOLLOW_FRAMES: int = 30

var _out: String = "user://cop_close"
var _city: CitySystem = null
var _view: CityView = null
var _police: int = 12
var _settle: int = 120
var _zooms: Array[float] = [2.0, 4.0]


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	var world: World = World.new()
	world.start(Events, Data, MASTER_SEED)
	add_child(world)
	_city = CitySystem.new(true)
	world.add_system(_city)
	_city.steer_by_input = false
	_city.focus = RIOT
	_city.target = RIOT
	_city.spawner.riot_c = RIOT
	var t: CityTargets = CityTargets.riot(40, _police)
	t.cars = 24
	t.police_cars = 2
	_city.spawner.targets = t
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	var characters: CityCharacters = CityCharacters.new(_city, _view, world.context())
	await characters.bake()
	await _view.prewarm()
	for f: int in _settle:
		await get_tree().process_frame
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	for zoom: float in _zooms:
		ok = await _shoot(zoom) and ok
	get_tree().quit(0 if ok else 1)


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--police="):
			_police = arg.substr(9).to_int()
		elif arg.begins_with("--settle="):
			_settle = arg.substr(9).to_int()
		elif arg.begins_with("--zooms="):
			_zooms.clear()
			for v: String in arg.substr(8).split(","):
				_zooms.append(v.to_float())
		else:
			printerr("cop_close: unknown argument %s" % arg)
			return false
	return true


## Follows the nearest live cop for FOLLOW_FRAMES at `zoom`, then saves the frame.
func _shoot(zoom: float) -> bool:
	_view.zoom = zoom
	var slot: int = _nearest_cop(RIOT, -1)
	if slot < 0:
		printerr("cop_close: no live cop near the riot")
		return false
	for f: int in FOLLOW_FRAMES:
		slot = _nearest_cop(_city.focus, slot)
		_city.focus = _cop_pos(slot, _city.focus)
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var file: String = "cop-%dppm.png" % roundi(zoom * SimConst.PX_PER_M)
	printerr("cop_close: %s cop slot %d at %s" % [file, slot, _city.focus])
	return img != null and img.save_png(_out.path_join(file)) == OK


## The live cop slot nearest to `p`; keeps `prefer` while it is alive.
func _nearest_cop(p: Vector2, prefer: int) -> int:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	var best: int = -1
	var best_d2: float = INF
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] >= SimConst.SNAP_PROJ_BASE:
			break
		if int(snap[r + 1]) != SimConst.K_COP or int(snap[r + 2]) == SimConst.M_DEAD:
			continue
		if int(snap[r]) == prefer:
			return prefer
		var d2: float = Vector2(snap[r + 4], snap[r + 5]).distance_squared_to(p)
		if d2 < best_d2:
			best_d2 = d2
			best = int(snap[r])
	return best


func _cop_pos(slot: int, fallback: Vector2) -> Vector2:
	var snap: PackedFloat64Array = _city.sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if int(snap[r]) == slot:
			return Vector2(snap[r + 4], snap[r + 5])
	return fallback
