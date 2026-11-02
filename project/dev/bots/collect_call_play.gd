class_name CollectCallPlay
extends RefCounted
## One headless play of quest 1 (collect-call) on the real World + SimLoop: the stage, then
## the QuestSystem through CollectCallWorld, the bot acting once per tick, the Events timeline
## recorded. The quest opens straight from the factory (no phone): offered, then started.
## Used by the scenario (all at once) and the frame grabber (tick by tick, with a view).

const MASTER_SEED: int = 20261102
const QUEST: String = "collect-call"
const TIMEOUT_TICKS: int = 20 * 60 * SimClock.TICK_RATE

var stage: CollectCallStage
var port: CollectCallWorld
var system: QuestSystem
var bot: CollectCallBot
var events: EventLog = EventLog.new()
var report: QuestReport = QuestReport.new()
var pkg: QuestPackage = null
var ticks: int = 0
var cash_before: int = 0
var final_hash: String = ""
## Beat ids in the order they began.
var beats: Array[String] = []
var _world: World = World.new()
var _bus: EventBus = EventBus.new()
var _data: DataStore = DataStore.new()


## Builds and starts the quest; false (with report) when the package does not load.
static func begin(seed: int = MASTER_SEED) -> CollectCallPlay:
	var p: CollectCallPlay = CollectCallPlay.new()
	p._world.start(p._bus, p._data, seed)
	p.events.attach(p._bus, p._world.context().clock.tick)
	p.stage = CollectCallStage.new(StageLayout.shipped())
	p.port = CollectCallWorld.new(p.stage)
	p.system = QuestSystem.new(p.port)
	p.stage.watch(p.system)
	p._world.add_system(p.stage)
	p._world.add_system(p.system)
	var loaded: QuestLoader.Result = QuestLoader.load_package(
		QUEST, QuestRules.shipped(), p.stage.layout.places
	)
	p.report = loaded.report
	p.pkg = loaded.package
	p.cash_before = p.stage.wallet.cash
	if p.pkg != null and p.system.offer(p.pkg):
		p.system.runner.start()
		p.bot = CollectCallBot.new(p.stage, p.system)
	return p


## `honest` false plants a fault: the bot skips trying the phone while hot; `torches` false
## plants the other: the bot never torches the crates.
static func play(
	honest: bool = true, torches: bool = true, seed: int = MASTER_SEED
) -> CollectCallPlay:
	var p: CollectCallPlay = begin(seed)
	if p.bot != null:
		p.bot.tries_hot_phone = honest
		p.bot.torches = torches
	while p.running():
		p.tick_once()
	p.finish()
	return p


func running() -> bool:
	return bot != null and not bot.done() and ticks < TIMEOUT_TICKS


func tick_once() -> void:
	bot.act()
	_world.loop().step()
	ticks += 1
	var beat: QuestBeat = system.runner.current_beat()
	if beat != null and (beats.is_empty() or beats[-1] != beat.id):
		beats.append(beat.id)


func finish() -> void:
	final_hash = _world.loop().state_hash()
	events.detach()


func release() -> void:
	_world.free()
	_bus.free()
	_data.free()


func shown() -> Array[QuestLinePlayer.Shown]:
	return system.runner.lines.shown if system.runner != null else []
