extends Scenario
## Autosave lane exit: quest 1 plays to beat 4 with its declared autosave points writing the
## two rotating slots through the real Save engine; the world is dropped; load lands on the saved
## state hash (re-simulated, exact or refused) and plays on to the same final hash as an
## uninterrupted run. Then the newest slot is corrupted: the load lands on the older slot's beat
## and tells the player. A valid slot whose hash is tampered is refused (planted fault, TST-05),
## and with both slots bad the quest starts from its start. Leaves autosave-resume.json.

const EVIDENCE_FILE: String = "autosave-resume.json"
const ROOT: String = "user://scenario_autosave"


func run(_tree: SceneTree) -> String:
	SaveKit.wipe(ROOT)
	Save.use_root(ROOT)
	var log: Dictionary = {}
	var failure: String = _play_and_load(log)
	Save.use_root(Save.DEFAULT_ROOT)
	SaveKit.wipe(ROOT)
	if failure != "":
		return failure
	return write_evidence(EVIDENCE_FILE, log)


func _play_and_load(log: Dictionary) -> String:
	var reference: CollectCallPlay = CollectCallPlay.play()
	var session: AutosaveRun = AutosaveRun.play_to("as-b4-dock")
	log["saved"] = session.saved
	if session.saved.keys() != ["as-b2-payphone", "as-b3-toner-room", "as-b4-dock"]:
		return "autosaves fired %s" % [session.saved.keys()]
	var slots: SaveSlots = Save.slots()
	if SaveKit.census(slots.root) != ["auto_a/state.sav", "auto_b/state.sav", "meta.json"]:
		return "files on disk: %s" % [SaveKit.census(slots.root)]
	log["meta"] = Save.read_meta()
	var out: SaveLoader.Outcome = Save.load_latest(AutosaveRun.resume)
	if out.status != SaveLoader.Status.LOADED or out.point != "as-b4-dock":
		return "load 1 landed on %s" % out.point
	var play: CollectCallPlay = out.value
	if (
		play.state_hash() != session.saved["as-b4-dock"]["hash"]
		or play.ticks != session.saved["as-b4-dock"]["tick"]
	):
		return "load 1 did not land on the saved state hash"
	while play.running():
		play.tick_once()
	play.finish()
	log["resumed_final_hash"] = play.final_hash
	log["reference_final_hash"] = reference.final_hash
	var same: bool = play.final_hash == reference.final_hash
	play.release()
	reference.release()
	if not same:
		return "the resumed run ended on another hash than the uninterrupted one"
	return _corruptions(slots, session, log)


func _corruptions(slots: SaveSlots, session: AutosaveRun, log: Dictionary) -> String:
	var newest: int = 0 if slots.read(0).seq() > slots.read(1).seq() else 1
	SaveKit.flip(slots.slot_path(newest), 70)
	var out: SaveLoader.Outcome = Save.load_latest(AutosaveRun.resume)
	log["after_corrupting_newest"] = {"point": out.point, "notice": out.notice}
	if out.point != "as-b3-toner-room" or out.notice == "":
		return "corrupt newest: landed on '%s', notice '%s'" % [out.point, out.notice]
	var play: CollectCallPlay = out.value
	if play.state_hash() != session.saved["as-b3-toner-room"]["hash"]:
		return "fallback did not land on the older slot's hash"
	play.release()
	if not FileAccess.file_exists(slots.slot_path(newest) + ".corrupt"):
		return "the corrupt slot was not quarantined"
	# Planted fault (TST-05): a valid container whose checkpoint hash is wrong must be refused.
	var other: int = 1 - newest
	var env: Dictionary = slots.read(other).envelope.duplicate(true)
	var body: Dictionary = env["body"]
	body["state_hash"] = "f".repeat(64)
	SaveKit.put(slots.slot_path(other), GtsvContainer.encode(env))
	var none: SaveLoader.Outcome = Save.load_latest(AutosaveRun.resume)
	log["tampered_hash_and_other_corrupt"] = {"status": none.status, "notice": none.notice}
	if none.status != SaveLoader.Status.FRESH or Save.take_notice() == "":
		return "a tampered checkpoint (and a corrupt twin) did not start fresh with a notice"
	log["quarantined"] = SaveKit.census(slots.root)
	return ""
