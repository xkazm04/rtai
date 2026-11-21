extends RefCounted
## Formation duel with real SWAT decisions and travelling Gloria rounds. Rivet fires
## at the exposed shoulder so some shots reach the rifleman beside the slab's edge.


static func run(mix: String) -> Dictionary:
	var rng: RandomNumberGenerator = RngRegistry.new(22).stream(&"combat")
	var bus: EventBus = EventBus.new()
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	var ids: PackedStringArray = mix.split(",")
	if ids.size() < 2:
		bus.free()
		return {}
	var squad: Array[Fighter] = []
	for index: int in ids.size():
		var id: StringName = StringName(ids[index].strip_edges())
		if id == &"" or arena.squad_ai.pit.roster.archetype(id) == null:
			bus.free()
			return {}
		var offset: Vector2 = Vector2(2.6, 2.4 if index % 2 == 0 else -2.4)
		var at: Vector2 = Vector2(10, 0) + (offset if index > 0 else Vector2.ZERO)
		var h: Fighter = arena.squad_ai.spawn_member(arena, at, id)
		h.facing = h.pos.direction_to(arena.rivet.pos)
		squad.append(h)
	arena.rivet.weapon = &"gloria"
	var result: Dictionary = {"mix": ids, "seed": 22, "mobile_cover_ticks": {}, "shadow_hits": []}
	_fight(arena, squad, result)
	bus.free()
	return result


static func _fight(arena: CombatArena, members: Array[Fighter], result: Dictionary) -> void:
	var start: Vector2 = members[0].pos
	var cover_ticks: Dictionary = result.mobile_cover_ticks
	var hits: Array = result.shadow_hits
	for tick: int in range(1, 361):
		var health: Array[float] = []
		var target: Fighter
		for h: Fighter in members:
			health.append(h.hp)
			var mind: SquadMind = arena.squad_ai.minds.get(h.id)
			if h.alive() and mind != null and mind.mobile_goal.is_finite():
				var key: String = str(h.id)
				var total: int = cover_ticks.get(key, 0)
				cover_ticks[key] = total + 1
				if target == null:
					target = h
		if target != null and tick >= 170:
			var side: Vector2 = arena.rivet.pos.direction_to(members[0].pos).orthogonal()
			var shoulder: float = signf(side.dot(target.pos - members[0].pos))
			@warning_ignore("return_value_discarded")
			arena.rivet_fire(target.pos + side * shoulder * 0.28)
		arena.step(tick)
		_shadow_hits(arena, members, health, hits)
		if not arena.rivet.alive():
			break
	result.carrier_travel_m = members[0].pos.distance_to(start)
	result.rivet_hp = arena.rivet.hp


static func _shadow_hits(
	arena: CombatArena, members: Array[Fighter], health: Array[float], hits: Array
) -> void:
	var row: EnemyRoster.Archetype = arena.squad_ai.pit.roster.archetype(members[0].archetype)
	if members[0].archetype != &"shield_robot":
		return
	var protected_hp: float = arena.tuning.weapon(arena.rivet.weapon).damage * row.shield_front_mult
	for i: int in range(1, members.size()):
		var h: Fighter = members[i]
		var loss: float = health[i] - h.hp
		var carrier: Fighter = members[0]
		if is_equal_approx(loss, protected_hp) and carrier.alive():
			hits.append(
				{
					"tick": arena.tick,
					"ally_id": h.id,
					"damage": loss,
					"distance_to_shield_m": h.pos.distance_to(carrier.pos)
				}
			)
