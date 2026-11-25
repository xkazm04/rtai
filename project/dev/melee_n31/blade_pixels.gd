extends ArenaGame
## n31 melee 01c/01d: the DRAWN swing from rendered pixels (arena, --ppm 64, tilt 70, no other body)
## for tools/melee/blade_volume.mjs. Per facing (0, 90, 315) RGB8 crops: `<f>_bg` (Rivet hidden),
## `<f>_idle`, each tick k (0 = press) twice, sim held: `<f>_k<k>` and `_nw` (held view hidden:
## weapon, swipe, smear) + frames.json. Env GTAI_BLADE_WEAPON, GTAI_BLADE_OUT. d3d12, dev only.

const FROM: Vector2 = Vector2(5, -38)
const FACINGS: Array[float] = [0.0, 90.0, 315.0]
const WAIT: int = 12
## The last tick of a swing kept (the chainsaw's strip stays drawn to k 48).
const K_END: int = 56
const WARM: int = 60
## The crop around Rivet's ground point on screen: left/right, up, down (screen px).
const HALF_W: int = 280
const UP: int = 300
const DOWN: int = 270

var weapon: StringName = &"hands"
var out_dir: String = ""
var _fi: int = 0
var _k: int = -WAIT - 1
var _origin: Vector2 = Vector2.ZERO
var _held: RivetHeldView = null
var _meta: Dictionary = {}
var _cut: Array[int] = []
var _land: Array[int] = []
var _seen: int = 0
var _nw_frame: bool = false
var _poses: Dictionary = {}


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	weapon = StringName(OS.get_environment("GTAI_BLADE_WEAPON"))
	out_dir = OS.get_environment("GTAI_BLADE_OUT")
	_meta = {"schema": "gtai.blade-pixels/1", "weapon": weapon, "facings": {}}
	_meta["px_per_m"] = SimConst.PX_PER_M
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_capture)


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	if tick < WARM:
		if tick == 2:
			_arm()
		if tick == 3 and weapon != &"hands":
			OpeningFilmPad.scroll(session.live)
		session.step()
		return
	if _held == null:
		_first()
	_nw_frame = not _nw_frame and _k >= 0 and _k <= K_END
	if _nw_frame:  # the same tick again, held view hidden (no step: the sim and rigs hold)
		return
	if _k == -WAIT - 1:
		_setup()
	_k += 1
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.from_angle(deg_to_rad(FACINGS[_fi])))
	OpeningFilmPad.button(&"fire", 1.0 if _k == 0 else 0.0)
	session.step()
	_record()


func _first() -> void:
	var all: Array[Node] = find_children("*", "RivetHeldView", true, false)
	_held = all[0] as RivetHeldView if not all.is_empty() else null
	var actual: StringName = MeleeTable.CLAW if weapon == &"hands" else weapon
	if _held == null or session.pilot.melee.weapon_id != actual:
		_fail("no held view or wheel did not equip %s" % weapon)
		return
	var arena: CombatArena = session.stage.arena
	session.stage.pit.points.clear()
	arena.rivet.hp = 100000.0
	arena.rivet.max_hp = arena.rivet.hp
	var tap: BladeTap = BladeTap.new()
	tap.on_frame = _late
	add_child(tap)


func _arm() -> void:
	if weapon == &"hands":
		return
	var ids: Array[StringName] = [weapon]
	for hook: ArenaHook in session.stage.hooks:
		if hook is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(hook as ArenaArsenal).arm(ids, false)


func _setup() -> void:
	var arena: CombatArena = session.stage.arena
	arena.hostiles.clear()
	session.stage.pit.standing.clear()
	_origin = session.plan.base + FROM
	arena.rivet.pos = _origin
	arena.rivet.facing = Vector2.from_angle(deg_to_rad(FACINGS[_fi]))
	_k = -WAIT
	_cut = []
	_land = []
	_seen = session.pilot.melee.landed + session.pilot.melee.whiffs
	_poses = {}


## After the views: other rigs hidden (empty arena); Rivet's hidden for the bg frame (k -3) only.
func _late() -> void:
	var mine: CutRig = _held.rigs.rig_for(_held.rivet_id)
	for n: Node in find_children("*", "CutRig", true, false):
		var rig: CutRig = n as CutRig
		rig.visible = rig == mine and _k != -3
	_held.visible = _k != -3 and not _nw_frame


func _record() -> void:
	var melee: PlayerMelee = session.pilot.melee
	var rig: CutRig = _held.rigs.rig_for(_held.rivet_id)
	if _k >= 0 and rig != null:
		var d: Vector2 = session.stage.arena.rivet.pos - _origin
		_poses[str(_k)] = [d.x, d.y, rig.clips.strike_t]
		if MeleeSwing.cutting(rig.clips.strike_t, rig.clips.strike_ph):
			_cut.append(_k)
	if melee.landed + melee.whiffs != _seen:
		_seen = melee.landed + melee.whiffs
		_land.append(_k)


## After the frame drew: the crop of the frame just rendered, named by its role.
func _capture() -> void:
	if _held == null or _k < -WAIT:
		return
	var name: String = _name_of(_k)
	if name == "":
		return
	var facing: String = str(int(FACINGS[_fi]))
	var world_to_screen: Transform2D = (
		_held.get_global_transform_with_canvas() * _held.get_global_transform().affine_inverse()
	)
	var at: Vector2 = world_to_screen * (_origin * SimConst.PX_PER_M)
	var im: Image = get_viewport().get_texture().get_image()
	var crop: Rect2i = Rect2i(Vector2i(at) - Vector2i(HALF_W, UP), Vector2i(HALF_W * 2, UP + DOWN))
	crop = crop.intersection(Rect2i(Vector2i.ZERO, im.get_size()))
	var part: Image = im.get_region(crop)
	part.convert(Image.FORMAT_RGB8)
	_write("%s_%s.rgb" % [facing, name], part.get_data())
	if name == "idle":
		_meta["facings"][facing] = _facing_meta(crop, world_to_screen, at)
	if _k >= K_END and _nw_frame:
		_next(facing)


func _name_of(k: int) -> String:
	if k < 0 or k > K_END:
		return str({-3: "bg", -1: "idle"}.get(k, ""))
	return "k%d_nw" % k if _nw_frame else "k%d" % k


func _facing_meta(crop: Rect2i, t: Transform2D, at: Vector2) -> Dictionary:
	var m: Dictionary = {"crop": [crop.position.x, crop.position.y, crop.size.x, crop.size.y]}
	m["world_to_screen"] = [t.x.x, t.x.y, t.y.x, t.y.y, t.origin.x, t.origin.y]
	m["origin_m"] = [_origin.x, _origin.y]
	m["rivet_screen"] = [at.x, at.y]
	m["lift_m"] = [ShotLift.up_m().x, ShotLift.up_m().y]
	m["pitch_deg"] = ViewMode.shared().pitch_deg
	return m


func _next(facing: String) -> void:
	var m: Dictionary = _meta["facings"][facing]
	m["cut_ks"] = _cut.duplicate()
	m["land_ks"] = _land.duplicate()
	m["k_end"] = K_END
	m["poses"] = _poses.duplicate()
	Log.info("blade_pixels", "%s facing %s cut %s land %s" % [weapon, facing, _cut, _land])
	_fi += 1
	_k = -WAIT - 1
	if _fi < FACINGS.size():
		return
	set_process(false)
	_write("frames.json", JSON.stringify(_meta, "\t").to_utf8_buffer())
	get_tree().quit(0)


func _write(file: String, bytes: PackedByteArray) -> void:
	var f: FileAccess = FileAccess.open(out_dir.path_join(file), FileAccess.WRITE)
	if f == null:
		_fail("could not write " + file)
		return
	@warning_ignore("return_value_discarded")
	f.store_buffer(bytes)
	f.close()


func _fail(why: String) -> void:
	Log.error("blade_pixels", why)
	set_process(false)
	get_tree().quit(1)
