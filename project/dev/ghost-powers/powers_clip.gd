extends Node
## features/souls evidence on the REAL city (World + CitySystem + CityView + CityCharacters, as
## bodies_clip.gd builds them), one tick per rendered frame so a frame is a fixed tick. Rivet
## turns into the Hauler ghost tank, drives through a standing crowd (the rivet_ghost class knocks
## them down at 4.2 m/s, under base Rivet's 5.0 tackle line), coasts on momentum, telegraphs a
## stomp and floors a group. --before = base Rivet on the same path and speed. Windowed only:
##   godot --rendering-driver d3d12 --path project res://dev/ghost-powers/powers_clip.tscn
##     -- --out=<dir> [--before] [--zoom=<z>] [--every=<n>] (clip frame every n ticks)

const MASTER_SEED: int = 91
const START: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const END_TICK: int = 720
const STILLS: Array[int] = [50, 90, 250, 430, 440, 520, 690]

var _out: String = "user://powers_clip"
var _before: bool = false
var _zoom: float = 1.0
var _every: int = 2
var _world: World = null
var _view: CityView = null
var _drive: PowersClipDrive = null
var _ring: PowersRing = null
var _characters: CityCharacters = null


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
	_drive = PowersClipDrive.new(city, START, _before)
	_world.add_system(_drive)
	_view = CityView.new()
	add_child(_view)
	_view.setup(city)
	_characters = CityCharacters.new(city, _view, _world.context())
	await _characters.bake()
	_ring = PowersRing.new()
	_ring.hauler = _drive.hauler
	_ring.z_index = RenderLayers.z(&"actors") + 1
	_view.actor_layer().add_child(_ring)
	await _view.prewarm()
	_view.zoom = _zoom
	_world.set_process(false)
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	ok = ok and _drive.band.x > 0.0
	while ok and _world.context().clock.tick() < END_TICK:
		_world.loop().step()
		_ring.sync(_world.context().clock.tick(), _characters.rigs.rig_for(CityCharacters.RIVET_ID))
		await get_tree().process_frame
		ok = await _shoot(_world.context().clock.tick()) and ok
	ok = _numbers() and ok
	get_tree().quit(0 if ok else 1)


func _numbers() -> bool:
	var h: HaulerCity = _drive.hauler
	var r: Dictionary = {
		"before": _before,
		"knocks_transformed": h.knocks,
		"stomp_knocks": h.stomp_knocks,
		"base_knocks": _drive.base_knocks,
		"time_transformed_s": h.ticks_on * SimClock.TICK_DT,
		"activations": _drive.powers.uses.get(&"hauler", 0),
		"stomps": h.form.stomps,
	}
	printerr("powers_clip: %s" % r)
	var f: FileAccess = FileAccess.open(
		_out.path_join("numbers-%s.json" % _tag()), FileAccess.WRITE
	)
	if f == null:
		return false
	@warning_ignore("return_value_discarded")
	f.store_string(JSON.stringify(r, "  ", true))
	return true


func _tag() -> String:
	return "before" if _before else "after"


func _shoot(tick: int) -> bool:
	var tag: String = _tag()
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
			printerr("powers_clip: unknown argument %s" % arg)
			return false
	return true
