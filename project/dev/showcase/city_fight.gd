extends Node
## The combat blood in the REAL city (lane d5-combat evidence): the real World + CitySystem +
## CityView + CityCharacters (as city_frame), a riot of 40 rioters and 8 cops on one street, the
## camera parked on it. At each --at tick the clock is frozen (time_scale 0) and the frame is shot
## at every --zooms zoom, so the zooms show the same moment. The blood mode is the game's own
## flag (-- --blood=noir|ink|both). Windowed only. Usage:
##   godot --rendering-driver d3d12 --path project res://dev/showcase/city_fight.tscn --
##   --blood=<mode> --out=<dir> [--at=<tick>,...] [--zooms=1,1.5,2] [--focus=<i>] [--tag=<name>]

const MASTER_SEED: int = 91
const BASE: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const FOCI: Array[Vector2] = [Vector2(30.0, -4.0), Vector2(-4.0, 30.0), Vector2(62.0, 30.0)]

var _out: String = "user://city_fight"
var _at: Array[int] = [600, 1200]
var _zooms: Array[float] = [1.0, 1.5, 2.0]
var _focus: int = 0
var _tag: String = ""
var _world: World = null
var _city: CitySystem = null
var _view: CityView = null
var _chars: CityCharacters = null


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	_city = CitySystem.new(true)
	_world.add_system(_city)
	_city.steer_by_input = false
	var p: Vector2 = BASE + FOCI[_focus]
	_city.focus = p
	_city.target = p
	_city.spawner.riot_c = p
	var t: CityTargets = CityTargets.riot(40, 8)
	_city.spawner.targets = t
	_view = CityView.new()
	add_child(_view)
	_view.setup(_city)
	_chars = CityCharacters.new(_city, _view, _world.context())
	await _chars.bake()
	await _view.prewarm()
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	for tick: int in _at:
		while _world.context().clock.tick() < tick:
			await get_tree().process_frame
		ok = await _shoot(tick) and ok
	printerr(_summary())
	get_tree().quit(0 if ok else 1)


func _shoot(tick: int) -> bool:
	Engine.time_scale = 0.0
	var ok: bool = true
	for zoom: float in _zooms:
		_view.zoom = zoom
		for f: int in 3:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		var ppm: int = roundi(zoom * SimConst.PX_PER_M)
		var file: String = "fight%s-%s-t%d-%dppm.png" % [_tag, _chars.blood.blood.mode, tick, ppm]
		ok = img != null and img.save_png(_out.path_join(file)) == OK and ok
	Engine.time_scale = 1.0
	return ok


func _summary() -> String:
	var b: CombatBlood = _chars.blood.blood
	var f: Dictionary = _view.fx_triggers.fired
	return (
		(
			"city_fight: tick=%d deaths=%d shots=%d kills=%d aimed=%d decals=%d draw_us=%d"
			+ " avg_us_per_frame=%.1f frames=%d"
		)
		% [
			_world.context().clock.tick(),
			f[&"death"],
			f[&"shot"],
			b.kills,
			b.aimed,
			b.blood.live_decals(),
			b.blood.draw_us,
			float(b.spent_us) / maxi(b.frames, 1),
			b.frames
		]
	)


func _parse_args() -> bool:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			_out = arg.substr(6)
		elif arg.begins_with("--at="):
			_at.clear()
			for v: String in arg.substr(5).split(","):
				_at.append(v.to_int())
		elif arg.begins_with("--zooms="):
			_zooms.clear()
			for v: String in arg.substr(8).split(","):
				_zooms.append(v.to_float())
		elif arg.begins_with("--focus="):
			_focus = arg.substr(8).to_int()
		elif arg.begins_with("--tag="):
			_tag = "-" + arg.substr(6)
		elif not arg.begins_with("--blood="):
			printerr("city_fight: unknown argument %s" % arg)
			return false
	return true
