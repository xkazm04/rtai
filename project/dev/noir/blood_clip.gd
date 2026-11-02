extends Node
## D-Noir fight clip (lane noir): the real city at the junction in the noir look, in rain, and a
## scripted beat through the REAL combat events (Events.actor_killed / player_hit): Rivet kills
## two cops, takes a hit, the blood pools. NoirCombatFx answers with blood, impact frames and
## hit-stop (the world is held for hit_stop_ticks). The cops are fixed points, not combat AI:
## the city scene has no CombatArena. Record with the movie maker for a fixed 60 fps:
##   godot --path project --resolution 1280x720 --write-movie <f.avi> --fixed-fps 60
##     res://dev/noir/blood_clip.tscn -- --out=<dir> [--zoom=1.5]

const KNOWN_FLAGS: PackedStringArray = ["--out", "--zoom"]
const RIVET: int = 1
const COPS: Dictionary[int, Vector2] = {101: Vector2(3.2, -1.6), 102: Vector2(-2.6, 2.4)}
## tick -> [event, id]; the clip ends at END.
const BEATS: Dictionary[int, Array] = {
	50: ["kill", 101], 140: ["hit", 0], 175: ["kill", 102], 260: ["hit", 0]
}
const HEROES: PackedInt32Array = [50, 51, 60, 176, 300, 600]
const END: int = 620

var _out: String = "user://noir"
var _zoom: float = 1.5
var _frame: int = 0
var _hold: int = 0
var _live: bool = false
var _focus: Vector2 = NoirFrames.JUNCTION
var _world: World = null
var _view: CityView = null
var _blood: BloodFx = BloodFx.new()
var _impact: ImpactFrame = ImpactFrame.new()
var _fx: NoirCombatFx = NoirCombatFx.new()


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		var flag: String = arg.get_slice("=", 0)
		if not KNOWN_FLAGS.has(flag):
			get_tree().quit(2)
			return
		var v: String = arg.substr(flag.length() + 1)
		if flag == "--out":
			_out = v
		else:
			_zoom = v.to_float()
	var made: bool = DirAccess.make_dir_recursive_absolute(_out) == OK
	if not made:
		printerr("blood_clip: cannot create %s" % _out)
	var built: Array = NoirFrames.build_city(self)
	_world = built[0]
	_view = built[1]
	_view.zoom = _zoom
	_view.add_child(_blood)
	add_child(_impact)
	add_child(_fx)
	_fx.player_id = RIVET
	_fx.locate = _locate
	_fx.to_screen_uv = _to_uv
	_fx.bind(Events, _blood, _impact)
	@warning_ignore("return_value_discarded")
	_fx.hit_stop.connect(func(t: int) -> void: _hold = t)
	var chars: CityCharacters = built[3]
	await chars.bake()
	await _view.prewarm()
	_live = true


func _process(_delta: float) -> void:
	if not _live:
		return
	_frame += 1
	_world.process_mode = Node.PROCESS_MODE_DISABLED if _hold > 0 else Node.PROCESS_MODE_INHERIT
	_hold = maxi(_hold - 1, 0)
	_view.noir.fixed_phase = float(_frame)
	_impact.step_ticks(1)
	var beat: Array = BEATS.get(_frame, [])
	if not beat.is_empty():
		var id: int = beat[1]
		if beat[0] == "kill":
			Events.actor_killed.emit(RIVET, id, &"shot")
		else:
			Events.player_hit.emit(&"baton")
	_blood.step_ticks(1)
	if HEROES.has(_frame):
		_save.call_deferred(_frame)
	if _frame >= END:
		printerr(
			"blood_clip: kills %d hits %d decals %d" % [_fx.kills, _fx.hits, _blood.live_decals()]
		)
		get_tree().quit(0)


func _save(f: int) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = get_viewport().get_texture().get_image()
	var ppm: int = roundi(_zoom * SimConst.PX_PER_M)
	var ok: bool = img.save_png(_out.path_join("fight-%dppm-f%03d.png" % [ppm, f])) == OK
	if not ok:
		printerr("blood_clip: frame %d not saved" % f)


func _locate(id: int) -> Vector2:
	if id == RIVET:
		return _focus
	if COPS.has(id):
		return _focus + COPS[id]
	return Vector2.INF


func _to_uv(px: Vector2) -> Vector2:
	var cam: Vector2 = _view.camera.position
	var view: Vector2 = get_viewport().get_visible_rect().size
	return ((px - cam) * _zoom + view * 0.5) / view
