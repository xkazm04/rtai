extends Node
## n9 world item 3 evidence on the REAL city: World + CitySystem + CityView + CityCharacters (as
## bodies_clip.gd builds them), stepped one tick per rendered frame so a frame is a fixed tick.
## A sim car at 12 m/s meets Rivet running across its lane (CarKnockClipDrive): knocked down along
## its heading, the slide, the lie, the rise. --before = bodies.json car_hit off (d9: the car went
## through him); --creep = he stands in the lane (the car brakes and stops at his body). Windowed.
## Usage: godot --rendering-driver d3d12 --path project res://dev/showcase/car_knock_clip.tscn
##     -- --out=<dir> [--before] [--creep] [--zoom=<z>] [--every=<n>] [--view=<id>]

const MASTER_SEED: int = 53
const END_TICK: int = 420
const STILLS: Array[int] = [190, 200, 215, 240, 300]

var _out: String = "user://car_knock_clip"
var _before: bool = false
var _creep: bool = false
var _zoom: float = 2.0
var _every: int = 2
var _world: World = null
var _view: CityView = null
var _drive: CarKnockClipDrive = null


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
	city.spawner.targets = CityTargets.street(20, 0, 0)
	if _before:
		city.body.table.car_hit.x = 0.0
	_drive = CarKnockClipDrive.new(city, _creep)
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
	while ok and _world.context().clock.tick() < END_TICK:
		_world.loop().step()
		await get_tree().process_frame
		ok = await _shoot(_world.context().clock.tick()) and ok
	printerr(
		(
			"car_knock_clip: before=%s creep=%s knocks=%d hit=%d"
			% [_before, _creep, _drive.knocks, _drive.hit_tick]
		)
	)
	get_tree().quit(0 if ok else 1)


func _shoot(tick: int) -> bool:
	var tag: String = (
		"%s%s-%s"
		% ["before" if _before else "after", "-creep" if _creep else "", ViewMode.shared().id]
	)
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
		elif arg.begins_with("--view="):
			pass  # ViewMode.shared() reads it
		elif arg == "--creep":
			_creep = true
		elif arg.begins_with("--zoom="):
			_zoom = arg.substr(7).to_float()
		elif arg.begins_with("--every="):
			_every = arg.substr(8).to_int()
		else:
			printerr("car_knock_clip: unknown argument %s" % arg)
			return false
	return true
