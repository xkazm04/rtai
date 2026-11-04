class_name PlayerShock
extends RefCounted
## Rivet's charged electroshock in the live fight (rivet_melee.json `shock`, MeleeShock's timing).
## The melee press still starts the claw jab on its edge (the combo is untouched); keeping the
## button down after the jab has played charges, and the release discharges: the nearest exposed
## hostile in reach and in front is stunned (stun_min..stun_full with the charge), the arc hops on
## to bodies within chain_radius_m (humans conduct in the fight, as FightAreas' chain), and a full
## charge kills the body it strikes first (full_damage through CombatArena.damage). The stun and
## the arcs live on the arena's FightAreas, so FxView draws them and the brains stand still.

const WEAPON: StringName = &"claw_shock"
## A body's radius is added to the reach (the arc reaches its edge).
const ARC_FROM_M: float = 0.55
## While the charge holds, a short arc jumps off the claws every few ticks (view only), longer as
## the charge fills.
const CRACKLE_EVERY: int = 4
const CLAW_SPREAD_M: float = 0.3

var shock: MeleeShock
var full_damage: float = 1.0
var cone_dot: float = 0.3
var recovery_ticks: int = 18
## Discharges (a view compares it with the count it last saw to play the thrust).
var discharges: int = 0
var landed: int = 0
var kills: int = 0
var last_tick: int = -1000000
var last_charge01: float = 0.0
var _recovery_left: int = 0


static func shipped() -> PlayerShock:
	return from_table(DataTable.open(MeleeTable.TABLE, MeleeTable.SCHEMA))


static func from_table(t: DataTable) -> PlayerShock:
	var p: PlayerShock = PlayerShock.new()
	var row: Dictionary = t.object(t.raw, "shock")
	p.shock = MeleeShock.from_row(t, row)
	p.full_damage = t.num(row, "full_damage")
	p.cone_dot = t.num(row, "cone_dot")
	p.recovery_ticks = t.integer(row, "recovery_ticks")
	return p


## One tick. `down`: the melee button is held; `idle`: no claw hit plays (the charge waits for the
## jab to end). True on the tick a discharge leaves.
func step(arena: CombatArena, down: bool, idle: bool, facing: Vector2) -> bool:
	_recovery_left = maxi(_recovery_left - 1, 0)
	var stun: int = shock.step(down and idle and _recovery_left == 0)
	if stun == 0 and charging01() > 0.0 and arena.tick % CRACKLE_EVERY == 0:
		_crackle(arena, facing)
	if stun <= 0:
		return false
	discharges += 1
	last_tick = arena.tick
	var span: float = maxf(float(shock.stun_full - shock.stun_min), 1.0)
	last_charge01 = clampf(float(stun - shock.stun_min) / span, 0.0, 1.0)
	_recovery_left = recovery_ticks
	_discharge(arena, stun, facing)
	return true


## 0..1 of the charge being held now (the rig's crackle reads it); 0 below the threshold.
func charging01() -> float:
	return shock.charge01() if shock.held and shock.charge >= shock.charge_min else 0.0


func busy() -> bool:
	return _recovery_left > 0 or (shock.held and shock.charge >= shock.charge_min)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(shock.charge)
	out.put_8(1 if shock.held else 0)
	out.put_32(_recovery_left)
	out.put_32(discharges)
	out.put_32(landed)


func _discharge(arena: CombatArena, stun: int, facing: Vector2) -> void:
	var bodies: Array[Fighter] = []
	var pos: PackedVector2Array = PackedVector2Array()
	var first: int = -1
	var best: float = INF
	for f: Fighter in arena.hostiles:
		if not f.alive() or not f.exposed:
			continue
		var to: Vector2 = f.pos - arena.rivet.pos
		var near: bool = to.length() <= shock.reach_m + f.radius_m
		var ahead: bool = to.length() < 0.001 or to.normalized().dot(facing) >= cone_dot
		if near and ahead and to.length() < best:
			best = to.length()
			first = bodies.size()
		bodies.append(f)
		@warning_ignore("return_value_discarded")
		pos.append(f.pos)
	var areas: FightAreas = areas_of(arena)
	var from: Vector2 = arena.rivet.pos + facing * ARC_FROM_M
	if first < 0:  # a whiff: the arc snaps into the air at the reach
		_arc(areas, arena.tick, from, arena.rivet.pos + facing * shock.reach_m)
		return
	landed += 1
	var metal: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	metal.resize(pos.size())
	metal.fill(1)
	var path: PackedInt32Array = shock.chain(pos, metal, first)
	for i: int in path.size():
		var f: Fighter = bodies[path[i]]
		_arc(areas, arena.tick, from, f.pos)
		from = f.pos
		_stun(arena, areas, f, stun, i == 0)


func _stun(arena: CombatArena, areas: FightAreas, f: Fighter, stun: int, first: bool) -> void:
	stun_on(areas, f, stun)
	var dir: Vector2 = (f.pos - arena.rivet.pos).normalized()
	arena.hit_dir = dir
	arena.hit_at = f.pos - dir * f.radius_m
	var lethal: bool = first and stun >= shock.stun_full and full_damage > 0.0
	if lethal:
		arena.damage(f, full_damage, arena.rivet.id, WEAPON)
		kills += 0 if f.alive() else 1
	arena.struck.emit(f, dir, not f.alive(), WEAPON)


## Two arcs, one off each claw (CLAW_SPREAD_M either side of the facing), jumping outward and
## growing with the charge, so the held charge reads at 32 px/m.
func _crackle(arena: CombatArena, facing: Vector2) -> void:
	var beat: int = arena.tick / CRACKLE_EVERY
	var length: float = 0.3 + 0.6 * charging01()
	for side: float in [-1.0, 1.0]:
		var at: Vector2 = arena.rivet.pos + facing * ARC_FROM_M
		at += facing.orthogonal() * side * CLAW_SPREAD_M
		var turn: float = side * (0.5 + 0.35 * float(beat % 3))
		_arc(areas_of(arena), arena.tick, at, at + facing.rotated(turn) * length)


func _arc(areas: FightAreas, tick: int, from: Vector2, to: Vector2) -> void:
	areas.chain_arcs.append(PackedVector2Array([from, to]))
	areas.arc_ticks.append(tick)


## The arena's area model, made here when no table gun has fired yet (quest 1 starts without one).
static func areas_of(arena: CombatArena) -> FightAreas:
	if arena.areas == null:
		arena.areas = FightAreas.new()
		arena.areas.hp_scale = arena.gun.hp_scale() if arena.gun != null else 0.01
	return arena.areas


## Locks `f`'s brain for `ticks` (the FightAreas stun the electro gun uses; FxView draws sparks).
static func stun_on(areas: FightAreas, f: Fighter, ticks: int) -> void:
	if not areas.fx.has(f.id):
		areas.fx[f.id] = FighterFx.new()
	var e: FighterFx = areas.fx[f.id]
	e.stun_ticks = maxi(e.stun_ticks, ticks)
