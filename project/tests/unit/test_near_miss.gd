extends GutTest


func _shot(at: Vector2, vel: Vector2) -> Shot:
	var s: Shot = Shot.new()
	s.pos = at
	s.vel = vel
	return s


func _human(at: Vector2) -> Fighter:
	var h: Fighter = Fighter.make(Fighter.Kind.GUARD, 3, at, 1.0)
	h.radius_m = 0.35
	return h


func test_a_round_past_the_body_within_reach_is_a_near_miss() -> void:
	var h: Fighter = _human(Vector2(5.0, 0.7))
	assert_true(NearMiss.passed(_shot(Vector2(5.5, 0.0), Vector2(40.0, 0.0)), h))


func test_a_round_still_coming_or_far_or_through_the_body_is_not() -> void:
	var h: Fighter = _human(Vector2(5.0, 0.7))
	assert_false(NearMiss.passed(_shot(Vector2(4.5, 0.0), Vector2(40.0, 0.0)), h), "not past yet")
	assert_false(NearMiss.passed(_shot(Vector2(5.5, -1.0), Vector2(40.0, 0.0)), h), "too far off")
	assert_false(NearMiss.passed(_shot(Vector2(5.5, 0.6), Vector2(40.0, 0.0)), h), "a hit line")


func test_a_near_miss_ducks_the_human_once_per_round() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(3)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	var h: Fighter = _human(Vector2(5.0, 0.7))
	arena.hostiles.append(h)
	arena.shots.append(_shot(Vector2(5.5, 0.0), Vector2(40.0, 0.0)))
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[3] = rig
	var near: NearMiss = NearMiss.new()
	var pipe: DeathPipe = DeathPipe.make(ReactTable.shipped())
	near.apply(arena, rigs, pipe)
	assert_eq(near.ducks, 1)
	assert_eq(rig.react.kind, &"cover")
	rig.react.settle()
	near.apply(arena, rigs, pipe)
	assert_eq(near.ducks, 1, "one duck per round")
