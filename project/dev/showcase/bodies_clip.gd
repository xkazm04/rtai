extends Node
## features/bodies evidence on the REAL city: World + CitySystem + CityView + CityCharacters (as
## city_frame.gd builds them), stepped one tick per rendered frame so a frame is a fixed tick.
## Rivet walks east (1.4 m/s) through a standing crowd that parts, stops, then sprints (6 m/s)
## into a second group: knockdowns, slides, get-ups, flight. --before = his body off (the game
## before features/bodies: he walks through everyone). Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/bodies_clip.tscn -- --out=<dir>
##   [--before] [--zoom=<z>] [--every=<n>] (clip frame every n ticks, 0 = stills only)

const MASTER_SEED: int = 91
const START: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const END_TICK: int = 1320
const STILLS: Array[int] = [420, 990, 1050, 1250]

var _out: String = "user://bodies_clip"
var _before: bool = false
var _zoom: float = 1.0
var _every: int = 2
var _world: World = null
var _view: CityView = null
var _drive: BodiesClipDrive = null


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	var city: CitySystem = CitySystem.new(true)
	_world.add_system(city)
	city.steer_by_input = false
	city.spawner.targets = CityTargets.street(60, 10, 0)
	_drive = BodiesClipDrive.new(city, START, _before)
	_world.add_system(_drive)
	_view = CityView.new()
	add_child(_view)
	_view.setup(city)
	var characters: CityCharacters = CityCharacters.new(city, _view, _world.context())
	await characters.bake()
	await _view.prewarm()
	_view.zoom = _zoom
	_world.set_process(false)
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	ok = ok and _drive.band.x > 0.0
	while ok and _world.context().clock.tick() < END_TICK:
		_world.loop().step()
		await get_tree().process_frame
		ok = await _shoot(_world.context().clock.tick()) and ok
	printerr("bodies_clip: before=%s knockdowns=%d ok=%s" % [_before, _drive.knocks, ok])
	get_tree().quit(0 if ok else 1)


func _shoot(tick: int) -> bool:
	var tag: String = "before" if _before else "after"
	var ppm: int = roundi(_zoom * SimConst.PX_PER_M)
	var ok: bool = true
	if tick in STILLS:
		ok = await _save("%s-%dppm-t%d.png" % [tag, ppm, tick])
	if _every > 0 and tick % _every == 0:
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		@warning_ignore("integer_division")
		var f: String = "clip-%s-%dppm/%05d.jpg" % [tag, ppm, tick / _every]
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_recursive_absolute(_out.path_join(f.get_base_dir()))
		ok = img != null and img.save_jpg(_out.path_join(f), 0.9) == OK and ok
	return ok


func _save(file: String) -> bool:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	return img != null and img.save_png(_out.path_join(file)) == OK


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg == "--before":
			_before = true
		elif arg.begins_with("--zoom="):
			_zoom = arg.substr(7).to_float()
		elif arg.begins_with("--every="):
			_every = arg.substr(8).to_int()
		else:
			printerr("bodies_clip: unknown argument %s" % arg)
			return false
	return true
