extends Node
## Samples the same title-menu pilot as newgame_pilot once per simulation tick.

const KNOWN_FLAGS: PackedStringArray = ["--bot", "--result", "--seed"]


func _ready() -> void:
	_measure.call_deferred()


func _measure() -> void:
	var game: Quest1Game = preload("res://boot/quest1.tscn").instantiate()
	game.new_game_path.campaign_menu = true
	game.save_path = ""
	game.settings_path = ""
	add_child(game)
	var drive: PrologueMenuDrive = PrologueMenuDrive.new()
	var issue: String = drive.press(game)
	if not issue.is_empty():
		Log.error("hand_pilot_probe", issue)
		get_tree().quit(1)
		return
	var chapter: PrologueGame = game.new_game_path.prologue
	var row: Dictionary = _play(drive, chapter)
	if row.seed == 1:
		row["rivet_claw_digest"] = _rake_digest()
	var file: FileAccess = FileAccess.open(LaunchArgs.value("--result"), FileAccess.WRITE)
	if file == null or not file.store_line(JSON.stringify(row, "  ")):
		row.outcome = "could not write hand pilot result"
	if row.outcome != "quest1":
		Log.error("hand_pilot_probe", str(row.outcome))
	get_tree().quit(0 if row.outcome == "quest1" else 1)


func _play(drive: PrologueMenuDrive, chapter: PrologueGame) -> Dictionary:
	var issue: String = ""
	var lowest: float = chapter.stage.arena.rivet.hp
	var full: float = chapter.stage.arena.rivet.max_hp
	var spans: Array[Dictionary] = chapter.encounter.spans
	var patrol_ticks: int = 0
	var squad_ticks: int = 0
	while issue.is_empty() and drive.first_line_tick < 0:
		if chapter.encounter.phase == PrologueEncounter.Phase.HANDS:
			patrol_ticks += 1
		if (
			chapter.encounter.phase == PrologueEncounter.Phase.BEAT_TWO
			and chapter.encounter.battle.ranged
		):
			squad_ticks += 1
		issue = drive.step()
		lowest = minf(lowest, chapter.stage.arena.rivet.hp)
	var row: Dictionary = drive.result()
	row.merge({"seed": LaunchArgs.value("--seed").to_int(), "min_hp": lowest, "max_hp": full})
	row["encounters"] = spans
	row["patrol_fight_ticks"] = patrol_ticks
	row["squad_fight_ticks"] = squad_ticks
	row["deaths"] = chapter.encounter.deaths
	row["outcome"] = "quest1" if issue.is_empty() else issue
	return row


## The arena scenario verifies this recording but only exports contact counts.
func _rake_digest() -> String:
	LaunchArgs.parse([])
	var session: ArenaSession = ArenaSession.open(Events, Data)
	var bot: ArenaRivetBot = ArenaRivetBot.new(session.stage, session.actions)
	session.world.loop().set_input(bot)
	session.world.loop().start_recording()
	while session.tick() < 30 * SimClock.TICK_RATE and bot.finished_tick < 0:
		session.step()
	var log: ReplayLog = session.world.loop().finish_recording()
	session.world.free()
	LaunchArgs.parse()
	return log.final_hash
