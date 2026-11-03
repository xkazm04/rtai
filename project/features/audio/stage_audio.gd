class_name StageAudio
extends Node
## Quest 1's sound (the stage the bot and the player fight in): the AudioService, the Events hooks,
## the shot feed (a round in CombatArena.shots appears = its weapon's shot; it ends = a wall hit, or
## a body hit when an actor died that frame) and the voice player for the quest's lines. Everything
## reads the stage; nothing is written back.

var service: AudioService
var hooks: AudioHooks = AudioHooks.new()
var voice: QuestVoice = QuestVoice.new()
var _stage: CollectCallStage
var _shots: Dictionary[Shot, Vector2] = {}


## Builds it all under `parent`: `bus` is the EventBus of the play (or the Events autoload).
static func attach(
	parent: Node, stage: CollectCallStage, system: QuestSystem, bus: EventBus, seed_value: int
) -> StageAudio:
	var a: StageAudio = StageAudio.new()
	a._stage = stage
	a.service = AudioService.new(AudioTables.shipped(), seed_value)
	parent.add_child(a)
	a.add_child(a.service)
	var rivet_m: Callable = func() -> Vector2: return stage.arena.rivet.pos
	a.service.listener_fn = rivet_m
	a.add_child(a.hooks)
	a.hooks.attach(a.service, bus, func() -> int: return stage.tick, rivet_m)
	var radio: CarRadio = CarRadio.new()
	a.add_child(radio)
	radio.listen(bus)
	a.add_child(a.voice)
	a.voice.bind(a.service, system)
	return a


func _process(_delta: float) -> void:
	if _stage == null:
		return
	var live: Dictionary[Shot, Vector2] = {}
	for s: Shot in _stage.arena.shots:
		live[s] = s.pos
		if not _shots.has(s):
			@warning_ignore("return_value_discarded")
			service.cue(_shot_cue(s), s.pos, _stage.tick)
	for s: Shot in _shots:
		if not live.has(s):
			var id: StringName = &"hit_flesh" if hooks.kill_pending else &"projectile_end"
			@warning_ignore("return_value_discarded")
			service.cue(id, _shots[s], _stage.tick)
	_shots = live


func _shot_cue(s: Shot) -> StringName:
	return &"shot_gloria" if s.weapon == &"gloria" else &"shot_assault_rifle"
