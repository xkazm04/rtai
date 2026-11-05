class_name StageAudio
extends Node
## Quest 1's sound (the stage the bot and the player fight in): the AudioService, the Events hooks,
## the shot feed (a round in CombatArena.shots appears = its weapon's shot; it ends = a wall hit, or
## a body hit when an actor died that frame) and the voice player for the quest's lines. Everything
## reads the stage; nothing is written back.

## The riot's night-city bed is the quest stage's too, a little lower (a dock, not a crossing).
const STAGE_BED_TRIM_DB: float = -3.0

var service: AudioService
var hooks: AudioHooks = AudioHooks.new()
var voice: QuestVoice = QuestVoice.new()
## n7-melee: the melee and ghost hits' own sounds (null under `--hit-cues=off`).
var hit_cues: HitCues = null
## n7-ranged: a weapons row's end_cue plays where its round ends (`--end-cue=off` = the before).
var end_cues: bool = not OS.get_cmdline_user_args().has("--end-cue=off")
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
	a.hooks.rivet_id = stage.arena.rivet.id
	a.hooks.attach(a.service, bus, func() -> int: return stage.tick, rivet_m)
	a.service.loops.set_on(&"city_ambience", true, STAGE_BED_TRIM_DB)
	if HitCues.enabled():
		a.hit_cues = HitCues.attach(stage.arena, a.service.tables.hits, a.service.cue)
	var radio: CarRadio = CarRadio.new()
	a.add_child(radio)
	radio.listen(bus)
	a.add_child(a.voice)
	a.voice.bind(a.service, system)
	return a


func _process(_delta: float) -> void:
	if _stage == null:
		return
	_end_boss_loop()
	var gun: GunHand = _stage.arena.gun
	if gun != null and gun.trigger.charge == 1:  # a charge gun starts charging (lane gunplay)
		@warning_ignore("return_value_discarded")
		service.cue(&"tazer_charge", _stage.arena.rivet.pos, _stage.tick)
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
			if end_cues and s.spec != null and s.spec.end_cue != &"":
				@warning_ignore("return_value_discarded")
				service.cue(s.spec.end_cue, _shots[s], _stage.tick)
	_shots = live


## The boss loop plays while Mertz stands: it ends when he goes down (not only with the contract).
func _end_boss_loop() -> void:
	var boss: Fighter = _stage.arena.boss
	if boss != null and not boss.alive() and service.loops.is_on(&"boss_loop"):
		service.loops.set_on(&"boss_loop", false)


func _shot_cue(s: Shot) -> StringName:
	if s.spec != null and s.spec.shot_cue != &"":  # a table gun's own (lane gunplay)
		return s.spec.shot_cue
	return &"shot_gloria" if s.weapon == &"gloria" else &"shot_assault_rifle"
