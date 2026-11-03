extends GutTest
## A tracking gun leads a moving Rivet (enemies.json squad.aim_lead): a steady strafe is hit far
## more often than with the lead off; a reversal after the lock still dodges.


func _strafe_hits(lead: float, reverse_at_lock: bool) -> float:
	var pit: EnemyPit = PitLayout.build(17, false)
	pit.rivet_pos = Vector2.ZERO
	PitLayout.place(pit, [&"patrol_cop"], PackedVector2Array([Vector2(9.0, 0.0)]))
	pit.roster.aim_lead = lead
	pit.rivet_hp = 100000.0
	var cop: EnemyAgent = pit.agents[0]
	var dir: float = 1.0
	var reversed: bool = false
	for t: int in 1200:
		if t % 240 == 0:
			pit.rivet_pos = Vector2(0.0, -4.0 * dir)  # restart the pass from one side
		var locked: bool = cop.aim_locked(pit.roster.aim_lock_ticks)
		if reverse_at_lock and locked and not reversed:
			dir = -dir
		reversed = locked
		pit.rivet_vel = Vector2(0.0, 2.5 * dir)
		pit.rivet_pos += pit.rivet_vel * SimClock.TICK_DT
		pit.step()
	return pit.stats["shot_hits"] / maxf(pit.stats["shots"], 1.0)


func test_lead_hits_a_steady_strafe() -> void:
	var led: float = _strafe_hits(0.8, false)
	var flat: float = _strafe_hits(0.0, false)
	assert_gt(led, flat + 0.2, "led %.2f vs flat %.2f" % [led, flat])


func test_a_reversal_after_the_lock_still_dodges() -> void:
	var led: float = _strafe_hits(0.8, false)
	var juked: float = _strafe_hits(0.8, true)
	assert_lt(juked, led * 0.5, "juked %.2f vs steady %.2f" % [juked, led])
