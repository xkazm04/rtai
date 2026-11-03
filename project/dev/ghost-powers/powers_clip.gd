extends Node
## features/souls evidence on the REAL city (World + CitySystem + CityView + CityCharacters, as
## bodies_clip.gd builds them), one tick per rendered frame so a frame is a fixed tick. Rivet
## turns into the Hauler ghost tank, drives through a standing crowd (the rivet_ghost class knocks
## them down at 4.2 m/s, under base Rivet's 5.0 tackle line), coasts on momentum, telegraphs a
## stomp and floors a group. --before = base Rivet on the same path and speed. Windowed only:
##   godot --rendering-driver d3d12 --path project res://dev/ghost-powers/powers_clip.tscn
##     -- --out=<dir> [--before] [--zoom=<z>] [--every=<n>] (clip frame every n ticks)
##     [--look=<scaled|bulked>] (overrides powers.json hauler.look) [--cops] (3 cops in the group)

const MASTER_SEED: int = 91
const START: Vector2 = Vector2(64.0 * 8 + 12.0, 64.0 * 8 + 12.0)
const END_TICK: int = 720
const STILLS: Array[int] = [50, 90, 250, 430, 440, 520, 690]

## Hit-stop frames the stomp held (evidence).
var hitstop_frames: int = 0
var _out: String = "user://powers_clip"
var _before: bool = false
var _zoom: float = 1.0
var _every: int = 2
var _world: World = null
var _view: CityView = null
var _drive: PowersClipDrive = null
var _ring: PowersRing = null
## --look=<scaled|bulked> overrides powers.json hauler.look (ASK ghost-powers-2 A/B frames).
var _look: StringName = &""
var _cops: bool = false
## The sound hook as it fired (the clip is silent): "id@tick".
var _cues: PackedStringArray = PackedStringArray()
## Rendered frames (a hit-stop renders frames without a tick) and frames still held.
var _frame: int = 0
var _held: int = 0
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
	_drive.cops = _cops
	@warning_ignore("return_value_discarded")
	_drive.hauler.cued.connect(_on_cue)
	_world.add_system(_drive)
	_view = CityView.new()
	add_child(_view)
	_view.setup(city)
	_characters = CityCharacters.new(city, _view, _world.context())
	await _characters.bake()
	_add_ring()
	await _view.prewarm()
	_view.rig = CameraRig.new()
	_view.rig.snap(&"car" if _zoom > 1.2 else &"on_foot")
	_world.set_process(false)
	var ok: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	ok = ok and _drive.band.x > 0.0
	while ok and _world.context().clock.tick() < END_TICK:
		if _held > 0:
			_held -= 1
		else:
			_world.loop().step()
			_feel(_world.context().clock.tick())
		_ring.sync(_world.context().clock.tick(), _characters.rigs.rig_for(CityCharacters.RIVET_ID))
		await get_tree().process_frame
		ok = await _shoot(_world.context().clock.tick()) and ok
		_frame += 1
	ok = _numbers() and ok
	get_tree().quit(0 if ok else 1)


func _on_cue(id: StringName, _at: Vector2, tick: int) -> void:
	@warning_ignore("return_value_discarded")
	_cues.append("%s@%d" % [id, tick])


func _add_ring() -> void:
	_ring = PowersRing.new()
	_ring.hauler = _drive.hauler
	_ring.look = HaulerLook.new(PowerTable.load_default().hauler)
	if _look != &"":
		_ring.look.look = _look
	_ring.z_index = RenderLayers.z(&"actors") + 1
	_view.actor_layer().add_child(_ring)


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
		"stomp_hitstop_frames": hitstop_frames,
		"cues": _cues,
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
	var tag: String = "before" if _before else "after"
	tag += "-cops" if _cops else ""
	return tag if _look == &"" else "%s-%s" % [tag, _look]


## The stomp's landing feel, the step after the pulse knocked the ring down: the camera shake
## and a hit-stop of whole rendered frames with the sim held (powers.json stomp_shake/hitstop).
func _feel(tick: int) -> void:
	var st: int = _drive.hauler.stomp_tick
	if st < 0 or tick != st + 2:
		return
	var h: Dictionary = PowerTable.load_default().hauler
	_view.rig.kick(StringName(str(h["stomp_shake"])), tick)
	_held = _view.rig.hitstop(StringName(str(h["stomp_hitstop"])), tick)
	hitstop_frames = _held


func _shoot(tick: int) -> bool:
	var tag: String = _tag()
	var ppm: int = roundi(_zoom * SimConst.PX_PER_M)
	var ok: bool = true
	if tick in STILLS:
		ok = await _save("%s-%dppm-t%d.png" % [tag, ppm, tick])
	if _every > 0 and _frame % _every == 0:
		await RenderingServer.frame_post_draw
		var img: Image = get_viewport().get_texture().get_image()
		@warning_ignore("integer_division")
		var f: String = "clip-%s-%dppm/%05d.jpg" % [tag, ppm, _frame / _every]
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
		elif arg == "--cops":
			_cops = true
		elif arg.begins_with("--look="):
			_look = StringName(arg.substr(7))
		elif arg.begins_with("--every="):
			_every = arg.substr(8).to_int()
		else:
			printerr("powers_clip: unknown argument %s" % arg)
			return false
	return true
