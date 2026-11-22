extends GutTest

const ENTRY: PackedScene = preload("res://boot/prologue/prologue.tscn")


func after_each() -> void:
	LaunchArgs.parse()
	PlayerActions.shipped().install()


func _open() -> PrologueGame:
	var game: PrologueGame = ENTRY.instantiate() as PrologueGame
	add_child_autofree(game)
	game.world.set_process(false)
	return game


func test_invalid_seed_and_result_path_are_rejected_before_starting_the_world() -> void:
	var game: PrologueGame = PrologueGame.new()
	@warning_ignore("return_value_discarded")
	autofree(game)
	for flags: PackedStringArray in [
		PackedStringArray(["--seed"]),
		PackedStringArray(["--seed=eleven"]),
		PackedStringArray(["--result"]),
		PackedStringArray(["--result=relative.json"])
	]:
		LaunchArgs.parse(flags)
		assert_ne(game._read_args(), "", str(flags))
	LaunchArgs.parse([])
	assert_eq(game._read_args(), "")
	assert_null(game.world)


func test_entry_installs_the_unskipped_pilot_and_saves_its_active_checkpoint_on_exit() -> void:
	var path: String = TestTmp.dir("prologue_game").path_join("nested/run.json")
	LaunchArgs.parse(["--bot", "--seed=23", "--result=" + ProjectSettings.globalize_path(path)])
	var game: PrologueGame = _open()
	var world: World = game.world
	game.boot()
	assert_same(game.world, world, "Booting an active game preserves the run")
	assert_eq(game.world.context().rng.master_seed(), 23)
	var first_tick: int = game.lines.events.front()["tick"]
	assert_eq(first_tick, 0)
	assert_eq(game.lines.current, "b1_l01_warden_three_down")
	for i: int in 3000:
		game.world.loop().step()
		if game.encounter.phase == PrologueEncounter.Phase.HANDS:
			break
	assert_eq(game.encounter.phase, PrologueEncounter.Phase.HANDS)
	for event: Dictionary in game.lines.events:
		var skipped: bool = event.get("skipped", false)
		assert_false(skipped, str(event["id"]))
	var stage: ArenaStage = game.stage
	assert_true(game.encounter in stage.hooks)
	remove_child(game)
	assert_true(stage.hooks.is_empty(), "Exiting releases the active encounter and corpse hooks")
	assert_true(FileAccess.file_exists(path))
	var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var seed_value: float = saved["seed"]
	var ticks: float = saved["ticks"]
	var ended: bool = saved["ended"]
	assert_eq(str(saved["schema"]), "gtai.prologue-run/1")
	assert_eq(roundi(seed_value), 23)
	assert_eq(roundi(ticks), world.context().clock.tick())
	assert_eq(str(saved["beat_checkpoints"][-1]["id"]), "dale_patrol")
	assert_false(ended)


func test_live_entry_forwards_devices_and_keeps_the_end_card_on_screen() -> void:
	LaunchArgs.parse([])
	var game: PrologueGame = _open()
	assert_eq(game.world.context().rng.master_seed(), World.DEFAULT_SEED)
	game._input(InputEventJoypadButton.new())
	assert_true(game.live.pad_last)
	game._input(InputEventMouseButton.new())
	assert_false(game.live.pad_last)
	game.world.set_process(true)
	game.encounter.finished.emit()
	assert_false(game.world.is_processing())


func test_play_view_follows_the_active_rivet_and_reads_the_encounters_dialogue() -> void:
	var game: PrologueGame = _open()
	game._open_view(game.stage.plan as PrologueYard)
	var view: PrologueView
	for child: Node in game.get_children():
		if child is PrologueView:
			view = child as PrologueView
	assert_not_null(view)
	if view == null:
		return
	assert_same(view.encounter, game.encounter)
	assert_same(view.hud_feed, game.lines)
	assert_true(view.stage_view is PrologueFloor)
	assert_same((view.stage_view as PrologueFloor).plan, game.stage.plan)
	assert_same(game.live.viewport, game.get_viewport())
	assert_eq(game.live.origin_px, view.rivet_screen)
	var scale_px: float = game.live.px_per_m.call()
	assert_eq(scale_px, 32.0)
	var command_view: PrologueCommandView
	for child: Node in view.print_stage.actor_layer().get_children():
		if child is PrologueCommandView:
			command_view = child as PrologueCommandView
	assert_not_null(command_view, "The commander's order and exposure cues attach to the play view")
