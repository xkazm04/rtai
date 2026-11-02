class_name CollectCallChecks
extends RefCounted
## Quest 1's own checks of one real play (CollectCallRecord adds them to the contract checks):
## the beats in order, every line once, Patch refusing a hot caller, the heat peak, 49 enemies,
## the rifle, the Robo-tazer, the fire and +$1,500 through the wallet exactly once.

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
		"rifleGrabbed": arena.rifles_grabbed >= 1,
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
