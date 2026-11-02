class_name CollectCallChecks
extends RefCounted
## The verdict and the evidence record of one quest 1 play (scenario_collect_call).

const BEATS: Array[String] = [
	"b1-dumpster", "b2-payphone", "b3-toner-room", "b4-dock", "b5-quartermaster", "b6-hot-walk"
]


static func of(p: CollectCallPlay) -> Dictionary[String, bool]:
	var runner: QuestRunner = p.system.runner
	var played: bool = runner != null
	var arena: CombatArena = p.stage.arena
	return {
		"loaded": p.report.ok(),
		"succeeded": played and runner.state == QuestRunner.State.SUCCEEDED,
		"beatsInOrder": p.beats == BEATS,
		"allLinesShown": played and missing(p).is_empty(),
		"everyLineOnce": played and p.shown().size() == p.pkg.lines.size(),
		"patchRefusedHot": p.stage.router.refusals >= 1,
		"heatPeakedAt3": _max_wanted(p) == 3,
		"enemies49": arena.hostiles.size() == 49 and arena.kills == 49,
		"robotazerHit": arena.tazer_hits >= 1 and arena.rivet.alive(),
		"robotazerShorted": arena.tazer != null and arena.tazer.state == RoboTazer.State.SHORTED,
		"cratesBurning": p.stage.crates_burning,
		"paid1500Once":
		p.stage.wallet.cash - p.cash_before == 1500 and _emits(p, "cash_changed") == 1,
		"contractStartedOnce": _emits(p, "contract_started") == 1,
		"contractCompletedOnce": _emits(p, "contract_completed") == 1,
	}


static func missing(p: CollectCallPlay) -> Array[String]:
	var ids: Array[String] = []
	for s: QuestLinePlayer.Shown in p.shown():
		ids.append(s.line_id)
	var out: Array[String] = []
	for line_id: String in p.pkg.line_order:
		if not ids.has(line_id):
			out.append(line_id)
	return out


static func evidence(p: CollectCallPlay, checks: Dictionary, reason: String) -> Dictionary:
	var runner: QuestRunner = p.system.runner
	var lines: Array[Dictionary] = []
	for s: QuestLinePlayer.Shown in p.shown():
		lines.append(
			{"id": s.line_id, "speaker": s.speaker, "bark": s.bark, "tick": s.tick, "beat": s.beat}
		)
	return {
		"pass": reason == "",
		"problem": reason,
		"quest": CollectCallPlay.QUEST,
		"state": runner.state_name() if runner != null else "not offered",
		"checks": checks,
		"beats": p.beats,
		"ticks": p.ticks,
		"linesShown": lines,
		"linesMissing": missing(p),
		"cashBefore": p.cash_before,
		"cashAfter": p.stage.wallet.cash,
		"patchRefusals": p.stage.router.refusals,
		"kills": p.stage.arena.kills,
		"tazerHits": p.stage.arena.tazer_hits,
		"deaths": p.stage.deaths,
		"timeline": runner.timeline if runner != null else [],
		"events": p.events.lines(),
		"loadErrors": p.report.errors,
		"loadWarnings": p.report.warnings,
		"stateHash": p.final_hash,
		"simStep": "fixed %d Hz ticks" % SimClock.TICK_RATE,
		"engineVersion": Engine.get_version_info()["string"],
	}


static func summary(p: CollectCallPlay) -> String:
	return (
		"collect-call: %s in %d ticks, beats %s, %d lines, cash %d -> %d"
		% [
			p.system.runner.state_name() if p.system.runner != null else "-",
			p.ticks,
			p.beats,
			p.shown().size(),
			p.cash_before,
			p.stage.wallet.cash,
		]
	)


static func _max_wanted(p: CollectCallPlay) -> int:
	var top: int = 0
	for line: String in p.events.lines():
		if line.get_slice(" ", 1) == "wanted_changed":
			top = maxi(top, line.get_slice(" ", 2).trim_prefix("[").trim_suffix("]").to_int())
	return top


static func _emits(p: CollectCallPlay, signal_name: String) -> int:
	var n: int = 0
	for line: String in p.events.lines():
		n += 1 if line.get_slice(" ", 1) == signal_name else 0
	return n
