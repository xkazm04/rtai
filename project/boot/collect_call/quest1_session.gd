class_name Quest1Session
extends RefCounted
## Quest 1 (collect-call) as the player plays it: the real World + SimLoop with the stage, then
## the QuestSystem through CollectCallWorld, exactly as CollectCallPlay composes them, but Rivet
## is driven by StagePilot from the loop's input (LiveInput in the game, a ReplayLog on
## --replay) instead of CollectCallBot. The World node is added to the tree by the caller (the
## game scene); a headless test may call step() itself instead.

const QUEST: String = "collect-call"
const MASTER_SEED: int = 20261102
## The city's crowd around the quest (people only: the stage runs its own police, and no car is
## drivable yet, so no traffic drives through the fight).
const CITY_PEDS: int = 120

## Quest 1 plays on the generated city (collect_call_city.json; false = the invented arena the
## bot scenario and its goldens were taken on). Every open/resume/replay of a run uses the same.
static var on_city: bool = true

var world: World = World.new()
var stage: CollectCallStage
## The streamed city under the quest (null on the invented arena).
var city: CitySystem = null
var port: CollectCallWorld
var system: QuestSystem
var pilot: StagePilot
var live: LiveInput
## What the loop samples: the live input, recorded (and a loaded checkpoint's history first).
var tape: InputTape
var actions: PlayerActions
var report: QuestReport = QuestReport.new()
var cash_before: int = 0
var master_seed: int = MASTER_SEED
var _last_beat: String = ""


## Builds the world and starts the contract; null when the package does not load.
static func open(events: EventBus, data: DataStore, seed: int = MASTER_SEED) -> Quest1Session:
	var s: Quest1Session = Quest1Session.new()
	s.actions = PlayerActions.shipped()
	s.actions.install()
	s.world.name = "Quest1World"
	s.world.start(events, data, seed)
	s.stage = CollectCallStage.new(StageLayout.shipped(on_city))
	s.pilot = StagePilot.new(s.actions)
	s.stage.pilot = s.pilot
	s.port = CollectCallWorld.new(s.stage)
	s.system = QuestSystem.new(s.port)
	s.stage.watch(s.system)
	s.world.add_system(s.stage)
	s.world.add_system(s.system)
	if on_city:
		s._add_city()
	s.master_seed = seed
	s.live = LiveInput.new(s.actions)
	s.tape = InputTape.new(s.live)
	s.world.loop().set_input(s.tape)
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
	s._last_beat = s.beat_id()
	return s


## The city after the stage and the quest: its bubble follows Rivet (the stage sets the focus
## each tick), and he collides with its buildings, props and parked cars (StageCells).
func _add_city() -> void:
	city = CitySystem.new(true)
	city.steer_by_input = false
	stage.cells = StageCells.shipped()
	stage.follow = city
	city.focus = stage.layout.rivet_start
	city.target = city.focus
	world.add_system(city)
	city.spawner.targets = CityTargets.street(CITY_PEDS, 0, 0)


## A session at `cp`: the tape's history re-simulated on a fresh world; null when the state
## there does not hash to the checkpoint's (a stale or tampered save is refused, not loaded).
static func resume(events: EventBus, data: DataStore, cp: Checkpoint) -> Quest1Session:
	var s: Quest1Session = open(events, data, cp.master_seed)
	if s == null:
		return null
	s.tape.preload_history(cp.input_ticks, cp.inputs, cp.tick)
	while s.tick() < cp.tick:
		s.step()
	if s.world.loop().state_hash() != cp.state_hash:
		Log.warn("save", "checkpoint at %s did not re-simulate to its hash" % cp.beat)
		s.world.free()
		return null
	s._last_beat = s.beat_id()
	Log.info("save", "resumed quest 1 at %s (tick %d)" % [cp.beat, cp.tick])
	return s


## A checkpoint when a new beat has begun since the last call (between ticks), else null.
func poll_checkpoint() -> Checkpoint:
	var beat: String = beat_id()
	if beat == _last_beat or state() != QuestRunner.State.ACTIVE:
		return null
	_last_beat = beat
	var cp: Checkpoint = Checkpoint.new()
	cp.quest = QUEST
	cp.beat = beat
	cp.tick = tick()
	cp.master_seed = master_seed
	cp.state_hash = world.loop().state_hash()
	var history: Array[Array] = tape.history_before(cp.tick)
	cp.input_ticks.assign(history[0])
	cp.inputs.assign(history[1])
	return cp


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
