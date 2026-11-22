extends GutTest


func test_adjacent_waves_count_new_bursts_including_zero() -> void:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	var stats: GauntletWaveStats = GauntletWaveStats.new()
	var row: Dictionary = {}
	var dash: int = 1 << stage.pilot.actions.bit(&"dash")
	stage.arena.rivet.pos = Vector2(-20, -20)
	stage.step(0, TickInput.new(dash, 127, 0))
	stats.begin(stage)
	stage.step(1, TickInput.new())
	stats.finish(stage, row)
	var count: int = row["dashes"]
	assert_eq(count, 0)
	stats.begin(stage)
	for i: int in range(2, 60):
		stage.step(i, TickInput.new(dash if i == 52 else 0, 127, 0))
	stats.finish(stage, row)
	count = row["dashes"]
	assert_eq(count, 1)
