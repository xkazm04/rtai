class_name Quest1Autosave
extends RefCounted
## Quest 1's autosave points on the slice's session (the autosave lane's glue, SAV-08): the points
## quest.json declares plus the quest end fire `sink` (Save.autosave) at their beat edges, with the
## session's checkpoint as the slot body. Call poll() once after each step; with no sink it does
## nothing (tests, the invented arena). `accept()` is the other direction, for Save.load_latest.

var sink: Callable = Callable()
var points: AutosavePoints.Result
var last_beat: String = ""
var _session: Quest1Session
var _saver: QuestAutosaver


func _init(session: Quest1Session, beat_ids: Array[String]) -> void:
	_session = session
	points = AutosavePoints.load_file(Quest1Session.QUEST)
	if not points.ok():
		Log.error("save", "autosavePoints: %s" % [points.errors])
	_saver = QuestAutosaver.new(points, beat_ids, snapshot, _send)


func poll() -> void:
	if not sink.is_valid():
		return
	var runner: QuestRunner = _session.system.runner
	_saver.poll(runner.beat_index, runner.state == QuestRunner.State.SUCCEEDED)


## An autosave outside the quest's declared edges (the quit point, SAV-08): the snapshot of this
## tick goes to the sink at once. False when there is no sink.
func save_now(point: String) -> bool:
	if not sink.is_valid():
		return false
	var snap: Dictionary = snapshot(point)
	var body: Dictionary = snap.get("body", {})
	var meta: Dictionary = snap.get("meta", {})
	_send(point, body, meta)
	return true


## What a slot carries: the checkpoint at this tick plus the meta.json fields.
func snapshot(_point: String) -> Dictionary:
	var beat: String = _session.beat_id()
	last_beat = beat if beat != "" else last_beat
	var cp: Checkpoint = _session.checkpoint(last_beat)
	var seconds: int = cp.tick / SimClock.TICK_RATE
	return {
		"body": cp.to_dict(),
		"meta": {"quest": Quest1Session.QUEST, "beat": last_beat, "playtime_s": seconds},
	}


func _send(point: String, body: Dictionary, meta: Dictionary) -> void:
	sink.call(point, body, meta)


## The Callable for Save.load_latest: a slot body -> the resumed session, or null (refused).
static func accept(events: EventBus, data: DataStore) -> Callable:
	return func(body: Dictionary) -> Variant:
		var cp: Checkpoint = CheckpointSlot.read(body)
		if cp == null or cp.quest != Quest1Session.QUEST:  # another quest's slot is not ours
			return null
		return Quest1Session.resume(events, data, cp)
