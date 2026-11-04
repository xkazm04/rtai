extends GutTest
## CrowdReact: a pedestrian whose FLEE flag comes on cowers after DELAY_TICKS, away along its
## flight; one already fleeing when first seen, a cop, or a person without a full rig does not.


func _feed(flee: bool, kind: BodyPlan.Kind = BodyPlan.Kind.PED) -> RigFeed:
	var f: RigFeed = RigFeed.new()
	@warning_ignore("return_value_discarded")
	f.put(0, 42, kind, Vector2.ZERO, Vector2(-90.0, 0.0))
	f.flags[0] = RigFeed.Flag.FLEE if flee else 0
	return f


func test_the_flight_onset_cowers_away_after_the_delay() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rig.actor_id = 42
	rigs._by_actor[42] = rig
	rigs.feed = _feed(false)
	c.observe(rigs)
	rigs.feed = _feed(true)
	for i: int in CrowdReact.DELAY_TICKS - 1:
		c.observe(rigs)
	assert_eq(c.cowers, 0, "waits for the sim to turn the body")
	c.observe(rigs)
	assert_eq(c.cowers, 1)
	assert_eq(rig.react.kind, &"cower")
	assert_lt(rig.react.dir.x, -0.9, "the hop goes along the flight (facing 0: rig space = world)")


func test_already_fleeing_or_a_cop_never_cowers() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	rigs.feed = _feed(true)
	for i: int in 6:
		c.observe(rigs)
	assert_eq(c.cowers, 0, "fleeing when first seen: no startle")
	rigs.feed = _feed(false, BodyPlan.Kind.COP)
	c.observe(rigs)
	rigs.feed = _feed(true, BodyPlan.Kind.COP)
	for i: int in 6:
		c.observe(rigs)
	assert_eq(c.cowers, 0, "cops do not cower")


func test_the_cower_row_is_in_the_table() -> void:
	var t: ReactTable = ReactTable.shipped()
	assert_almost_eq(t.length(&"cower"), 0.7, 0.001)


func test_a_city_kill_plays_the_standard_death_along_the_round() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	rigs.feed = _feed(false, BodyPlan.Kind.COP)
	c.observe(rigs)
	rigs.feed = _feed(false, BodyPlan.Kind.COP)
	rigs.feed.flags[0] = RigFeed.Flag.DEAD
	c.observe(rigs)
	assert_eq(c.deaths, 1)
	assert_eq(rig.react.kind, &"death_bullet", "3 m/s slide: a round, not a car")
	assert_lt(rig.react.dir.x, -0.9, "falls along the round")
	c.observe(rigs)
	assert_eq(c.deaths, 1, "a corpse dies once")


func test_dead_when_first_seen_is_not_killed_again() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	rigs.feed = _feed(false)
	rigs.feed.flags[0] = RigFeed.Flag.DEAD
	c.observe(rigs)
	assert_eq(c.deaths, 0)


func test_a_fleeing_person_trips_over_a_body_once() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	var f: RigFeed = _feed(true)
	@warning_ignore("return_value_discarded")
	f.put(1, 7, BodyPlan.Kind.PED, Vector2(-10.0, 0.0), Vector2.ZERO)
	f.flags[1] = RigFeed.Flag.DEAD
	rigs.feed = f
	c.observe(rigs)
	assert_eq(c.trips, 1)
	assert_eq(rig.react.kind, &"trip")
	assert_lt(rig.react.dir.x, -0.9, "pitches along the flight")
	rig.react.settle()
	c.observe(rigs)
	assert_eq(c.trips, 1, "one trip per body")


func test_a_fleeing_person_trips_over_the_fights_dead_drawn_elsewhere() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	rigs.feed = _feed(true)
	c.extra_bodies[-1 - 3] = Vector2(-10.0, 0.0)  # a dead cop on the arena's own rigs
	c.observe(rigs)
	assert_eq(c.trips, 1)
	rig.react.settle()
	c.observe(rigs)
	assert_eq(c.trips, 1, "one trip per body")


func test_a_walker_or_a_far_body_does_not_trip() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	var f: RigFeed = _feed(false)
	@warning_ignore("return_value_discarded")
	f.put(1, 7, BodyPlan.Kind.PED, Vector2(-10.0, 0.0), Vector2.ZERO)
	f.flags[1] = RigFeed.Flag.DEAD
	rigs.feed = f
	c.observe(rigs)
	assert_eq(c.trips, 0, "walking past a body is not a trip")
	f.flags[0] = RigFeed.Flag.FLEE
	f.pos[1] = Vector2(-CrowdReact.TRIP_M * SimConst.PX_PER_M * 1.5, 0.0)
	c.observe(rigs)
	assert_eq(c.trips, 0, "a body beyond TRIP_M")


func test_a_limping_rig_drops_on_its_step_and_hunches_standing() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var r: HumanReact = HumanReact.on(rig)
	r.limp = 1.0
	rig.vel_in = Vector2(60.0, 0.0)
	rig.phase = 0.25
	r.pre(rig, 1.0 / 60.0)
	assert_lt(r.scl.x, 0.9, "the bad leg's step drops the body")
	assert_gt(r.off.y, 20.0, "and tips it to that side")
	rig.vel_in = Vector2.ZERO
	r.pre(rig, 1.0 / 60.0)
	assert_almost_eq(r.off.y, 0.0, 0.001, "standing: no step")
	assert_lt(r.scl.x, 1.0, "standing: the hunch stays")
	r.limp = 0.0
	r.pre(rig, 1.0 / 60.0)
	assert_eq(r.scl, Vector2.ONE, "whole: nothing drawn")


func _pair(dead: bool, gap_px: float) -> RigFeed:
	var f: RigFeed = RigFeed.new()
	@warning_ignore("return_value_discarded")
	f.put(0, 7, BodyPlan.Kind.PED, Vector2.ZERO, Vector2.ZERO)
	f.flags[0] = RigFeed.Flag.DEAD if dead else 0
	@warning_ignore("return_value_discarded")
	f.put(1, 42, BodyPlan.Kind.PED, Vector2(gap_px, 0.0), Vector2.ZERO)
	return f


func test_a_death_startles_the_neighbours_away_from_the_body() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	var gap: float = 1.0 * SimConst.PX_PER_M
	rigs.feed = _pair(false, gap)
	c.observe(rigs)
	rigs.feed = _pair(true, gap)
	c.observe(rigs)
	assert_eq(c.startles, 1)
	assert_eq(rig.react.kind, &"cower")
	assert_gt(rig.react.dir.x, 0.9, "away from the body (east of it)")
	c.observe(rigs)
	assert_eq(c.startles, 1, "one startle per death")


func test_a_death_beyond_startle_m_is_not_noticed() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	var gap: float = (CrowdReact.STARTLE_M + 0.5) * SimConst.PX_PER_M
	rigs.feed = _pair(false, gap)
	c.observe(rigs)
	rigs.feed = _pair(true, gap)
	c.observe(rigs)
	assert_eq(c.startles, 0)


func test_a_busy_body_trips_once_its_cower_ends() -> void:
	var c: CrowdReact = CrowdReact.make()
	var rigs: CharacterRigs = autofree(CharacterRigs.new())
	var rig: CutRig = autofree(CutRig.new())
	rigs._by_actor[42] = rig
	rigs.feed = _feed(true)
	HumanReact.on(rig).play(rig, CrowdReact.COWER, Vector2.LEFT, c.table)
	c.extra_bodies[-1 - 3] = Vector2(-10.0, 0.0)
	c.observe(rigs)
	assert_eq(c.trips, 0, "mid-cower: no trip yet")
	rig.react.settle()
	c.observe(rigs)
	assert_eq(c.trips, 1, "the body underfoot still trips it after")
