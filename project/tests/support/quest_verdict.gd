class_name QuestVerdict
extends RefCounted
## The shared verdict of a quest scenario: a play passes its checks, a second play is
## bit-identical (state hash and Events timeline), and a planted fault is caught (TST-05).
## evidence() is the scenario's detail file for PoF (gtai.quest-selftest/1 shape).

const SCHEMA: String = "gtai.quest-selftest/1"

var reason: String = ""
var identical: bool = false
var play: QuestPlay
var planted: QuestPlay
var planted_fault: String = ""


static func judge(
	first: QuestPlay, again: QuestPlay, p_planted: QuestPlay, fault: String
) -> QuestVerdict:
	var v: QuestVerdict = QuestVerdict.new()
	v.play = first
	v.planted = p_planted
	v.planted_fault = fault
	var failed: String = first.first_failure()
	v.reason = "check %s failed" % failed if failed != "" else ""
	v.identical = (
		first.final_hash == again.final_hash and first.events.lines() == again.events.lines()
	)
	if v.reason == "" and not v.identical:
		v.reason = "a second play diverged (hash or Events timeline)"
	if v.reason == "" and p_planted.first_failure() == "":
		v.reason = "planted fault (%s) was not caught" % fault
	return v


func evidence(quest_id: String) -> Dictionary:
	var runner: QuestRunner = play.system.runner
	return {
		"schema": SCHEMA,
		"pass": reason == "",
		"problem": reason,
		"quest": quest_id,
		"checks": play.checks(),
		"finalState": runner.state_name() if runner != null else "not offered",
		"ticks": play.ticks,
		"beatsReached": play.beats_reached(),
		"linesShown": _shown(runner),
		"linesMissing": play.lines_missing(),
		"barksMissing": play.barks_missing(),
		"cash": play.stub.cash,
		"unlocks": runner.granted_unlocks if runner != null else [],
		"heatClamps": runner.heat_clamps if runner != null else 0,
		"timeline": runner.timeline if runner != null else [],
		"events": play.events.lines(),
		"loadErrors": play.report.errors,
		"loadWarnings": play.report.warnings,
		"stateHash": play.final_hash,
		"secondPlayIdentical": identical,
		"planted": {"fault": planted_fault, "caughtBy": planted.first_failure()},
		"world": "tests/support/stub_quest_world.gd (stub; the city is integrated later)",
		"stubbed": play.driver.stubbed() if play.driver != null else [],
		"simStep": "fixed %d Hz ticks" % SimClock.TICK_RATE,
		"engineVersion": Engine.get_version_info()["string"],
	}


func summary(quest_id: String) -> String:
	var runner: QuestRunner = play.system.runner
	return (
		"quest %s: %s in %d ticks, %d lines shown, cash %d, planted fault caught by %s"
		% [
			quest_id,
			runner.state_name() if runner != null else "-",
			play.ticks,
			play.shown_ids().size(),
			play.stub.cash,
			planted.first_failure(),
		]
	)


static func _shown(runner: QuestRunner) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if runner == null:
		return out
	for s: QuestLinePlayer.Shown in runner.lines.shown:
		out.append(
			{"id": s.line_id, "speaker": s.speaker, "bark": s.bark, "tick": s.tick, "beat": s.beat}
		)
	return out
