class_name Quest1Session
extends RefCounted
## Quest 1 (collect-call) as the player plays it: the real World + SimLoop with the stage, then
## the QuestSystem through CollectCallWorld, exactly as CollectCallPlay composes them, but Rivet
## is driven by StagePilot from the loop's input (LiveInput in the game, a ReplayLog on
## --replay) instead of CollectCallBot. The World node is added to the tree by the caller (the
## game scene); a headless test may call step() itself instead.

const QUEST: String = "collect-call"
const MASTER_SEED: int = 20261102

var world: World = World.new()
var stage: CollectCallStage
var port: CollectCallWorld
var system: QuestSystem
var pilot: StagePilot
var live: LiveInput
var actions: PlayerActions
var report: QuestReport = QuestReport.new()
var cash_before: int = 0
var deaths_seen: int = 0


## Builds the world and starts the contract; null when the package does not load.
static func open(events: EventBus, data: DataStore, seed: int = MASTER_SEED) -> Quest1Session:
	var s: Quest1Session = Quest1Session.new()
	s.actions = PlayerActions.shipped()
	s.actions.install()
	s.world.name = "Quest1World"
	s.world.start(events, data, seed)
	s.stage = CollectCallStage.new(StageLayout.shipped())
	s.pilot = StagePilot.new(s.actions)
	s.stage.pilot = s.pilot
	s.port = CollectCallWorld.new(s.stage)
	s.system = QuestSystem.new(s.port)
	s.stage.watch(s.system)
	s.world.add_system(s.stage)
	s.world.add_system(s.system)
	s.live = LiveInput.new(s.actions)
	s.world.loop().set_input(s.live)
	var loaded: QuestLoader.Result = QuestLoader.load_package(
		QUEST, QuestRules.shipped(), s.stage.layout.places
	)
	s.report = loaded.report
	if loaded.package == null or not s.system.offer(loaded.package):
		Log.error("quest1", "collect-call did not load: %s" % [s.report])
		s.world.free()
		return null
	s.system.runner.start()
	s.cash_before = s.stage.wallet.cash
	return s


## One fixed tick (headless tests; the game lets World._process step on the frame delta).
func step() -> void:
	world.loop().step()


func tick() -> int:
	return world.context().clock.tick()


func state() -> QuestRunner.State:
	return system.runner.state


## Paid: the contract succeeded and the payout is in the wallet.
func paid() -> bool:
	return state() == QuestRunner.State.SUCCEEDED and stage.wallet.cash > cash_before


func failed() -> bool:
	return state() == QuestRunner.State.FAILED


func beat_id() -> String:
	var beat: QuestBeat = system.runner.current_beat()
	return beat.id if beat != null else ""
