class_name Impact
extends RefCounted
## What a round does where it stops: direct damage, splash with linear falloff, an electro chain
## through metal, burning, stun and knockback. Every hp change goes through ProjectileSim.hurt().


static func land(sim: ProjectileSim, p: Projectile, victim: RangeTarget, at: Vector2) -> void:
	var w: WeaponSpec = p.spec
	if victim != null:
		_strike(sim, p, victim, p.damage, p.vel.normalized())
	if w.splash_radius_m > 0.0:
		_splash(sim, p, victim, at)
	if w.chain_hops > 0 and victim != null:
		_chain(sim, p, victim)
	if w.patch_ticks > 0 and (w.kind == WeaponSpec.Kind.THROWN or victim == null):
		sim.add_patch(at, w.patch_radius_m, w.patch_ticks, w.dot_dps)


static func _strike(
	sim: ProjectileSim, p: Projectile, t: RangeTarget, amount: float, dir: Vector2
) -> void:
	var w: WeaponSpec = p.spec
	t.knock += dir * w.knockback_mps
	if w.dot_ticks > 0:
		t.burn_ticks = maxi(t.burn_ticks, w.dot_ticks)
		t.burn_dps = maxf(t.burn_dps, w.dot_dps)
	if w.stun_ticks > 0 and not t.metal:
		t.stun_ticks = maxi(t.stun_ticks, w.stun_ticks)
	sim.hurt(t, amount, w.hit_class, dir, p.shooter_id)


static func _splash(sim: ProjectileSim, p: Projectile, direct: RangeTarget, at: Vector2) -> void:
	var r: float = p.spec.splash_radius_m
	for t: RangeTarget in sim.targets:
		if t == direct or not t.alive():
			continue
		var dist: float = maxf(t.pos.distance_to(at) - t.radius_m, 0.0)
		if dist > r:
			continue
		var amount: float = p.spec.splash_damage * (1.0 - dist / r)
		var dir: Vector2 = (t.pos - at).normalized() if t.pos != at else Vector2.RIGHT
		_strike(sim, p, t, amount, dir)


## The bolt jumps to the nearest living metal target within chain_radius_m, chain_hops times.
static func _chain(sim: ProjectileSim, p: Projectile, first: RangeTarget) -> void:
	if not first.metal:
		return
	var hit: Array[RangeTarget] = [first]
	var at: RangeTarget = first
	for hop: int in p.spec.chain_hops:
		var next: RangeTarget = _nearest_metal(sim, at.pos, p.spec.chain_radius_m, hit)
		if next == null:
			return
		sim.chain_arcs.push_back(PackedVector2Array([at.pos, next.pos]))
		_strike(sim, p, next, p.damage * pow(0.7, hop + 1), (next.pos - at.pos).normalized())
		hit.append(next)
		at = next


static func _nearest_metal(
	sim: ProjectileSim, from: Vector2, r: float, skip: Array[RangeTarget]
) -> RangeTarget:
	var best: RangeTarget = null
	var best_d: float = r
	for t: RangeTarget in sim.targets:
		if t.metal and t.alive() and not skip.has(t):
			var d: float = t.pos.distance_to(from)
			if d <= best_d:
				best_d = d
				best = t
	return best
