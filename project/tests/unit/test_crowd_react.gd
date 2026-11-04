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
