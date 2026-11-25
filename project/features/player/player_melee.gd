class_name PlayerMelee
extends RefCounted
## Rivet's equipped melee swing in quest 1, the arena and the city block. On a
## hit's first active tick every exposed hostile inside its reach and cone takes its damage and a
## shove along the hit line (knockback_m, eased out over SHOVE_TICKS so it reads as a slide; the
## stage pushes the body back out of buildings). The lunge and the move scale go to the pilot.
## Hosts (views) read `starts`, `hit_index` and `last_land_tick` to pose the rig and the hit-stop.

const WEAPON: StringName = &"claw"
const SHOVE_TICKS: int = 8
## A body's radius is added to a hit's reach (the claw reaches the edge, not the centre).
const EDGE_SLACK_M: float = 0.0

## n7-melee: a landed hit hands CombatArena its line (Rivet -> victim) and contact point, so a kill
## carries the blow's own direction (signature kills cut and throw along it) instead of whatever
## round set it last; `--melee-dir=off` = the before (a stale line).
static var sets_dir: bool = not OS.get_cmdline_user_args().has("--melee-dir=off")

var combo: MeleeCombo
## The weapon id the hits are dealt with (CombatArena.damage; brutality keys kills on it).
var weapon_id: StringName = WEAPON
## Hit starts (a view compares it with the count it last saw to start the strike clip).
var starts: int = 0
var landed: int = 0
var whiffs: int = 0
var last_land_tick: int = -1000000
var last_land_index: int = 0
## Hostile rounds the blade sent back (the plasma sword's deflect).
var deflects: int = 0
## Shoves in flight: fighter id -> the metres still to slide (a vector).
var _contact: MeleeContact = MeleeContact.new()
var _shoves: Dictionary[int, Vector2] = {}
## n31 melee 02: the struck set of the drawn-blade sweep (MeleeSweep.on).
var _sweep: MeleeSweep = MeleeSweep.new()


func _init(table: MeleeTable = MeleeTable.shipped()) -> void:
	combo = MeleeCombo.new(table)
	weapon_id = table.id


## One tick: `press` is this tick's melee press; `facing` is Rivet's heading. Returns the lunge
## displacement (m) for this tick.
func step(arena: CombatArena, press: bool, facing: Vector2) -> Vector2:
	if press:
		combo.press()
	_contact.advance(arena, combo)
	if combo.starts != starts:
		starts = combo.starts
	_slide(arena)
	if MeleeSweep.on and _sweep.track(combo):
		whiffs += 1
	if MeleeSweep.on and not MeleeSweep.held(combo):
		_sweep_tick(arena, facing)
	elif combo.lands():
		_land(arena, combo.current(), facing)
	if combo.table.deflect_m > 0.0 and combo.phase() == MeleeCombo.Phase.ACTIVE:
		deflects += PlayerDeflect.bat(arena, facing, combo.table.deflect_m)
	return facing * combo.lunge_step_m()


## Scale for the walk's top speed while a hit plays.
func move_scale() -> float:
	return combo.move_scale()


func busy() -> bool:
	return combo.hit_index != 0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(combo.hit_index)
	out.put_32(combo.tick_in)
	out.put_8(1 if combo.buffered else 0)
	out.put_32(mini(combo.since_end, 1 << 20))
	out.put_32(combo.last_index)
	out.put_32(landed)
	if combo.table.grinds():  # only a grinding weapon carries it: the claw's goldens hold
		out.put_32(combo.ground)
		_contact.write_bites(out)
	if combo.table.deflect_m > 0.0:
		out.put_32(deflects)
	if MeleeSweep.on:  # off: the goldens hold
		_sweep.write(out)
	var ids: Array = _shoves.keys()
	ids.sort()
	out.put_32(ids.size())
	for id: int in ids:
		out.put_float(_shoves[id].x)
		out.put_float(_shoves[id].y)


func _land(arena: CombatArena, h: MeleeHit, facing: Vector2) -> void:
	var at: Vector2 = arena.rivet.pos
	var hit_any: bool = false
	var conductor: Fighter = null
	for f: Fighter in arena.hostiles:
		var to: Vector2 = f.pos - at
		if not f.alive() or not f.exposed or to.length() > h.reach_m + f.radius_m + EDGE_SLACK_M:
			continue
		var dir: Vector2 = to.normalized() if to.length() > 0.001 else facing
		if dir.dot(facing) < h.cone_dot:
			continue
		conductor = _strike(arena, f, h, dir, conductor)
		hit_any = true
	if conductor != null:
		_arc_from_metal(arena, conductor, h)
	if hit_any:
		landed += 1
		last_land_tick = arena.tick
		last_land_index = combo.hit_index
	else:
		whiffs += 1


## n31 melee 02: one sweep tick. Every exposed hostile the drawn blade crossed since the last tick
## and not yet struck by this hit takes it; `landed` counts the hit once, `whiffs` once when the
## whole sweep struck nothing (its last cutting tick, or MeleeSweep.track when cut short).
func _sweep_tick(arena: CombatArena, facing: Vector2) -> void:
	var h: MeleeHit = combo.current()
	if h == null or not MeleeSweep.cuts(h, combo.tick_in) or _sweep.bitten(h):
		return
	var at: Vector2 = arena.rivet.pos
	var span: Vector2 = MeleeSweep.span(combo, h)
	var conductor: Fighter = null
	var hit_now: bool = false
	for f: Fighter in arena.hostiles:
		if not f.alive() or not f.exposed or _sweep.struck.has(f.id):
			continue
		if not MeleeSweep.crosses(f, at, facing, span, h.reach_m + EDGE_SLACK_M):
			continue
		_sweep.struck[f.id] = true
		var to: Vector2 = f.pos - at
		conductor = _strike(
			arena, f, h, to.normalized() if to.length() > 0.001 else facing, conductor
		)
		hit_now = true
	if conductor != null:
		_arc_from_metal(arena, conductor, h)
	var k: int = _sweep.close(h, combo.tick_in, hit_now)
	landed += 1 if k == 1 else 0
	whiffs += 1 if k == -1 else 0
	if hit_now:
		last_land_tick = arena.tick
		last_land_index = combo.hit_index


## One struck fighter: the blow's line, its contact, its shove; returns the nearest conductor.
func _strike(arena: CombatArena, f: Fighter, h: MeleeHit, dir: Vector2, near: Fighter) -> Fighter:
	if sets_dir:
		arena.hit_dir = dir
		arena.hit_at = f.pos
	var result: MeleeLethal.Contact = MeleeLethal.contact(f, arena.boss, combo, dir, arena.tick)
	var shove: bool = _contact.land(arena, f, combo, dir, result)
	var at: Vector2 = arena.rivet.pos
	if combo.table.single_swing and h.chain_hops > 0 and (f.machine or arena.metal.has(f.pos)):
		if near == null or at.distance_squared_to(f.pos) < at.distance_squared_to(near.pos):
			near = f
	_shoves[f.id] = dir * h.knockback_m if shove else Vector2.ZERO
	return near


## The baton conducts from a struck machine or metal dummy to two nearby conductors.
## A bare prop can bridge the arc. Bodies at its endpoints receive the existing stun.
func _arc_from_metal(arena: CombatArena, first: Fighter, h: MeleeHit) -> void:
	var points: PackedVector2Array = arena.metal.duplicate()
	var bodies: Dictionary[Vector2, Fighter] = {}
	for f: Fighter in arena.hostiles:
		if f == first or (f.alive() and f.exposed and (f.machine or arena.metal.has(f.pos))):
			bodies[f.pos] = f
			if not points.has(f.pos):
				@warning_ignore("return_value_discarded")
				points.append(f.pos)
	var metals: PackedByteArray = PackedByteArray()
	@warning_ignore("return_value_discarded")
	metals.resize(points.size())
	metals.fill(1)
	var path: PackedInt32Array = combo.table.chain_for(h, points, metals, points.find(first.pos))
	var areas: FightAreas = PlayerShock.areas_of(arena)
	for i: int in range(1, path.size()):
		var to: Vector2 = points[path[i]]
		areas.chain_arcs.append(PackedVector2Array([points[path[i - 1]], to]))
		areas.arc_ticks.append(arena.tick)
		if bodies.has(to):
			var ticks: int = h.stun_ticks
			if combo.table.electric and combo.table.never_finish.has(bodies[to].archetype):
				ticks = combo.table.heavy_stun_ticks
			PlayerShock.stun_on(areas, bodies[to], ticks)


## Eases every shove out: each tick slides a share of what is left (by id order: deterministic).
func _slide(arena: CombatArena) -> void:
	if _shoves.is_empty():
		return
	var k: float = 1.0 / float(SHOVE_TICKS) * 2.0
	for f: Fighter in arena.hostiles:
		if not _shoves.has(f.id):
			continue
		var left: Vector2 = _shoves[f.id]
		var d: Vector2 = left * minf(k, 1.0)
		f.pos += d
		left -= d
		if left.length() < 0.01:
			@warning_ignore("return_value_discarded")
			_shoves.erase(f.id)
		else:
			_shoves[f.id] = left
