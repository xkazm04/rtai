extends GutTest
## PitWaves (enemy_waves.json) and WaveRun: the curves load, gates interleave, a wave waits for
## the last clear plus the breather, the report counts the wave's own enemies.


func test_table_loads_three_curves() -> void:
	var w: PitWaves = PitWaves.shipped()
	assert_true(w.ok())
	assert_eq(w.curve_ids(), [&"gentle", &"standard", &"steep"] as Array[StringName])
	assert_eq(w.waves(&"standard").size(), 3)


func test_gates_interleave() -> void:
	var w: PitWaves = PitWaves.shipped()
	var first: Array = w.waves(&"standard")[0]
	assert_eq(first.size(), 4)
	var a: Vector2 = first[0]["at"]
	var b: Vector2 = first[1]["at"]
	assert_gt(a.distance_to(b), 5.0, "second spawn comes from another gate")


func test_next_wave_waits_for_clear_and_breather() -> void:
	var w: PitWaves = PitWaves.shipped()
	var pit: EnemyPit = PitLayout.build(3)
	var run: WaveRun = WaveRun.new(w, &"gentle")
	for i: int in 200:
		run.step(pit)
		pit.step()
	assert_eq(run.index, 0)
	assert_eq(pit.agents.size(), 3, "wave 2 must not open while wave 1 lives")
	for e: EnemyAgent in pit.agents:
		pit.hurt(e, 99.0, Vector2.RIGHT)
	run.step(pit)
	pit.step()
	assert_eq(run.report().size(), 1)
	for i: int in w.breather_ticks - 2:
		run.step(pit)
		pit.step()
	assert_eq(run.index, 0, "still in the breather")
	for i: int in 3:
		run.step(pit)
		pit.step()
	assert_eq(run.index, 1)
