extends GutTest
## The robot thug's claw lunge: after the windup it dashes along the LOCKED aim, then swings.


func _thug_pit() -> EnemyPit:
	var pit: EnemyPit = PitLayout.build(5, false)
	pit.rivet_pos = Vector2.ZERO
	PitLayout.place(pit, [&"robot_thug"], PackedVector2Array([Vector2(4.4, 0.0)]))
	return pit


func _run_to_swing(pit: EnemyPit, sidestep: Vector2) -> EnemyAgent:
	var thug: EnemyAgent = pit.agents[0]
	var moved: bool = false
	for _t: int in 600:
		pit.step()
		var locking: bool = thug.state == EnemyAgent.State.WINDUP
		if not moved and locking and thug.aim_locked(pit.roster.aim_lock_ticks):
			pit.rivet_pos += sidestep
			moved = true
		if pit.stats["swings"] >= 1.0:
			break
	return thug


func test_claw_lunges_closes_and_hits_a_standing_rivet() -> void:
	var pit: EnemyPit = _thug_pit()
	assert_gt(pit.roster.archetype(&"robot_thug").weapon.lunge_m, 0.0, "the claw lunges (data)")
	var thug: EnemyAgent = _run_to_swing(pit, Vector2.ZERO)
	assert_eq(pit.stats["swings"], 1.0)
	assert_eq(pit.stats["swing_hits"], 1.0, "a player who ignores the tell is caught")
	assert_lt(thug.pos.x, 2.0, "the lunge closed the gap the walk alone would not")


func test_a_sidestep_after_the_lock_is_missed() -> void:
	var pit: EnemyPit = _thug_pit()
	@warning_ignore("return_value_discarded")
	_run_to_swing(pit, Vector2(0.0, 2.6))
	assert_eq(pit.stats["swings"], 1.0)
	assert_eq(pit.stats["swing_hits"], 0.0, "the dash follows the locked aim, not the player")
