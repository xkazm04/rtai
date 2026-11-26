extends ArenaGame
## n31 melee 02p4: the hit volume LIVE, for a slow clip. The real arena at --ppm (64), Rivet facing
## 0 deg with one melee weapon (--blade=hands|chainsaw|electro_baton|katana|plasma_sword), a ring of
## standing dummies (blade_volume's dummy, pinned, gun cold, unkillable) and the same first swing
## repeated --swings times. SweepClipLines draws the sector the hit tests on each tick and flashes
## each struck dummy once. With --melee-sweep the sweep's sector, with --melee-sweep=off the table
## cone on the contact tick. Quits after the last swing. tools/melee/sweep_clip.mjs films it.

const KNOWN_FLAGS: PackedStringArray = [
	"--blade", "--swings", "--melee-sweep", "--ppm", "--cam-lock", "--clean", "--silent"
]
const DUMMY: StringName = &"patrol_cop"
const FROM: Vector2 = Vector2(-24, 26)
const RINGS: Array[Vector3] = [Vector3(8, 1.8, 0.0)]
const FAR_DEG: Array[float] = [-60.0, -20.0, 20.0, 60.0]
const WARM: int = 60
## Idle ticks past the combo window before the next press (the combo restarts at hit 1).
const GAP: int = 8
const TAIL: int = 20

var blade: StringName = &"katana"
var swings: int = 4
var lines: SweepClipLines = null
var _dummies: Array[Fighter] = []
var _offsets: Array[Vector2] = []
var _origin: Vector2 = Vector2.ZERO
var _pressed: int = 0
var _idle: int = 0


func _ready() -> void:
	super()
	process_priority = -1000
	session.world.set_process(false)
	session.live.viewport = null
	var args: ArenaArgs = ArenaArgs.parse()
	blade = StringName(args.text("--blade", "katana"))
	swings = int(args.number("--swings", 4.0))
	Log.info("sweep_clip", "%s x%d sweep %s" % [blade, swings, MeleeSweep.on])


func _process(_delta: float) -> void:
	var tick: int = session.tick()
	if tick < WARM:
		if tick == 2:
			_arm()
		if tick == 3 and blade != &"hands":
			OpeningFilmPad.scroll(session.live)
		session.step()
		return
	if lines == null:
		_setup()
	_pin()
	var melee: PlayerMelee = session.pilot.melee
	var press: bool = _wants_press(melee)
	OpeningFilmPad.sticks(Vector2.ZERO, Vector2.RIGHT)
	OpeningFilmPad.button(&"fire", 1.0 if press else 0.0)
	session.step()
	lines.show_tick(_tested(melee))
	if _pressed >= swings and not melee.busy() and _idle > TAIL:
		Log.info("sweep_clip", "%s done: %d swings, landed %d" % [blade, _pressed, melee.landed])
		get_tree().quit(0)


func _wants_press(melee: PlayerMelee) -> bool:
	if melee.busy():
		_idle = 0
		return false
	_idle += 1
	var wait: int = melee.combo.table.combo_window_ticks + GAP
	if _pressed >= swings or (_pressed > 0 and _idle <= wait):
		return false
	_pressed += 1
	_idle = 0
	return true


## The sector this tick's hit test used ({} when none): MeleeSweep's crossed sector while the
## sweep cuts, else the table cone on a landing tick (the flag off, or a held grind's re-test).
func _tested(melee: PlayerMelee) -> Dictionary:
	var combo: MeleeCombo = melee.combo
	var h: MeleeHit = combo.current()
	if h == null:
		return {}
	var rivet: Fighter = session.stage.arena.rivet
	var at: Vector2 = rivet.pos - rivet.facing * combo.lunge_step_m()
	var out: Dictionary = {"at": at, "aim": rivet.facing.angle(), "reach": h.reach_m}
	if MeleeSweep.on and not MeleeSweep.held(combo):
		if not MeleeSweep.cuts(h, combo.tick_in) or melee._sweep.bitten(h):
			return {}
		out["arc"] = MeleeSweep.span(combo, h)
		return out
	if not combo.lands():
		return {}
	var half: float = acos(clampf(h.cone_dot, -1.0, 1.0))
	out["arc"] = Vector2(-half, half)
	return out


func _arm() -> void:
	if blade == &"hands":
		return
	var ids: Array[StringName] = [blade]
	for hook: ArenaHook in session.stage.hooks:
		if hook is ArenaArsenal:
			@warning_ignore("return_value_discarded")
			(hook as ArenaArsenal).arm(ids, false)


func _setup() -> void:
	var arena: CombatArena = session.stage.arena
	arena.hostiles.clear()
	session.stage.pit.standing.clear()
	session.stage.pit.points.clear()
	arena.rivet.hp = 100000.0
	arena.rivet.max_hp = arena.rivet.hp
	_origin = session.plan.base + FROM
	arena.rivet.pos = _origin
	arena.rivet.facing = Vector2.RIGHT
	for ring: Vector3 in RINGS:
		for i: int in int(ring.x):
			var deg: float = ring.z + i * 360.0 / ring.x
			_offsets.append(Vector2.from_angle(deg_to_rad(deg)) * ring.y)
	for deg: float in FAR_DEG:
		_offsets.append(Vector2.from_angle(deg_to_rad(deg)) * 2.8)
	for off: Vector2 in _offsets:
		var d: Fighter = arena.squad_ai.spawn_member(arena, _origin + off, DUMMY)
		d.max_hp = 1000000.0
		d.hp = d.max_hp
		d.facing = -off.normalized()
		session.stage.pit.standing.append(d)
		_dummies.append(d)
	@warning_ignore("return_value_discarded")
	arena.struck.connect(_struck)
	var probe: BladeProbe = BladeProbe.find(self)
	lines = SweepClipLines.new()
	lines.z_index = probe.held.z_index + 5
	probe.held.get_parent().add_child(lines)


## Holds every dummy on its mark, full, its gun cold, every tick.
func _pin() -> void:
	var arena: CombatArena = session.stage.arena
	for i: int in _dummies.size():
		var d: Fighter = _dummies[i]
		d.pos = _origin + _offsets[i]
		d.hp = d.max_hp
		d.cooldown = 100
		var mind: SquadMind = arena.squad_ai.mind_for(d)
		if mind != null:
			mind.agent.pos = d.pos
			mind.agent.facing = d.facing
			mind.agent.cooldown = 100


func _struck(f: Fighter, _dir: Vector2, _lethal: bool, _weapon: StringName) -> void:
	if f in _dummies:
		lines.flash(f.pos, f.radius_m)
