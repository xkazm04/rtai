extends ArenaGame
## n31 melee 04b: stills of the blade hit marks (ClawMarks / BladeMarks, melee_marks.json) on a
## real cop rig in the arena at the game's own zoom (run with --ppm=64, d3d12, windowed). After a
## warm-up one human cop stands NEAR_M in front of Rivet, the others leave; per weapon in
## GTAI_MARKS_WEAPONS (comma list) the view hears CombatArena.wounded(cop, weapon) with the sim
## held, and two crops round the cop are written to GTAI_MARKS_OUT: `marks_<weapon>_64.png` (the
## first drawn frame, age 0) and `marks_<weapon>_64_mid.png` (MID_FRAC of the mark's life later).
## A view-only probe: it emits the signal the hit would, it lands no hit. Dev only.
## n31 04d: GTAI_MARKS_VICTIM picks the victim: `cop` (default, a human guard), `robot` (a robot
## thug: the sparks and oil of a non-lethal hit), `riot` (a riot cop: the slab's sparks); the file
## names carry the zoom (`--ppm`) and the victim; a chainsaw re-emits the hit each tick (the grind).
## n31 04e: a gun id in GTAI_MARKS_WEAPONS (run with `--weapon=<the same gun>`) stops one of its
## rounds on the victim instead (GunFx's body impact + GunFxWound's flick, as GunFxRounds would);
## its mid still is GUN_MID ticks on, when the flick's drops have landed.

const WARM: int = 60
const NEAR_M: float = 1.1
const SETTLE: int = 6
const MID_FRAC: float = 0.5
const HALF_PX: int = 200
const GUN_MID: int = 16

var _weapons: PackedStringArray = PackedStringArray()
var _out: String = ""
var _cop: Fighter = null
var _wi: int = 0
var _phase: int = 0
var _wait: int = 0
var _snap: String = ""
var _victim: String = "cop"
## A gun's stop (m): the crops centre on it (the sim walks the guard back to his post).
var _at: Vector2 = Vector2.INF


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	_weapons = OS.get_environment("GTAI_MARKS_WEAPONS").split(",", false)
	_out = OS.get_environment("GTAI_MARKS_OUT")
	_victim = OS.get_environment("GTAI_MARKS_VICTIM")
	_victim = "cop" if _victim == "" else _victim
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
		if _phase == 1 and _weapons[_wi] == "chainsaw":
			session.stage.arena.wounded.emit(_cop, &"chainsaw")
		return
	_next()


## One human cop in front of Rivet; the rest of the room cleared.
func _stand() -> void:
	var arena: CombatArena = session.stage.arena
	var squad: ArenaSquad = arena.squad_ai
	if _victim == "robot" and squad != null:  # the pit's first waves are human: enrol a thug
		_cop = squad.spawn_member(arena, arena.rivet.pos + Vector2.RIGHT * NEAR_M, &"robot_thug")
	for h: Fighter in arena.hostiles:
		if _cop == null and h.alive() and _wanted(h):
			_cop = h
			break
	if _cop == null or _weapons.is_empty() or _out == "":
		_fail("no %s, GTAI_MARKS_WEAPONS or GTAI_MARKS_OUT" % _victim)
		return
	arena.hostiles = [_cop]
	if _victim == "riot":
		_cop.archetype = &"riot_cop"
	arena.rivet.hp = 100000.0
	arena.rivet.facing = Vector2.RIGHT
	_cop.pos = arena.rivet.pos + Vector2.RIGHT * NEAR_M
	_cop.facing = Vector2.LEFT
	_cop.hp = 100000.0
	_wait = SETTLE


func _wanted(h: Fighter) -> bool:
	match _victim:
		"robot":
			return h.machine
		"riot":  # --riot dresses the wave's first guard; the arena leaves its archetype unset
			return h.archetype == &"riot_cop" or (h.archetype == &"" and not h.machine)
	return not h.machine and h.kind == Fighter.Kind.GUARD


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
		_cop.facing = Vector2.LEFT  # the shield's front toward Rivet again (the sim turned him)
		arena.tick = session.stage.tick
		if w in MeleeWound.MELEE_IDS:
			arena.wounded.emit(_cop, w)
		else:
			_shoot(w)
		_snap = "marks_%s_%s_%d.png" % [w, _victim, roundi(px_per_m)]
		_phase = 1
		_wait = maxi(int(_life(w) * MID_FRAC), 1)
		return
	_snap = "marks_%s_%s_%d_mid.png" % [w, _victim, roundi(px_per_m)]
	_phase = 0
	_wi += 1
	_wait = _life(w) + SETTLE


## One round of gun `w` stopped on the victim's near side, travelling from Rivet (the carry put
## the gun away for the claw: the probe hands it back, as GunplayHook arms it).
func _shoot(w: StringName) -> void:
	var arena: CombatArena = session.stage.arena
	if arena.gun == null or arena.gun.trigger.spec.id != w:
		var rng: RandomNumberGenerator = session.world.context().rng.stream(&"gunplay")
		arena.gun = GunHand.make(WeaponTable.shipped(), w, rng)
	var fx: GunFx = (find_children("*", "FxView", true, false)[0] as FxView).gun_fx()
	var hop: Vector2 = (_cop.pos - arena.rivet.pos).normalized() * 0.5
	var at: Vector2 = _cop.pos - hop.normalized() * _cop.radius_m * 0.5
	fx.impacts.append(Vector4(at.x, at.y, float(GunFx.Hit.BODY), float(session.stage.tick + 1)))
	@warning_ignore("return_value_discarded")
	fx.impact_dir.append(hop.normalized())
	var thrown: int = GunFxWound.on_round(fx, arena, _cop, at, hop)
	Log.info("marks_still", "gun %s flick %d" % [arena.gun.trigger.spec.id, thrown])
	session.step()  # the view draws the stop on its next tick: the hit frame is age 0
	_at = at


func _life(w: StringName) -> int:
	if not (w in MeleeWound.MELEE_IDS):
		return GUN_MID * 2
	var t: DataTable = DataTable.open(ClawMarks.TABLE, ClawMarks.SCHEMA)
	return t.integer(t.object(t.raw, String(w)), "flash_ticks")


func _capture() -> void:
	if _snap == "" or _cop == null:
		return
	var held: Node2D = find_children("*", "RivetHeldView", true, false)[0] as Node2D
	var to_screen: Transform2D = (
		held.get_global_transform_with_canvas() * held.get_global_transform().affine_inverse()
	)
	var mid: Vector2 = _cop.pos if _at == Vector2.INF else _at
	var at: Vector2i = Vector2i(to_screen * (mid * SimConst.PX_PER_M))
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
