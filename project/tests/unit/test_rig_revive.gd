extends GutTest
## d9-rivet: Rivet respawns on the same rig. His row alive again must end the death clip the DEAD
## flag latched (he lay in his sprawl at the hub while he walked); a cop's corpse stays down.


func _rig(pool: RigPool, kind: BodyPlan.Kind) -> CutRig:
	@warning_ignore("return_value_discarded")
	pool.prewarm(kind, 1)
	return pool.acquire(kind, _look(kind), Vector2.ZERO, 0.0)


func _look(kind: BodyPlan.Kind) -> RigVariant:
	return RigVariant.rivet() if kind == BodyPlan.Kind.RIVET else RigVariant.crowd(5)


func _feed(kind: BodyPlan.Kind, flags: int) -> RigFeed:
	var feed: RigFeed = RigFeed.new(1)
	@warning_ignore("return_value_discarded")
	feed.put(0, 7, kind, Vector2.ZERO, Vector2.ZERO)
	feed.flags[0] = flags
	feed.count = 1
	return feed


func _step(rig: CutRig, feed: RigFeed, n: int) -> void:
	for _t: int in n:
		RigInput.apply(rig, feed, 0)
		rig.drive(SimClock.TICK_DT)


func test_rivet_stands_up_when_his_row_is_alive_again() -> void:
	var pool: RigPool = add_child_autofree(RigPool.new())
	var rig: CutRig = _rig(pool, BodyPlan.Kind.RIVET)
	_step(rig, _feed(BodyPlan.Kind.RIVET, RigFeed.Flag.DEAD), 60)
	assert_true(rig.dead, "down in his sprawl for the beat")
	_step(rig, _feed(BodyPlan.Kind.RIVET, 0), 2)
	assert_false(rig.dead, "up at the hub")
	assert_lt(rig.clips.death_t, 0.0)
	assert_eq(rig.c_sprawl, 0.0)


func test_a_cops_corpse_stays_down() -> void:
	var pool: RigPool = add_child_autofree(RigPool.new())
	var rig: CutRig = _rig(pool, BodyPlan.Kind.COP)
	_step(rig, _feed(BodyPlan.Kind.COP, RigFeed.Flag.DEAD), 60)
	_step(rig, _feed(BodyPlan.Kind.COP, 0), 2)
	assert_true(rig.dead)
