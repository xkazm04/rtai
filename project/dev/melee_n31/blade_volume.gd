extends ArenaGame
## n31 melee 01a: the real arena and Rivet's live views at 60 Hz, one standing dummy per swing at
## 12 angles x 5 distances (then movers crossing at 1.4 m/s); Rivet swings once facing 0 deg. Each
## frame the DRAWN blade/crescent (BladeProbe) is tested against the dummy's body; hit = a landed
## test. Env: GTAI_BLADE_WEAPON, GTAI_BLADE_OUT (dir), GTAI_BLADE_OVERLAY=<png> (one GPU frame).

const DUMMY: StringName = &"patrol_cop"
const FROM: Vector2 = Vector2(5, -38)
## Ticks before the press (the last swing's linger clears), the last k a trial may run to.
const WAIT: int = 10
const MAX_K: int = 200
## Ticks before the first trial (the wheel's draw settles, as swing_measure's WARM).
const WARM: int = 60

var weapon: StringName = &"hands"
var out_dir: String = ""
var overlay: String = ""
var probe: BladeProbe = null
var trials: BladeTrials = null
var lines: BladeLines = null
var _k: int = -WAIT - 1
var _dummy: Fighter = null
var _origin: Vector2 = Vector2.ZERO
var _land_seen: int = 0
var _landed_seen: int = 0
var _quiet: int = 0


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	weapon = StringName(OS.get_environment("GTAI_BLADE_WEAPON"))
	out_dir = OS.get_environment("GTAI_BLADE_OUT")
	overlay = OS.get_environment("GTAI_BLADE_OVERLAY")
	trials = BladeTrials.new(overlay != "")
	var cap: int = int(OS.get_environment("GTAI_BLADE_CELLS"))
	if cap > 0:
		@warning_ignore("return_value_discarded")
		trials.plan.resize(mini(cap, trials.plan.size()))
	var tap: BladeTap = BladeTap.new()
	tap.on_frame = _sample
	add_child(tap)
	if overlay != "":
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
	if probe == null:
		_first()
	if _k == -WAIT - 1:
		_setup()
	_k += 1
	_pin()
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.RIGHT)
	OpeningFilmPad.button(&"fire", 1.0 if _k == 0 else 0.0)
	var melee: PlayerMelee = session.pilot.melee
	session.step()
	if melee.landed + melee.whiffs != _land_seen:
		if melee.landed + melee.whiffs - _land_seen > 0 and melee.landed > _landed_seen:
			trials.struck(_k)  # the dummy is the only hostile: a landed test hit it
		_land_seen = melee.landed + melee.whiffs
		_landed_seen = melee.landed
		trials.landed(_k)


func _first() -> void:
	probe = BladeProbe.find(self)
	var actual: StringName = MeleeTable.CLAW if weapon == &"hands" else weapon
	if probe.held == null or session.pilot.melee.weapon_id != actual:
		_fail(
			"no held view or wheel did not equip %s (%s)" % [weapon, session.pilot.melee.weapon_id]
		)
	var arena: CombatArena = session.stage.arena
	session.stage.pit.points.clear()
	arena.rivet.hp = 100000.0
	arena.rivet.max_hp = arena.rivet.hp
	@warning_ignore("return_value_discarded")
	arena.struck.connect(_struck)
	if overlay != "":
		lines = BladeLines.new()
		lines.z_index = probe.held.z_index + 5
		probe.held.get_parent().add_child(lines)


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
	arena.rivet.facing = Vector2.RIGHT
	_dummy = arena.squad_ai.spawn_member(arena, _origin + trials.at(-WAIT), DUMMY)
	_dummy.max_hp = 1000000.0
	_dummy.hp = _dummy.max_hp
	_dummy.facing = Vector2.LEFT
	session.stage.pit.standing.append(_dummy)
	_k = -WAIT
	_quiet = 0


## Holds the dummy on its mark (a mover on its path) and its gun cold, every tick.
func _pin() -> void:
	if _dummy == null or not _dummy.alive():
		return
	var mind: SquadMind = session.stage.arena.squad_ai.mind_for(_dummy)
	_dummy.pos = _origin + trials.at(_k)
	_dummy.cooldown = 100
	if mind != null:
		mind.agent.pos = _dummy.pos
		mind.agent.facing = _dummy.facing
		mind.agent.cooldown = 100


func _struck(f: Fighter, _dir: Vector2, _lethal: bool, _weapon: StringName) -> void:
	if f == _dummy:
		trials.struck(_k)


## After the views processed (BladeTap): this frame's drawn geometry against the dummy.
func _sample() -> void:
	if probe == null or probe.held == null or _k < -WAIT or _dummy == null:
		return
	var frame: Dictionary = probe.read()
	var rig: CutRig = probe.held.rigs.rig_for(probe.held.rivet_id)
	var cutting: bool = rig != null and MeleeSwing.cutting(rig.clips.strike_t, rig.clips.strike_ph)
	var crescent: PackedVector2Array = frame["crescent"]
	var busy: bool = session.pilot.melee.busy() or not crescent.is_empty() or probe.smearing()
	if not busy or _k < 0:  # the idle held blade is not a swing
		frame = {"source": "", "blade": PackedVector2Array(), "crescent": crescent}
	var touch: bool = BladeGeom.frame_hits(frame, _dummy.pos, _dummy.radius_m)
	trials.frame(_k, frame, _origin, touch, cutting)
	if lines != null:
		lines.show_frame(probe.read())
	_quiet = 0 if busy else _quiet + 1
	if _k > 4 and (_quiet > 3 or _k >= MAX_K) and overlay == "":
		_next()


func _next() -> void:
	trials.close(_dummy.radius_m)
	if trials.i % 10 == 0 or trials.plan.size() < 10:
		Log.info("blade_volume", "%s trial %d of %d" % [weapon, trials.i, trials.plan.size()])
	if trials.done():
		_finish()
		return
	_k = -WAIT - 1


func _capture() -> void:
	if trials.land_now() < 0 or _k != trials.land_now() + 1 or probe == null:
		return
	var at: Vector2 = probe.held.get_global_transform_with_canvas() * (_origin * SimConst.PX_PER_M)
	var im: Image = get_viewport().get_texture().get_image()
	var crop: Rect2i = Rect2i(Vector2i(at) - Vector2i(260, 220), Vector2i(520, 440))
	crop = crop.intersection(Rect2i(Vector2i.ZERO, im.get_size()))
	if im.get_region(crop).save_png(overlay) != OK:
		_fail("could not save " + overlay)
		return
	Log.info("blade_volume", "overlay %s at k %d" % [overlay, _k])
	get_tree().quit(0)


func _finish() -> void:
	set_process(false)
	var result: Dictionary = trials.result(weapon, session.pilot.melee.combo.table)
	result["lift_m"] = ShotLift.up_m()
	if not BladePlot.write(result, trials.union, out_dir.path_join(String(weapon))):
		_fail("could not write " + out_dir)
		return
	Log.info("blade_volume", "%s %s" % [weapon, result["ring"]])
	get_tree().quit(0)


func _fail(why: String) -> void:
	Log.error("blade_volume", why)
	set_process(false)
	get_tree().quit(1)
