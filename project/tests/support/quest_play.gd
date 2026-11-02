class_name QuestPlay
extends RefCounted
## One headless play of a quest package on the real World + SimLoop: QuestSystem registered
## with the stub world, a QuestDriver acting once per tick (the player and every system that
## does not exist yet, each one named in stubbed()), the Events timeline recorded. checks() is
## the verdict (every beat, line and bark, the reward, the clamp, one start and one completion).

const MASTER_SEED: int = 20261102

var stub: StubQuestWorld
var system: QuestSystem
var driver: QuestDriver = null
var events: EventLog = EventLog.new()
var report: QuestReport = QuestReport.new()
var pkg: QuestPackage = null
var ticks: int = 0
var final_hash: String = ""
var _world: World = World.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()


## Plays `loaded` to the driver's end or `timeout_ticks`. make_driver(stub, system, bus) builds
## the QuestDriver; it is prepared before the offer.
static func play(
	loaded: QuestLoader.Result, places: QuestPlaces, make_driver: Callable, timeout_ticks: int
) -> QuestPlay:
	var p: QuestPlay = QuestPlay.new()
	p._world.start(p._bus, p._data, MASTER_SEED)
	p.events.attach(p._bus, p._world.context().clock.tick)
	p.stub = StubQuestWorld.new(places)
	p.stub.events = p._bus
	p.system = QuestSystem.new(p.stub)
	p._world.add_system(p.system)
	p.report = loaded.report
	p.pkg = loaded.package
	if p.pkg != null:
		p.driver = make_driver.call(p.stub, p.system, p._bus)
		p.driver.prepare()
		if p.system.offer(p.pkg):
			while not p.driver.done() and p.ticks < timeout_ticks:
				p.driver.act()
				p._world.loop().step()
				p.ticks += 1
	p.final_hash = p._world.loop().state_hash()
	p.events.detach()
	return p


## The `_selftest` fixture played by QuestBot; `answers` false plants the never-answers fault.
static func selftest(answers: bool) -> QuestPlay:
	var loaded: QuestLoader.Result = QuestLoader.load_package(
		QuestFixture.ID, QuestRules.shipped(), QuestFixture.places(), QuestFixture.ROOT
	)
	var make: Callable = func(w: StubQuestWorld, s: QuestSystem, _b: EventBus) -> QuestDriver:
		var bot: QuestBot = QuestBot.new(w, s)
		bot.answers = answers
		return bot
	return play(loaded, QuestFixture.places(), make, 120 * SimClock.TICK_RATE)


## The shipped collect-call package played by CollectCallScript; `torches` false plants the
## crates-never-burn fault.
static func collect_call(torches: bool) -> QuestPlay:
	var make: Callable = func(w: StubQuestWorld, s: QuestSystem, b: EventBus) -> QuestDriver:
		var script: CollectCallScript = CollectCallScript.new(w, s, b)
		script.torches = torches
		return script
	return play(
		QuestFixture.cc_load(), QuestFixture.cc_places(), make, 15 * 60 * SimClock.TICK_RATE
	)


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
		"allBarksFired": played and barks_missing().is_empty(),
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


func barks_missing() -> Array[String]:
	var missing: Array[String] = []
	for bark: QuestLine in pkg.barks():
		if not shown_ids().has(bark.id):
			missing.append(bark.id)
	return missing


func _emits(signal_name: String) -> int:
	var count: int = 0
	for line: String in events.lines():
		if line.get_slice(" ", 1) == signal_name:
			count += 1
	return count
