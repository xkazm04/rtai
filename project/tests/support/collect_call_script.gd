class_name CollectCallScript
extends QuestDriver
## Plays collect-call headless through the stub world, beat by beat, from a cue list. Rivet's
## own moves (walking, pressing interact) are scripted input; every world system the contract
## needs that does not exist yet is a scripted stand-in that speaks through the real Events bus,
## and stubbed() names each one. `torches` false is the planted fault: the crates never burn.

const DOCK: String = "Dock 9 bonded storage"
const VAULT: String = "Dock 9 vault cage"
const ARRIVE_M: float = 0.5
const START_HEAT: int = 2
## Ticks between scripted contractor kills (0.5 s) and per heat level lost lying low (2 s).
const KILL_EVERY: int = 30
const DRAIN_EVERY: int = 120
## Contractors per wave: 48 in five waves; Mertz is the sixth wave (difficulty 49 / 6).
const WAVES: Array[int] = [8, 9, 10, 10, 11]
const FIRST_VICTIM_ID: int = 100
const MERTZ_ID: int = 900
## Per beat id, its cues in order: [kind] or [kind, arg].
const SCRIPT: Dictionary[String, Array] = {
	"b1-dumpster": [["idle"], ["whisper"], ["idle"], ["drain"]],
	"b2-payphone": [["walk_phone", "Factory Row corner"], ["press"]],
	"b3-toner-room": [["walk", "The Toner Room"], ["whisper"]],
	"b4-dock":
	[
		["equip", "gloria"],
		["walk", DOCK],
		["heat", 3],
		["wave", 1],
		["wave", 2],
		["heat", 4],
		["wave", 3],
		["wave", 4],
		["wave", 5],
		["clear", DOCK],
	],
	"b5-quartermaster":
	[
		["walk", VAULT],
		["boss"],
		["idle"],
		["telegraph"],
		["idle"],
		["hit"],
		["idle"],
		["kill_boss"],
		["clear", VAULT],
		["idle"],
		["torch"],
	],
	"b6-hot-walk": [["drain"], ["walk_phone", "Harbor Road"], ["press"]],
}

var torches: bool = true
var _world: StubQuestWorld
var _system: QuestSystem
var _bus: EventBus
var _beat: int = -1
var _cue: int = 0
var _cue_ticks: int = 0
var _victims: int = 0


func _init(world: StubQuestWorld, system: QuestSystem, bus: EventBus) -> void:
	_world = world
	_system = system
	_bus = bus


func stubbed() -> Array[String]:
	return [
		(
			"heat (police): starts at 2 as the factory left it, drains one level per 2 s lying low, "
			+ "rises to 3 at Dock 9 (and a 4 the quest clamps); every change is Events.wanted_changed"
		),
		"payphones: a payphone is the place's `phone` point; answering is a scripted interact",
		"madness: whisper bursts are scripted Events.whispers_spiked (b1, b3, the tazer hit, the fire)",
		(
			"combat (Dock 9): 5 scripted waves (Events.wave_started) of 8/9/10/10/11 contractors, one "
			+ "downed every 0.5 s by scripted fire (Events.actor_killed, killer Rivet, kind shot)"
		),
		(
			"boss (Mertz): scripted Events.boss_engaged, attack_telegraphed and player_hit "
			+ "(robo-tazer), then one kill; no damage model, Rivet never dies"
		),
		"weapon: Brass's Gloria handover is the stub equipping `gloria` as the dock beat starts",
		"torch: the sabotage is a scripted interact at the vault marker",
		(
			"movement: Rivet walks in straight lines on a stub map "
			+ "(tests/support/quests/collect_call_places.json); no city, collisions or vehicles"
		),
		(
			"narrative-only: Juno's repair, the Toner Room safehouse and the payout under the phone "
			+ "are lines, not simulated"
		),
	]


func prepare() -> void:
	_world.rivet = _world.places().markers["Factory Row alleys"].at
	_world.set_wanted(START_HEAT)


func done() -> bool:
	var runner: QuestRunner = _system.runner
	var over: bool = runner.state in [QuestRunner.State.SUCCEEDED, QuestRunner.State.FAILED]
	return over and not runner.lines.busy()


func act() -> void:
	var runner: QuestRunner = _system.runner
	if runner.state != QuestRunner.State.ACTIVE:
		return
	if runner.beat_index != _beat:
		_beat = runner.beat_index
		_cue = 0
		_cue_ticks = 0
	var cues: Array = SCRIPT[runner.current_beat().id]
	if _cue >= cues.size():
		return
	var cue: Array = cues[_cue]
	if CollectCallCues.run(self, cue, _cue_ticks):
		_cue += 1
		_cue_ticks = 0
	else:
		_cue_ticks += 1


func stub_world() -> StubQuestWorld:
	return _world


func event_bus() -> EventBus:
	return _bus


func quest_runner() -> QuestRunner:
	return _system.runner


## The next scripted contractor's runtime id.
func next_victim() -> int:
	_victims += 1
	return FIRST_VICTIM_ID + _victims
