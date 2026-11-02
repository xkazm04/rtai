class_name QuestBot
extends QuestDriver
## Plays the `_selftest` fixture headless through the stub world, one action per tick, the way
## the spike's quest_selftest did, but moving instead of teleporting: walk to the ringing phone
## and answer it, wait for each beat's lines, swap to Hauler and back (the soul bark), walk to
## the bay, get into the sedan, take heat 4 (the clamp and the heat bark), drive to the gate.
## `answers` false is the planted fault: the bot never presses interact.

const ARRIVE_M: float = 0.5
const HEAT_FORCED: int = 4

var answers: bool = true
var phase: String = "phone"
var _world: StubQuestWorld
var _system: QuestSystem
var _swapped: bool = false


func _init(world: StubQuestWorld, system: QuestSystem) -> void:
	_world = world
	_system = system


func stubbed() -> Array[String]:
	return [
		"movement: Rivet walks and drives in straight lines on the spike's yard map (no city)",
		"heat: the hit-and-run is the bot setting wanted 4 once (no police feature)",
		"souls: the Hauler swap is the bot setting the stub's soul (no soul feature)",
	]


func done() -> bool:
	return phase == "done"


## One tick of intent, before the sim steps.
func act() -> void:
	var runner: QuestRunner = _system.runner
	match runner.state:
		QuestRunner.State.OFFERED:
			_answer(runner)
		QuestRunner.State.ACTIVE:
			_play(runner)
		QuestRunner.State.SUCCEEDED, QuestRunner.State.FAILED:
			if not runner.lines.busy():
				phase = "done"


func _answer(runner: QuestRunner) -> void:
	_world.move_toward(runner.phone)
	_world.interact = answers and _world.rivet.distance_to(runner.phone) < ARRIVE_M


func _play(runner: QuestRunner) -> void:
	if runner.lines.busy():
		return
	var beat: QuestBeat = runner.current_beat()
	var places: QuestPlaces = _world.places()
	match beat.handler:
		QuestRules.Handler.REACH:
			if beat.id == "the-bay" and not _swapped:
				_swap(runner)
				return
			if _world.in_vehicle() and _world.wanted < HEAT_FORCED and runner.heat_clamps == 0:
				_world.wanted = HEAT_FORCED
				return
			phase = beat.id
			_world.move_toward(places.markers[beat.location].at)
		QuestRules.Handler.ENTER_VEHICLE:
			phase = beat.id
			var car: Vector2 = _world.vehicle_at[beat.target]
			if _world.rivet.distance_to(car) > StubQuestWorld.ENTER_RANGE_M:
				_world.move_toward(car)
			elif not _world.enter(beat.target):
				Log.warn("quest-bot", "the %s is out of reach" % beat.target)


## Hauler takes over until the soul bark has fired, then Rivet takes back.
func _swap(runner: QuestRunner) -> void:
	phase = "swap"
	if _world.soul == "rivet" and runner.lines.armed_barks() == 2:
		_world.soul = "hauler"
	elif _world.soul == "hauler":
		_world.soul = "rivet"
		_swapped = true
