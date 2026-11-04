class_name FightAreas
extends RefCounted
## The weapon table's area behaviours in the real fight (CombatArena): splash with falloff and
## knockdown, the electro chain and stun, burning (panic + damage over time) and fire on the
## ground. The same rules as the range model (Impact, ProjectileSim) applied to Fighters, so the
## arena, the city block and the quest share one model. Every hp change goes through
## CombatArena.damage(). Deterministic: ticks, no RNG. Lane gunplay.

## Knockback at or above this speed knocks a human down (rocket blasts).
const KNOCKDOWN_MPS: float = 4.0
const DOWN_TICKS: int = 54
## Standing in a fire patch re-lights a fighter for this long.
const PATCH_IGNITE_TICKS: int = 30
## Burning humans run at walk speed x this, weaving off the line away from the fire.
const PANIC_SPEED_X: float = 1.7
const PANIC_WEAVE_RAD: float = 0.7
## DECISION 2026-11-04: in the fight the bolt jumps body to body (humans conduct) and metal props
## bridge it; false = the range model's metal-only chain.
const CHAIN_THROUGH_HUMANS: bool = true
const CHAIN_FALLOFF: float = 0.7
## Views see blasts and chain arcs for this long (VFX only; not in the replay state).
const VFX_KEEP_TICKS: int = 40

## Table hp points -> Fighter hp (a human is 1; GunHand.hp_scale).
var hp_scale: float = 0.01
var fx: Dictionary[int, FighterFx] = {}
## Fire on the ground: x, y = centre, z = radius, w = Fighter hp per second.
var patches: Array[Vector4] = []
var patch_ticks: Array[int] = []
## Recent VFX for the views: chain arcs (from, to) and blasts (x, y, radius), each with the
## tick it landed; older than VFX_KEEP_TICKS are dropped.
var chain_arcs: Array[PackedVector2Array] = []
var arc_ticks: Array[int] = []
var blasts: Array[Vector3] = []
var blast_ticks: Array[int] = []
var knockdowns: int = 0
var ignitions: int = 0
var chain_hits: int = 0


## The events.json death kind of a weapon's hits.
static func kind_of(w: WeaponSpec) -> StringName:
	if w.kind == WeaponSpec.Kind.ROCKET:
		return &"blown"
	if w.kind == WeaponSpec.Kind.CONE or w.kind == WeaponSpec.Kind.THROWN:
		return &"burned"
	return &"shot"


## A table round `s` stopped at `at` (on `victim`, or null: spent, blocked, a bottle landing).
func land(arena: CombatArena, s: Shot, victim: Fighter, at: Vector2) -> void:
	var w: WeaponSpec = s.spec
	if victim != null:
		_strike(arena, s, victim, s.damage, s.vel.normalized())
	if w.splash_radius_m > 0.0:
		blasts.append(Vector3(at.x, at.y, w.splash_radius_m))
		blast_ticks.append(arena.tick)
		_splash(arena, s, victim, at)
	if w.chain_hops > 0 and victim != null and CHAIN_THROUGH_HUMANS:
		_chain(arena, s, victim)
	if w.patch_ticks > 0 and (w.kind == WeaponSpec.Kind.THROWN or victim == null):
		add_patch(at, w.patch_radius_m, w.patch_ticks, w.dot_dps * hp_scale)


## Once per tick after the shots: the timers, burning, the patches.
func step(arena: CombatArena) -> void:
	_forget(arena.tick)
	_step_patches(arena)
	for h: Fighter in arena.hostiles:
		var e: FighterFx = fx.get(h.id, null)
		if e == null or not h.alive():
			continue
		e.stun_ticks = maxi(e.stun_ticks - 1, 0)
		e.down_ticks = maxi(e.down_ticks - 1, 0)
		if e.burn_ticks > 0:
			e.burn_ticks -= 1
			_burn(arena, h, e)


## True while `h`'s brain is off this tick; then this moves it (the panic run) instead.
func holds(arena: CombatArena, h: Fighter) -> bool:
	var e: FighterFx = fx.get(h.id, null)
	if e == null or not e.holds():
		return false
	h.burst_left = 0
	h.tell_left = 0
	if e.burn_ticks > 0 and e.stun_ticks == 0 and e.down_ticks == 0:
		var weave: float = sin(float(arena.tick) * 0.2 + float(h.id)) * PANIC_WEAVE_RAD
		var run: Vector2 = e.flee.rotated(weave)
		h.facing = run
		h.pos += run * float(arena.tuning.human["walk_mps"]) * PANIC_SPEED_X * SimClock.TICK_DT
	return true


## `h`'s lasting effects (views read burning, stun, down), or null when none ever landed.
func effect(h: Fighter) -> FighterFx:
	return fx.get(h.id, null)


func add_patch(at: Vector2, radius: float, ticks_left: int, dps: float) -> void:
	for i: int in patches.size():
		if Vector2(patches[i].x, patches[i].y).distance_to(at) < patches[i].z * 0.5:
			patch_ticks[i] = maxi(patch_ticks[i], ticks_left)
			return
	patches.append(Vector4(at.x, at.y, radius, dps))
	patch_ticks.append(ticks_left)


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(fx.size())
	for id: int in fx:
		out.put_32(id)
		fx[id].write_state(out)
	out.put_32(patches.size())
	for i: int in patches.size():
		out.put_32(patch_ticks[i])
	out.put_32(knockdowns)
	out.put_32(chain_hits)


func _strike(arena: CombatArena, s: Shot, f: Fighter, amount: float, dir: Vector2) -> void:
	var w: WeaponSpec = s.spec
	var e: FighterFx = _fx(f)
	if w.dot_ticks > 0:
		ignitions += 1 if e.burn_ticks == 0 else 0
		e.burn_ticks = maxi(e.burn_ticks, w.dot_ticks)
		e.burn_dps = maxf(e.burn_dps, w.dot_dps * hp_scale)
		e.burn_by = s.shooter_id
		e.flee = dir if dir != Vector2.ZERO else f.facing
	if w.stun_ticks > 0:
		e.stun_ticks = maxi(e.stun_ticks, w.stun_ticks)
	if w.knockback_mps >= KNOCKDOWN_MPS:
		knockdowns += 1 if e.down_ticks == 0 else 0
		e.down_ticks = DOWN_TICKS
	arena.hit_dir = dir
	arena.hit_at = f.pos - dir * f.radius_m
	arena.damage(f, amount, s.shooter_id, w.id, kind_of(w))
	arena.struck.emit(f, dir, not f.alive(), w.id)


func _splash(arena: CombatArena, s: Shot, direct: Fighter, at: Vector2) -> void:
	var r: float = s.spec.splash_radius_m
	for h: Fighter in arena.hostiles:
		if h == direct or not h.alive() or not h.exposed:
			continue
		var dist: float = maxf(h.pos.distance_to(at) - h.radius_m, 0.0)
		if dist <= r:
			var amount: float = s.spec.splash_damage * hp_scale * (1.0 - dist / r)
			var dir: Vector2 = (h.pos - at).normalized() if h.pos != at else Vector2.RIGHT
			_strike(arena, s, h, amount, dir)


## The bolt jumps chain_hops times to the nearest living hostile in reach; a metal prop in reach
## bridges a hop when no body is (no damage there).
func _chain(arena: CombatArena, s: Shot, first: Fighter) -> void:
	var done: Array[Fighter] = [first]
	var from: Vector2 = first.pos
	var used: PackedVector2Array = PackedVector2Array()
	for hop: int in s.spec.chain_hops:
		var next: Fighter = _nearest(arena, from, s.spec.chain_radius_m, done)
		var to: Vector2 = next.pos if next != null else _metal(arena, from, s, used)
		if to == from:
			return
		chain_arcs.append(PackedVector2Array([from, to]))
		arc_ticks.append(arena.tick)
		if next == null:
			@warning_ignore("return_value_discarded")
			used.append(to)
		else:
			chain_hits += 1
			done.append(next)
			var amount: float = s.damage * pow(CHAIN_FALLOFF, hop + 1)
			_strike(arena, s, next, amount, (to - from).normalized())
		from = to


func _nearest(arena: CombatArena, from: Vector2, r: float, skip: Array[Fighter]) -> Fighter:
	var best: Fighter = null
	var best_d: float = r
	for h: Fighter in arena.hostiles:
		if h.alive() and h.exposed and not skip.has(h):
			var d: float = h.pos.distance_to(from)
			if d <= best_d:
				best_d = d
				best = h
	return best


func _metal(arena: CombatArena, from: Vector2, s: Shot, used: PackedVector2Array) -> Vector2:
	var best: Vector2 = from
	var best_d: float = s.spec.chain_radius_m
	for m: Vector2 in arena.metal:
		var d: float = m.distance_to(from)
		if d <= best_d and d > 0.01 and not used.has(m):
			best_d = d
			best = m
	return best


func _burn(arena: CombatArena, h: Fighter, e: FighterFx) -> void:
	arena.hit_dir = e.flee
	arena.hit_at = h.pos
	arena.damage(h, e.burn_dps * SimClock.TICK_DT, e.burn_by, &"burn", &"burned")
	if not h.alive():
		arena.struck.emit(h, e.flee, true, &"burn")


func _step_patches(arena: CombatArena) -> void:
	for i: int in range(patches.size() - 1, -1, -1):
		var c: Vector2 = Vector2(patches[i].x, patches[i].y)
		for h: Fighter in arena.hostiles:
			if h.alive() and h.pos.distance_to(c) <= patches[i].z + h.radius_m:
				var e: FighterFx = _fx(h)
				if e.burn_ticks == 0:
					ignitions += 1
					e.flee = (h.pos - c).normalized() if h.pos != c else h.facing
				e.burn_ticks = maxi(e.burn_ticks, PATCH_IGNITE_TICKS)
				e.burn_dps = maxf(e.burn_dps, patches[i].w)
		patch_ticks[i] -= 1
		if patch_ticks[i] <= 0:
			patches.remove_at(i)
			patch_ticks.remove_at(i)


func _forget(tick: int) -> void:
	while not blast_ticks.is_empty() and tick - blast_ticks[0] > VFX_KEEP_TICKS:
		blast_ticks.remove_at(0)
		blasts.remove_at(0)
	while not arc_ticks.is_empty() and tick - arc_ticks[0] > VFX_KEEP_TICKS:
		arc_ticks.remove_at(0)
		chain_arcs.remove_at(0)


func _fx(f: Fighter) -> FighterFx:
	if not fx.has(f.id):
		fx[f.id] = FighterFx.new()
	return fx[f.id]
