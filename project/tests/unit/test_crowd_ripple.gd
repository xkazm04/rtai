extends GutTest
## n12 E3: a cower waits for the news of its bang to reach the person (distance / mps), capped;
## off (mps 0) every cower keeps its old tick.


func _ripple(mps: float, max_ticks: int) -> CrowdRipple:
	var r: CrowdRipple = CrowdRipple.new()
	r.mps = mps
	r.max_ticks = max_ticks
	return r


func test_the_table_ships_it_off_with_a_cap() -> void:
	var r: CrowdRipple = CrowdRipple.shipped()
	assert_false(r.on(), "shipped OFF (n12 E3: a delayed duck read as a lost one on film)")
	assert_gt(r.max_ticks, 0, "mps alone turns it on")


func test_the_wait_grows_with_distance_and_is_capped() -> void:
	var r: CrowdRipple = _ripple(12.0, 45)
	var m: float = SimConst.PX_PER_M
	assert_eq(r.ticks_from(0.0), 0, "at the bang: at once")
	assert_eq(r.ticks_from(6.0 * m), 30, "6 m at 12 m/s: half a second")
	assert_lt(r.ticks_from(2.0 * m), r.ticks_from(4.0 * m), "the far duck later")
	assert_eq(r.ticks_from(90.0 * m), 45, "the cap")


func test_the_nearest_bang_counts_and_none_waits_nothing() -> void:
	var r: CrowdRipple = _ripple(12.0, 45)
	var m: float = SimConst.PX_PER_M
	assert_eq(r.ticks_to(Vector2(6.0 * m, 0.0)), 0, "no bang this frame")
	r.bangs = PackedVector2Array([Vector2(40.0 * m, 0.0), Vector2.ZERO])
	assert_eq(r.ticks_to(Vector2(6.0 * m, 0.0)), 30)


func test_off_waits_nothing() -> void:
	var r: CrowdRipple = _ripple(0.0, 45)
	r.bangs = PackedVector2Array([Vector2.ZERO])
	assert_false(r.on())
	assert_eq(r.ticks_to(Vector2(300.0, 0.0)), 0)
	assert_eq(r.ticks_from(300.0), 0)


## A death 1 m and 2 m from two walkers: with the ripple the near one cowers first, both away.
func test_a_startle_runs_outward_from_the_body() -> void:
	var c: CrowdReact = CrowdReact.make()
	c.ripple = _ripple(12.0, 45)
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var near: CutRig = autofree(CutRig.new())
	var far: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = near
	rigs._by_actor[43] = far
	var m: float = SimConst.PX_PER_M
	rigs.feed = _street(false, m)
	c.observe(rigs)
	rigs.feed = _street(true, m)
	c.observe(rigs)
	assert_eq(c.startles, 2, "both noticed")
	assert_eq(c.cowers, 0, "the news has not reached them yet")
	var near_at: int = -1
	var far_at: int = -1
	for t: int in 20:
		c.observe(rigs)
		near_at = t if near_at < 0 and c.cowers >= 1 else near_at
		far_at = t if far_at < 0 and c.cowers >= 2 else far_at
	assert_between(near_at, 3, 6, "1 m at 12 m/s: 5 ticks")
	assert_between(far_at, 8, 11, "2 m: 10 ticks")
	assert_gt(near.react.dir.x, 0.9, "away from the body (east of it)")
	assert_gt(far.react.dir.x, 0.9)


func _street(dead: bool, m: float) -> RigFeed:
	var f: RigFeed = RigFeed.new()
	@warning_ignore("return_value_discarded")
	f.put(0, 41, BodyPlan.Kind.PED, Vector2.ZERO, Vector2.ZERO)
	f.flags[0] = RigFeed.Flag.DEAD if dead else 0
	@warning_ignore("return_value_discarded")
	f.put(1, 42, BodyPlan.Kind.PED, Vector2(m, 0.0), Vector2.ZERO)
	@warning_ignore("return_value_discarded")
	f.put(2, 43, BodyPlan.Kind.PED, Vector2(2.0 * m, 0.0), Vector2.ZERO)
	return f


func test_the_fights_bangs_are_its_muzzles_and_blasts() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var arena: CombatArena = CombatArena.new(
		CombatTuning.shipped(), bus, RngRegistry.new(5).stream(&"combat")
	)
	var m: float = SimConst.PX_PER_M
	var fired: Shot = Shot.new()
	fired.origin = Vector2(2.0, 3.0)
	fired.pos = Vector2(9.0, 3.0)
	var bare: Shot = Shot.new()
	bare.pos = Vector2(5.0, 1.0)
	arena.shots.append(fired)
	arena.shots.append(bare)
	arena.areas = FightAreas.new()
	arena.areas.blasts.append(Vector3(7.0, 8.0, 3.0))
	var b: PackedVector2Array = CrowdRipple.bangs_of(arena)
	assert_eq(b.size(), 3)
	assert_eq(b[0], Vector2(2.0, 3.0) * m, "the muzzle, not where the round is")
	assert_eq(b[1], Vector2(5.0, 1.0) * m, "a round with no origin: where it is")
	assert_eq(b[2], Vector2(7.0, 8.0) * m, "a blast")
	assert_eq(CrowdRipple.bangs_of(null).size(), 0)
