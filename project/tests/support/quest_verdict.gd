class_name QuestVerdict
extends RefCounted
## The shared verdict of a quest scenario: a play passes its checks, a second play is
## bit-identical (state hash and Events timeline), and every planted fault is caught (TST-05).
## evidence() is the scenario's detail file for PoF (gtai.quest-selftest/1 shape; `planted` is
## the first fault, `plantedFaults` all of them).

const SCHEMA: String = "gtai.quest-selftest/1"

var reason: String = ""
var identical: bool = false
var play: QuestRecord
var planted: Array[QuestRecord] = []
var planted_faults: Array[String] = []


## `p_planted[i]` is a play with fault `faults[i]` planted; each must fail a check.
static func judge(
	first: QuestRecord, again: QuestRecord, p_planted: Array[QuestRecord], faults: Array[String]
) -> QuestVerdict:
	var v: QuestVerdict = QuestVerdict.new()
	v.play = first
	v.planted = p_planted
	v.planted_faults = faults
	var failed: String = first.first_failure()
	v.reason = "check %s failed" % failed if failed != "" else ""
	v.identical = (
		first.final_hash == again.final_hash and first.events.lines() == again.events.lines()
	)
	if v.reason == "" and not v.identical:
		v.reason = "a second play diverged (hash or Events timeline)"
	for i: int in p_planted.size():
		if v.reason == "" and p_planted[i].first_failure() == "":
			v.reason = "planted fault (%s) was not caught" % faults[i]
	return v


func evidence(quest_id: String) -> Dictionary:
	var runner: QuestRunner = play.system.runner
	var out: Dictionary = {
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
		"cash": play.cash(),
		"unlocks": runner.granted_unlocks if runner != null else [],
		"heatClamps": runner.heat_clamps if runner != null else 0,
		"timeline": runner.timeline if runner != null else [],
		"events": play.events.lines(),
		"loadErrors": play.report.errors,
		"loadWarnings": play.report.warnings,
		"stateHash": play.final_hash,
		"secondPlayIdentical": identical,
		"planted": _planted(0),
		"plantedFaults": range(planted.size()).map(_planted),
		"world": play.world_doc(),
		"stubbed": play.stubbed(),
		"simStep": "fixed %d Hz ticks" % SimClock.TICK_RATE,
		"engineVersion": Engine.get_version_info()["string"],
	}
	out.merge(play.extra())
	return out


func summary(quest_id: String) -> String:
	var runner: QuestRunner = play.system.runner
	var caught: Array = range(planted.size()).map(
		func(i: int) -> String: return planted[i].first_failure()
	)
	return (
		"quest %s: %s in %d ticks, %d lines shown, cash %d, %d stubbed, planted faults caught by %s"
		% [
			quest_id,
			runner.state_name() if runner != null else "-",
			play.ticks,
			play.shown_ids().size(),
			play.cash(),
			play.stubbed().size(),
			caught,
		]
	)


func _planted(i: int) -> Dictionary:
	return {"fault": planted_faults[i], "caughtBy": planted[i].first_failure()}


static func _shown(runner: QuestRunner) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if runner == null:
		return out
	for s: QuestLinePlayer.Shown in runner.lines.shown:
		out.append(
			{"id": s.line_id, "speaker": s.speaker, "bark": s.bark, "tick": s.tick, "beat": s.beat}
		)
	return out
