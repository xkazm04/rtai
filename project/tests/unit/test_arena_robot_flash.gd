extends GutTest


func test_robot_hit_lights_the_flash_and_it_clears() -> void:
	var host: ArenaRobotRigs = add_child_autofree(ArenaRobotRigs.new())
	host.arena = CombatArena.new(
		CombatTuning.shipped(), Events, RngRegistry.new(5).stream(&"combat")
	)
	var rig: CutRig = CutRig.new()
	host.add_child(rig)
	var h: Fighter = Fighter.new()
	h.id = 7
	h.machine = true
	h.hp = 10.0
	h.pos = Vector2(3, 4)
	host._react(h, rig)
	rig.clips.sample(rig, SimClock.TICK_DT)
	assert_false(rig.is_tinted())
	h.hurt_tick = 12
	host._react(h, rig)
	rig.clips.sample(rig, SimClock.TICK_DT)
	assert_true(rig.is_tinted())
	assert_gt(rig.shove_v.length(), 0.0)
	for _i: int in int(RigClips.HIT_S * float(SimClock.TICK_RATE)) + 2:
		rig.clips.sample(rig, SimClock.TICK_DT)
	assert_false(rig.is_tinted())
	host._react(h, rig)
	rig.clips.sample(rig, SimClock.TICK_DT)
	assert_false(rig.is_tinted(), "an old hurt tick does not flash again")
