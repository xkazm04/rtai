extends Node
## n9 world item 4 evidence on the REAL city (as car_knock_clip.gd builds it), one tick per
## rendered frame: a pedestrian 1.5 m from a building's face is thrown into it at 16 m/s
## (DeadWallClipDrive). After: the slide stops at the face (world/dead-stop-at-walls-sim). --ref =
## the GDScript twin (bit-exact with native), so a checkout from before the change films the d9
## slide (through the face) with no native rebuild. --tag names the files. Windowed.
## Usage: godot --rendering-driver d3d12 --path project res://dev/showcase/dead_wall_clip.tscn
##     -- --out=<dir> [--ref] [--tag=<s>] [--zoom=<z>] [--every=<n>] [--view=<id>]

const MASTER_SEED: int = 53
const END_TICK: int = 200
const STILLS: Array[int] = [58, 66, 74, 90, 150]

var _out: String = "user://dead_wall_clip"
var _ref: bool = false
var _tag: String = "after"
var _zoom: float = 2.0
var _every: int = 2
var _world: World = null
var _view: CityView = null
var _drive: DeadWallClipDrive = null


func _ready() -> void:
	if not _parse_args():
		get_tree().quit(2)
		return
	_world = World.new()
	_world.start(Events, Data, MASTER_SEED)
	add_child(_world)
	var city: CitySystem = CitySystem.new(not _ref)
	_world.add_system(city)
	city.steer_by_input = false
	city.spawner.targets = CityTargets.street(20, 0, 0)
	_drive = DeadWallClipDrive.new(city)
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
			"dead_wall_clip: ref=%s spot=%s face_x=%.1f rest=%s"
			% [_ref, _drive.spot, _drive.face_x, _drive.rest]
		)
	)
	get_tree().quit(0 if ok else 1)


func _shoot(tick: int) -> bool:
	var tag: String = "%s-%s" % [_tag, ViewMode.shared().id]
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
		elif arg == "--ref":
			_ref = true
		elif arg.begins_with("--tag="):
			_tag = arg.substr(6)
		elif arg.begins_with("--view="):
			pass  # ViewMode.shared() reads it
		elif arg.begins_with("--zoom="):
			_zoom = arg.substr(7).to_float()
		elif arg.begins_with("--every="):
			_every = arg.substr(8).to_int()
		else:
			printerr("dead_wall_clip: unknown argument %s" % arg)
			return false
	return true
