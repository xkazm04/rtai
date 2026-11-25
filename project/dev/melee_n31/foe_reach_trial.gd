extends RefCounted
## n31 melee 01b: one foe, one stepping Rivet, the real CombatArena + ArenaSquad on a bare map.
## Rivet stands until the foe's tell starts, waits `delay` ticks, then walks straight away from the
## foe (or sideways) at `speed`. Measures only: no rule is changed.

const FOES: Array[StringName] = [&"riot_cop", &"robot_thug", &"appliance_warden", &"shield_robot"]
const LIMIT_TICKS: int = 900
const AFTER_TICKS: int = 24


## The geometry the sim hits with, from the tables (no arena).
func geometry(id: StringName) -> Dictionary:
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	var a: EnemyRoster.Archetype = roster.archetype(id)
	var rivet_r: float = CombatTuning.shipped().rivet["radius_m"]
	var out: Dictionary = {
		"foe": String(id),
		"weapon": String(a.weapon.id),
		"authored_reach_m": a.weapon.reach_m,
		"rivet_radius_m": rivet_r,
		"telegraph_ticks": a.telegraph_ticks,
		"cooldown_ticks": a.weapon.cooldown_ticks,
		"lunge_m": a.weapon.lunge_m,
		"hit_reach_centre_m": a.weapon.reach_m + rivet_r,
		"swing_starts_within_m": a.weapon.reach_m + rivet_r,
	}
	if id == &"shield_robot":
		var travel: float = a.speed_mps * SimClock.TICK_DT * FoeShield.LUNGE_TICKS
		out["lunge_travel_m"] = travel
		out["drawn_tip_m"] = travel + a.weapon.reach_m
		out["drawn_source"] = "FoeShoveZone.polygon tip, what FoeShieldView draws"
		out["slab_half_width_m"] = FoeShield.SLAB_HALF_M
	else:
		out["drawn_tip_m"] = a.weapon.reach_m
		out["drawn_source"] = "authored reach_m (the art's strike frame is not measured)"
	return out


## One trial. Returns what the hit looked like, or hit=false.
func run(id: StringName, delay: int, speed: float, mode: String, seed_value: int) -> Dictionary:
	var rng: RandomNumberGenerator = RngRegistry.new(seed_value).stream(&"combat")
	var bus: EventBus = EventBus.new()
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	arena.rivet.weapon = &"gloria"
	var h: Fighter = arena.squad_ai.spawn_member(arena, Vector2(5, 0), id)
	var out: Dictionary = _walk(arena, h, delay, speed, mode)
	bus.free()
	return out


func _walk(arena: CombatArena, h: Fighter, delay: int, speed: float, mode: String) -> Dictionary:
	var out: Dictionary = {"hit": false, "tell_tick": -1}
	var start: Vector2 = Vector2.ZERO
	var aim: Vector2 = Vector2.RIGHT
	var dir: Vector2 = Vector2.ZERO
	var tell_tick: int = -1
	for tick: int in range(1, LIMIT_TICKS + 1):
		var mind: SquadMind = arena.squad_ai.minds.get(h.id)
		if tell_tick < 0 and mind != null and (h.swing_left > 0 or h.tell_left > 0):
			tell_tick = tick
			start = h.pos
			aim = mind.agent.aim if mind.agent.aim != Vector2.ZERO else h.facing
			dir = aim if mode == "away" else aim.orthogonal()
			out["tell_tick"] = tick
			out["tell_dist_m"] = h.pos.distance_to(arena.rivet.pos)
		if tell_tick >= 0 and tick >= tell_tick + delay:
			arena.rivet.pos += dir * speed * SimClock.TICK_DT
		var pit: EnemyPit = arena.squad_ai.pit
		pit.rivet_pos = arena.rivet.pos
		pit.shots = arena.shots
		var before: Vector2 = arena.rivet.pos
		var hp: float = arena.rivet.hp
		arena.step(tick)
		if arena.rivet.hp < hp:
			return _hit(out, tick, before - start, before.distance_to(h.pos), aim)
		if tell_tick >= 0 and tick > tell_tick + mind.agent.arch.telegraph_ticks + AFTER_TICKS:
			break
	return out


func _hit(out: Dictionary, tick: int, rel: Vector2, centre: float, aim: Vector2) -> Dictionary:
	out["hit"] = true
	out["hit_tick"] = tick
	out["since_tell"] = tick - int(str(out["tell_tick"]))
	out["forward_m"] = rel.dot(aim)
	out["lateral_m"] = absf(rel.cross(aim))
	out["centre_dist_m"] = centre
	return out
