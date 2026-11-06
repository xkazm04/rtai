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
const CITY_PEDS: int = 300

## Quest 1 plays on the generated city (collect_call_city.json; false = the invented arena the
## bot scenario and its goldens were taken on). Every open/resume/replay of a run uses the same.
static var on_city: bool = true
## d7-calls ghost-powers-5 (owner, 2026-11-05): the story locks each ghost until its act
## (ghost_forms.json `unlock`; quest 1 completes none, so Dent stays locked). false = every
## ghost free (the old default; the game's `--ghosts-free`).
static var ghost_locks: bool = true
## n7-ranged: Rivet's weapon fires as its weapons.json row (StageGuns: Gloria with the table's
## muzzle, casings, cue and feel). false = the evening path (the game's `--quest-guns=off`).
static var table_guns: bool = true
## n7-melee: the blade Rivet carries on quest 1 (melee_weapons.json id, in its carry slot: the
## katana on key 2; a press draws it over the story's gun, a second press puts it away). &"" = no
## blade: Rivet fights with his own claws (the owner's 2026-11-06 call; `--quest-blade=katana`).
static var blade: StringName = &""
## The act quests the story has completed (none before quest 1's own act lands).
static var acts_done: Array[StringName] = []

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
## The quest's autosave points (set a `sink` to turn them on; see Quest1Autosave).
var autosave: Quest1Autosave
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
	if table_guns:
		s.stage.guns = StageGuns.make(s.world.context().rng.stream(&"quest_guns"))
	s._bind_pilot()
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
	var ids: Array[String] = []
	for beat: QuestBeat in loaded.package.beats:
		ids.append(beat.id)
	s.autosave = Quest1Autosave.new(s, ids)
	s.system.runner.start()
	s.cash_before = s.stage.wallet.cash
	s._last_beat = s.beat_id()
	return s


## The player's pilot, with the story's ghost locks and the carried blade (n7-melee, `blade`).
func _bind_pilot() -> void:
	pilot = StagePilot.new(actions)
	stage.pilot = pilot
	if ghost_locks:
		pilot.ghosts.forms.apply_locks(acts_done.duplicate())
	if blade == &"":
		return
	var rng: RandomNumberGenerator = world.context().rng.stream(&"quest_blade")
	var carry: RivetCarry = RivetCarry.new(WeaponTable.shipped(), ArsenalTable.shipped(), rng)
	carry.sheathe = true
	if carry.add(blade) >= 0:
		pilot.carry = carry


## The city after the stage and the quest: its bubble follows Rivet (the stage sets the focus
## each tick), and he collides with its buildings, props and parked cars (StageCells).
func _add_city() -> void:
	city = CitySystem.new(true)
	city.steer_by_input = false
	stage.cells = StageCells.shipped()
	var us: int = stage.cells.prewarm(stage.layout.extent())
	Log.info("quest1", "city cells: %d chunks in %d ms" % [stage.cells.chunk_count(), us / 1000])
	stage.follow = city
	city.focus = stage.layout.rivet_start
	city.target = city.focus
	world.add_system(CityScare.new(stage, city))  # lane human-reactions: the street hears the fight
	world.add_system(city)
	if not stage.layout.ghost_cars.is_empty():  # after the stage, so a seized car moves this tick
		@warning_ignore("return_value_discarded")
		ArenaCars.attach_at(world, stage, stage.layout.ghost_cars)
	# the chunks around Rivet resident before tick 0, so the first frame after Start has a street
	# (live, replay and resume all open here, so the run stays deterministic)
	city.residency.update(city.focus)
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
	return checkpoint(beat)


## The checkpoint at this tick (between ticks): the tape before it and the sim's state hash.
func checkpoint(beat: String) -> Checkpoint:
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
