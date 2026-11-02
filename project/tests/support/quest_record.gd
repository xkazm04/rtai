@abstract class_name QuestRecord
extends RefCounted
## One played contract as a quest scenario judges it (QuestVerdict): the runtime, the Events
## timeline, the load report and the final state hash, whatever world it played on. QuestPlay
## plays on the stub world; CollectCallRecord wraps quest 1's real stage play. contract_checks()
## are the checks every play shares (every beat, line and bark, the reward, one start and one
## completion); checks() adds the play's own.

var system: QuestSystem
var events: EventLog = EventLog.new()
var report: QuestReport = QuestReport.new()
var pkg: QuestPackage = null
var ticks: int = 0
var final_hash: String = ""

## The verdict's checks, in order (the first failing one names a caught fault).
@abstract func checks() -> Dictionary[String, bool]

## Cash the contract paid into the world.
@abstract func cash() -> int

## What the play stands in for, one line per stubbed system (scenario evidence).
@abstract func stubbed() -> Array[String]

## The world the play ran on (scenario evidence).
@abstract func world_doc() -> String

@abstract func release() -> void


## Play-specific evidence fields, merged into the scenario's detail file.
func extra() -> Dictionary:
	return {}


func contract_checks() -> Dictionary[String, bool]:
	var runner: QuestRunner = system.runner
	var played: bool = runner != null
	return {
		"loaded": report.ok(),
		"succeeded": played and runner.state == QuestRunner.State.SUCCEEDED,
		"allBeatsReached": played and beats_reached() == pkg.beats.size(),
		"allBeatLinesShown": played and lines_missing().is_empty(),
		"allBarksFired": played and barks_missing().is_empty(),
		"cashPaid": played and cash() == pkg.reward_cash,
		"unlocksGranted": played and runner.granted_unlocks == pkg.unlocks,
		"contractStartedOnce": emits("contract_started") == 1,
		"contractCompletedOnce": emits("contract_completed") == 1,
	}


## The first failing check's name, or "".
func first_failure() -> String:
	var all: Dictionary[String, bool] = checks()
	for name: String in all:
		if not all[name]:
			return name
	return ""


func beats_reached() -> int:
	var begun: int = 0
	for line: String in system.runner.timeline:
		if line.get_slice(" ", 1) == "beat" and line.ends_with(")"):
			begun += 1
	return begun


func shown_ids() -> Array[String]:
	var ids: Array[String] = []
	if system.runner != null:
		for s: QuestLinePlayer.Shown in system.runner.lines.shown:
			ids.append(s.line_id)
	return ids


func lines_missing() -> Array[String]:
	var missing: Array[String] = []
	for beat: QuestBeat in pkg.beats:
		for line_id: String in beat.line_ids:
			if not pkg.line(line_id).is_bark() and not shown_ids().has(line_id):
				missing.append(line_id)
	return missing


func barks_missing() -> Array[String]:
	var missing: Array[String] = []
	for bark: QuestLine in pkg.barks():
		if not shown_ids().has(bark.id):
			missing.append(bark.id)
	return missing


## How many times `signal_name` went out on the bus during the play.
func emits(signal_name: String) -> int:
	var count: int = 0
	for line: String in events.lines():
		if line.get_slice(" ", 1) == signal_name:
			count += 1
	return count
