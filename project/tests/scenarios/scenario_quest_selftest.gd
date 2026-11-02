extends Scenario
## F-12 exit: a gtai.quest/1 fixture (the spike's `_selftest`) plays headless to completion on
## the real World + SimLoop through the quest runtime, against a stub world (no city yet). Every
## beat, every beat line and both barks, the heat clamp, the cash and unlocks, and exactly one
## contract_started / contract_completed. A second play is bit-identical (state hash and Events
## timeline), and the planted fault (the phone is never answered) is caught (TST-05).
## Leaves quest-selftest.json in --evidence-dir for PoF.

const EVIDENCE_FILE: String = "quest-selftest.json"
const EVIDENCE_SCHEMA: String = "gtai.quest-selftest/1"


func run(_tree: SceneTree) -> String:
	var first: QuestPlay = QuestPlay.play(true)
	var again: QuestPlay = QuestPlay.play(true)
	var planted: QuestPlay = QuestPlay.play(false)
	var reason: String = first.first_failure()
	reason = "check %s failed" % reason if reason != "" else ""
	var identical: bool = (
		first.final_hash == again.final_hash and first.events.lines() == again.events.lines()
	)
	if reason == "" and not identical:
		reason = "a second play diverged (hash or Events timeline)"
	var caught: bool = planted.first_failure() != ""
	if reason == "" and not caught:
		reason = "planted fault (phone never answered) was not caught"
	var write_error: String = write_evidence(
		EVIDENCE_FILE, _evidence(first, reason, identical, planted)
	)
	if reason == "":
		reason = write_error
	Log.info("scenario", _summary(first, planted))
	for p: QuestPlay in [first, again, planted]:
		p.release()
	return reason


func _evidence(p: QuestPlay, reason: String, identical: bool, planted: QuestPlay) -> Dictionary:
	var runner: QuestRunner = p.system.runner
	return {
		"schema": EVIDENCE_SCHEMA,
		"pass": reason == "",
		"problem": reason,
		"quest": QuestFixture.ID,
		"checks": p.checks(),
		"finalState": runner.state_name() if runner != null else "not offered",
		"ticks": p.ticks,
		"beatsReached": p.beats_reached(),
		"linesShown": _shown(runner),
		"linesMissing": p.lines_missing(),
		"cash": p.stub.cash,
		"unlocks": runner.granted_unlocks if runner != null else [],
		"heatClamps": runner.heat_clamps if runner != null else 0,
		"timeline": runner.timeline if runner != null else [],
		"events": p.events.lines(),
		"loadErrors": p.report.errors,
		"loadWarnings": p.report.warnings,
		"stateHash": p.final_hash,
		"secondPlayIdentical": identical,
		"planted": {"fault": "phone never answered", "caughtBy": planted.first_failure()},
		"world": "tests/support/stub_quest_world.gd (stub; the city is integrated later)",
		"simStep": "fixed %d Hz ticks" % SimClock.TICK_RATE,
		"engineVersion": Engine.get_version_info()["string"],
	}


func _shown(runner: QuestRunner) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if runner == null:
		return out
	for s: QuestLinePlayer.Shown in runner.lines.shown:
		out.append(
			{"id": s.line_id, "speaker": s.speaker, "bark": s.bark, "tick": s.tick, "beat": s.beat}
		)
	return out


func _summary(p: QuestPlay, planted: QuestPlay) -> String:
	return (
		"quest selftest: %s in %d ticks, %d lines shown, cash %d, planted fault caught by %s"
		% [
			p.system.runner.state_name() if p.system.runner != null else "-",
			p.ticks,
			p.shown_ids().size(),
			p.stub.cash,
			planted.first_failure(),
		]
	)
