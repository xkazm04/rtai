class_name QuestPlay
extends QuestRecord
## One headless play of a quest package on the real World + SimLoop with the stub world:
## QuestSystem registered with StubQuestWorld, a QuestDriver acting once per tick (the player and
## every system that does not exist yet, each one named in stubbed()), the Events timeline
## recorded. checks() is the shared contract verdict plus the heat clamp.

const MASTER_SEED: int = 20261102

var stub: StubQuestWorld
var driver: QuestDriver = null
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


func release() -> void:
	_world.free()
	_bus.free()
	_data.free()


func checks() -> Dictionary[String, bool]:
	var out: Dictionary[String, bool] = contract_checks()
	var runner: QuestRunner = system.runner
	out["heatClamped"] = (
		runner != null and runner.heat_clamps >= 1 and stub.wanted <= pkg.heat_peak
	)
	return out


func cash() -> int:
	return stub.cash


func stubbed() -> Array[String]:
	return driver.stubbed() if driver != null else []


func world_doc() -> String:
	return "tests/support/stub_quest_world.gd (stub; the city is integrated later)"
