class_name AutosaveRun
extends RefCounted
## Quest 1 played by CollectCallBot with its declared autosave points wired to the real Save
## engine, and the matching resume: re-run a fresh world to the checkpoint's tick and require
## the same state hash (exact or refused). The slice's bound-input session (Quest1Session, branch
## d-slice) has the same accept shape; here the bot is the deterministic driver.

const QUEST: String = "collect-call"

## point -> {tick, hash, beat}, what each autosave carried.
var saved: Dictionary[String, Dictionary] = {}


## Plays until `stop_point` has fired and been written; the world is dropped on return.
static func play_to(stop_point: String) -> AutosaveRun:
	var run: AutosaveRun = AutosaveRun.new()
	var play: CollectCallPlay = CollectCallPlay.begin()
	var ids: Array[String] = []
	for beat: QuestBeat in play.pkg.beats:
		ids.append(beat.id)
	var snap: Callable = run._snapshot.bind(play)
	# Beats are minutes apart in the game; the sim here runs them in microseconds, so each
	# write is waited for (otherwise a pending autosave is rightly replaced by the next one).
	var sink: Callable = func(point: String, body: Dictionary, meta: Dictionary) -> void:
		Save.autosave(point, body, meta)
		Save.flush()
	var saver: QuestAutosaver = QuestAutosaver.new(AutosavePoints.load_file(QUEST), ids, snap, sink)
	while play.running() and not saver.fired.has(stop_point):
		play.tick_once()
		var runner: QuestRunner = play.system.runner
		saver.poll(runner.beat_index, runner.state == QuestRunner.State.SUCCEEDED)
	Save.flush()
	play.release()
	return run


func _snapshot(point: String, play: CollectCallPlay) -> Dictionary:
	var cp: Checkpoint = Checkpoint.new()
	cp.quest = QUEST
	cp.beat = play.system.runner.current_beat().id
	cp.tick = play.ticks
	cp.master_seed = CollectCallPlay.MASTER_SEED
	cp.state_hash = play.state_hash()
	saved[point] = {"tick": cp.tick, "hash": cp.state_hash, "beat": cp.beat}
	return {
		"body": cp.to_dict(), "meta": {"quest": QUEST, "beat": cp.beat, "playtime_s": cp.tick / 60}
	}


## The accept callable for Save.load_latest: a CollectCallPlay at the checkpoint, or null.
static func resume(body: Dictionary) -> Variant:
	var cp: Checkpoint = Checkpoint.from_dict(body)
	if cp == null:
		return null
	var play: CollectCallPlay = CollectCallPlay.begin(cp.master_seed)
	while play.ticks < cp.tick and play.running():
		play.tick_once()
	if play.ticks != cp.tick or play.state_hash() != cp.state_hash:
		play.release()
		return null
	return play
