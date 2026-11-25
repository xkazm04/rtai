extends ArenaGame
## n31 melee 04b: stills of the blade hit marks (ClawMarks / BladeMarks, melee_marks.json) on a
## real cop rig in the arena at the game's own zoom (run with --ppm=64, d3d12, windowed). After a
## warm-up one human cop stands NEAR_M in front of Rivet, the others leave; per weapon in
## GTAI_MARKS_WEAPONS (comma list) the view hears CombatArena.wounded(cop, weapon) with the sim
## held, and two crops round the cop are written to GTAI_MARKS_OUT: `marks_<weapon>_64.png` (the
## first drawn frame, age 0) and `marks_<weapon>_64_mid.png` (MID_FRAC of the mark's life later).
## A view-only probe: it emits the signal the hit would, it lands no hit. Dev only.

const WARM: int = 60
const NEAR_M: float = 1.1
const SETTLE: int = 6
const MID_FRAC: float = 0.5
const HALF_PX: int = 200

var _weapons: PackedStringArray = PackedStringArray()
var _out: String = ""
var _cop: Fighter = null
var _wi: int = 0
var _phase: int = 0
var _wait: int = 0
var _snap: String = ""


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	_weapons = OS.get_environment("GTAI_MARKS_WEAPONS").split(",", false)
	_out = OS.get_environment("GTAI_MARKS_OUT")
	@warning_ignore("return_value_discarded")
	RenderingServer.frame_post_draw.connect(_capture)


func _process(_delta: float) -> void:
	if session.tick() < WARM:
		session.step()
		return
	if _cop == null:
		_stand()
		return
	if _snap != "":
		return
	if _wait > 0:
		_wait -= 1
		session.step()
		return
	_next()


## One human cop in front of Rivet; the rest of the room cleared.
func _stand() -> void:
	var arena: CombatArena = session.stage.arena
	for h: Fighter in arena.hostiles:
		if h.alive() and not h.machine and h.kind == Fighter.Kind.GUARD:
			_cop = h
			break
	if _cop == null or _weapons.is_empty() or _out == "":
		_fail("no human cop, GTAI_MARKS_WEAPONS or GTAI_MARKS_OUT")
		return
	arena.hostiles = [_cop]
	arena.rivet.hp = 100000.0
	arena.rivet.facing = Vector2.RIGHT
	_cop.pos = arena.rivet.pos + Vector2.RIGHT * NEAR_M
	_cop.facing = Vector2.LEFT
	_cop.hp = 100000.0
	_wait = SETTLE


func _next() -> void:
	if _wi >= _weapons.size():
		Log.info("marks_still", "done: %d weapons" % _weapons.size())
		set_process(false)
		get_tree().quit(0)
		return
	var w: StringName = StringName(_weapons[_wi])
	var arena: CombatArena = session.stage.arena
	if _phase == 0:
		_cop.pos = arena.rivet.pos + Vector2.RIGHT * NEAR_M
		arena.tick = session.stage.tick
		arena.wounded.emit(_cop, w)
		_snap = "marks_%s_64.png" % w
		_phase = 1
		_wait = maxi(int(_life(w) * MID_FRAC), 1)
		return
	_snap = "marks_%s_64_mid.png" % w
	_phase = 0
	_wi += 1
	_wait = _life(w) + SETTLE


func _life(w: StringName) -> int:
	var t: DataTable = DataTable.open(ClawMarks.TABLE, ClawMarks.SCHEMA)
	return t.integer(t.object(t.raw, String(w)), "flash_ticks")


func _capture() -> void:
	if _snap == "" or _cop == null:
		return
	var held: Node2D = find_children("*", "RivetHeldView", true, false)[0] as Node2D
	var to_screen: Transform2D = (
		held.get_global_transform_with_canvas() * held.get_global_transform().affine_inverse()
	)
	var at: Vector2i = Vector2i(to_screen * (_cop.pos * SimConst.PX_PER_M))
	var im: Image = get_viewport().get_texture().get_image()
	var crop: Rect2i = Rect2i(
		at - Vector2i(HALF_PX, HALF_PX + 60), Vector2i(HALF_PX * 2, HALF_PX * 2)
	)
	crop = crop.intersection(Rect2i(Vector2i.ZERO, im.get_size()))
	var path: String = _out.path_join(_snap)
	@warning_ignore("return_value_discarded")
	DirAccess.make_dir_recursive_absolute(_out)
	var err: Error = im.get_region(crop).save_png(path)
	Log.info("marks_still", "%s tick %d (%s)" % [path, session.stage.tick, error_string(err)])
	_snap = ""


func _fail(why: String) -> void:
	Log.error("marks_still", why)
	set_process(false)
	get_tree().quit(1)
