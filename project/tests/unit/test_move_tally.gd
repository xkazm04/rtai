extends GutTest


func test_wave_rows_record_only_effective_uses_inside_the_interval() -> void:
	var options: ArenaArgs = ArenaArgs.parse([])
	var session: ArenaSession = ArenaSession.open_with_args(Events, Data, 23, null, options)
	var stage: ArenaStage = session.stage
	var tally: MoveTally = stage.arena.move_tally
	var stats: GauntletWaveStats = GauntletWaveStats.new()
	var row: Dictionary = {}
	tally.record(&"before")
	stats.begin(stage)
	stats.finish(stage, row)
	assert_false(row.has("moves"))
	stats.begin(stage)
	tally.record(MoveTable.SHORT_CIRCUIT)
	tally.record(MoveTable.SHORT_CIRCUIT)
	tally.record(&"another_move")
	stats.finish(stage, row)
	var moves: Dictionary = row.get("moves", {})
	assert_eq(moves, {"ohm_short_circuit": 2, "another_move": 1})
	row = {}
	stats.begin(stage)
	stats.finish(stage, row)
	assert_false(row.has("moves"))
	session.close()
