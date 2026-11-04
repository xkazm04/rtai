class_name GunFxRounds
extends RefCounted
## Lane gunplay: GunFx's round tracking (split out of gun_fx.gd): which rounds left the fight
## since the last tick and where each stopped, and a hostile's muzzle when its round appears.
## Presentation only, never written back to the sim.


## Every Rivet bullet or ray (and every enemy round) that left the fight since last tick stopped
## where it was last seen: on a body, on Rivet's plating, on metal, or on the ground.
static func track(fx: GunFx, arena: CombatArena, tick: int) -> void:
	var now: Dictionary = {}
	for s: Shot in arena.shots:
		if not s.from_rivet or s.spec == null or _marks(s.spec):
			now[s] = [s.pos, s.vel * SimClock.TICK_DT, s.from_rivet]
			if not s.from_rivet and not fx.shots_seen.has(s):
				_enemy_fired(fx, arena, s, tick)
	for s: Variant in fx.shots_seen:
		if not now.has(s):
			var last: Array = fx.shots_seen[s]
			_impact(fx, arena, last, tick)
	fx.shots_seen = now


## A hostile's round just appeared: a small flash at its gun and a shell kicked to its right.
static func _enemy_fired(fx: GunFx, arena: CombatArena, s: Shot, tick: int) -> void:
	var dir: Vector2 = s.vel.normalized()
	var pistol: float = fx.look(&"pistol").get("casing_m", 0.2)
	var shell: float = pistol * 0.8
	for h: Fighter in arena.hostiles:
		if h.id == s.shooter_id:
			var at: Vector2 = h.pos + dir * (h.radius_m + 0.35)
			fx.enemy_flashes.append(Vector4(at.x, at.y, float(tick), dir.angle()))
			var v: Vector2 = (-dir.orthogonal() * 2.6 - dir * 0.6) * SimClock.TICK_DT
			fx.add_bit(h.pos + dir * h.radius_m, v, 120, shell)
			return


## The round's last step (seen pos -> one tick on) is swept: the first body (or Rivet, for an
## enemy round) it crosses is where it stopped; else it fell at the step's end (metal near it
## sparks, the ground scuffs).
static func _impact(fx: GunFx, arena: CombatArena, last: Array, tick: int) -> void:
	var from: Vector2 = last[0]
	var hop: Vector2 = last[1]
	var at: Vector2 = from + hop
	var kind: GunFx.Hit = GunFx.Hit.GROUND
	var bodies: Array[Fighter] = [arena.rivet]
	if last[2]:
		bodies = arena.hostiles
	for h: Fighter in bodies:
		var c: Vector2 = Geometry2D.get_closest_point_to_segment(h.pos, from, from + hop)
		if c.distance_to(h.pos) <= h.radius_m + 0.3:
			kind = GunFx.Hit.BODY if last[2] else GunFx.Hit.PLATING
			at = c
			break
	if kind == GunFx.Hit.GROUND:
		for m: Vector2 in arena.metal:
			if m.distance_to(at) <= 0.9:
				kind = GunFx.Hit.METAL
	# a plasma bolt (gun_fx.json scorch) adds SCORCH to the kind: a burn ring and a pop
	var scorch: bool = last[2] and fx.look(arena.gun.trigger.spec.id).get("scorch", false)
	var code: int = int(kind) + (GunFx.SCORCH if scorch else 0)
	fx.impacts.append(Vector4(at.x, at.y, float(code), float(tick)))
	@warning_ignore("return_value_discarded")
	fx.impact_dir.append(hop.normalized())


## Rivet's rounds GunFx marks: bullets, and a ray (a bolt with no chain; the electro gun's chain
## arcs are FightAreasArt's).
static func _marks(spec: WeaponSpec) -> bool:
	var ray: bool = spec.kind == WeaponSpec.Kind.BOLT and spec.chain_hops == 0
	return spec.kind == WeaponSpec.Kind.BULLET or ray
