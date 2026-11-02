class_name QuestPlay
extends RefCounted
## One headless play of the `_selftest` fixture on the real World + SimLoop: QuestSystem
## registered with the stub world, the bot acting once per tick, the Events timeline recorded.
## checks() is the spike selftest's verdict, plus the contract events; evidence() is its record.

const MASTER_SEED: int = 20261102
const TIMEOUT_TICKS: int = 120 * SimClock.TICK_RATE

var stub: StubQuestWorld
var system: QuestSystem
var bot: QuestBot
var events: EventLog = EventLog.new()
var report: QuestReport = QuestReport.new()
var pkg: QuestPackage = null
var ticks: int = 0
var final_hash: String = ""
var _world: World = World.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()


## Plays to the end (or the timeout); `answers` false plants the never-answers fault.
static func play(answers: bool) -> QuestPlay:
	var p: QuestPlay = QuestPlay.new()
	p._world.start(p._bus, p._data, MASTER_SEED)
	p.events.attach(p._bus, p._world.context().clock.tick)
	p.stub = StubQuestWorld.new(QuestFixture.places())
	p.system = QuestSystem.new(p.stub)
	p._world.add_system(p.system)
	var loaded: QuestLoader.Result = QuestLoader.load_package(
		QuestFixture.ID, QuestRules.shipped(), QuestFixture.places(), QuestFixture.ROOT
	)
	p.report = loaded.report
	p.pkg = loaded.package
	if p.pkg != null and p.system.offer(p.pkg):
		p.bot = QuestBot.new(p.stub, p.system)
		p.bot.answers = answers
		while not p.bot.done() and p.ticks < TIMEOUT_TICKS:
			p.bot.act()
			p._world.loop().step()
			p.ticks += 1
	p.final_hash = p._world.loop().state_hash()
	p.events.detach()
	return p


func release() -> void:
	_world.free()
	_bus.free()
	_data.free()


func checks() -> Dictionary[String, bool]:
	var runner: QuestRunner = system.runner
	var played: bool = runner != null
	return {
		"loaded": report.ok(),
		"succeeded": played and runner.state == QuestRunner.State.SUCCEEDED,
		"allBeatsReached": played and beats_reached() == pkg.beats.size(),
		"allBeatLinesShown": played and lines_missing().is_empty(),
		"soulBarkFired": shown_ids().has("hauler-bark-1"),
		"heatBarkFired": shown_ids().has("patch-heat-1"),
		"cashPaid": played and stub.cash == pkg.reward_cash,
		"unlocksGranted": played and runner.granted_unlocks == pkg.unlocks,
		"heatClamped": played and runner.heat_clamps >= 1 and stub.wanted <= pkg.heat_peak,
		"contractStartedOnce": _emits("contract_started") == 1,
		"contractCompletedOnce": _emits("contract_completed") == 1,
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


func _emits(signal_name: String) -> int:
	var count: int = 0
	for line: String in events.lines():
		if line.get_slice(" ", 1) == signal_name:
			count += 1
	return count
