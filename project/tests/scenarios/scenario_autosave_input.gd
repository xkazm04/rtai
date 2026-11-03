extends Scenario
## The autosave lane's exit, on the slice's real path: quest 1 (boot/quest1.tscn) is played through
## the bound input only (CollectCallInputDriver -> InputMap -> LiveInput -> StagePilot) with its
## declared autosave points writing the two rotating slots through the real Save engine. At beat 4
## world dropped; Continue's loader (Quest1Autosave.accept) re-simulates the tape, lands on
## the saved tick and state hash. The newest slot is then flipped: the loader quarantines it, lands
## on the older slot's beat and says so. Leaves autosave-input.json. (The driver's own state is not
## in a save, so no claim is made that a resumed run ends on the uninterrupted run's hash; the load
## itself is exact or refused.)

const EVIDENCE_FILE: String = "autosave-input.json"
const ROOT: String = "user://scenario_autosave_input"
const STOP_POINT: String = "as-b4-dock"
const TIMEOUT_TICKS: int = 25 * 60 * SimClock.TICK_RATE


func run(tree: SceneTree) -> String:
	SaveKit.wipe(ROOT)
	Save.use_root(ROOT)
	var log: Dictionary = {}
	var failure: String = _run(tree, log)
	Save.use_root(Save.DEFAULT_ROOT)
	SaveKit.wipe(ROOT)
	return failure if failure != "" else write_evidence(EVIDENCE_FILE, log)


func _run(tree: SceneTree, log: Dictionary) -> String:
	var game: Quest1Game = (load("res://boot/quest1.tscn") as PackedScene).instantiate()
	game.settings_path = ""
	tree.root.add_child(game)
	game.boot()
	game.card.start_pressed.emit()
	var s: Quest1Session = game.session
	if s == null:
		game.free()
		return "the Start button did not open quest 1"
	s.world.set_process(false)
	var saved: Dictionary[String, Dictionary] = {}
	var failure: String = _play(s, saved)
	log["saved"] = saved
	if failure == "":
		failure = _resume(game, saved, log)
	game.free()
	return failure


## Plays through the input path until `STOP_POINT` fired, waiting for each write to land.
func _play(s: Quest1Session, saved: Dictionary[String, Dictionary]) -> String:
	var driver: CollectCallInputDriver = CollectCallInputDriver.new(s.stage, s.system)
	s.autosave.sink = func(point: String, body: Dictionary, meta: Dictionary) -> void:
		saved[point] = {"tick": body["tick"], "hash": body["state_hash"], "beat": body["beat"]}
		Save.autosave(point, body, meta)
		Save.flush()
	while not saved.has(STOP_POINT) and s.tick() < TIMEOUT_TICKS and not driver.done():
		driver.act()
		s.step()
		s.autosave.poll()
	driver.release()
	if saved.keys() != ["as-b2-payphone", "as-b3-toner-room", STOP_POINT]:
		return "autosaves fired %s" % [saved.keys()]
	return ""


func _resume(game: Quest1Game, saved: Dictionary[String, Dictionary], log: Dictionary) -> String:
	game.session.world.free()
	game.session = null
	var slots: SaveSlots = Save.slots()
	var census: Array[String] = SaveKit.census(slots.root)
	if census != ["auto_a/state.sav", "auto_b/state.sav", "meta.json"]:
		return "files on disk: %s" % [census]
	var out: SaveLoader.Outcome = Save.load_latest(Quest1Autosave.accept(Events, Data))
	var s: Quest1Session = out.value if out.status == SaveLoader.Status.LOADED else null
	if s == null or out.point != STOP_POINT:
		return "load 1 landed on '%s'" % out.point
	var want: Dictionary = saved[STOP_POINT]
	if s.world.loop().state_hash() != want["hash"] or s.tick() != want["tick"]:
		return "load 1 did not land on the saved tick and hash"
	log["load_1"] = {"point": out.point, "beat": s.beat_id(), "tick": s.tick()}
	s.world.free()
	var newest: int = 0 if slots.read(0).seq() > slots.read(1).seq() else 1
	SaveKit.flip(slots.slot_path(newest), 70)
	out = Save.load_latest(Quest1Autosave.accept(Events, Data))
	s = out.value if out.status == SaveLoader.Status.LOADED else null
	log["load_2_after_corrupting_newest"] = {"point": out.point, "notice": out.notice}
	if s == null or out.point != "as-b3-toner-room" or out.notice == "":
		return "corrupt newest: landed on '%s', notice '%s'" % [out.point, out.notice]
	if s.world.loop().state_hash() != saved["as-b3-toner-room"]["hash"]:
		return "the fallback did not land on the older slot's hash"
	log["load_2"] = {"beat": s.beat_id(), "tick": s.tick()}
	s.world.free()
	return ""
