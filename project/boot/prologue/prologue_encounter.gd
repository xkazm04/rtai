class_name PrologueEncounter
extends ArenaHook
## Runs after combat and reads the interact edge StagePilot decoded for this tick.

signal finished
signal end_card_reached
signal opening_restarted(tick: int)

enum Phase { TALK, HANDS, BEAT_TWO, STREET }

var lines: PrologueLines
var patrol: ProloguePatrol
var battle: PrologueBattle
var street: PrologueStreet
var wave_one: Dictionary = {}
var prompts: ProloguePrompts = ProloguePrompts.new()
var phase: Phase = Phase.TALK
var spans: Array[Dictionary] = []
var dale_died: int = -1
var deaths: int = 0
var done_tick: int = -1
var strike_ready: bool = false
var _talk_checkpoint: String
var _wave_checkpoint: String
var _last_line: String
var _next_checkpoint: String
var _street_checkpoint: String


func _init(feed: PrologueLines, stage: ArenaStage, data: DataTable) -> void:
	lines = feed
	patrol = ProloguePatrol.new(stage, data)
	battle = PrologueBattle.new(stage.plan as PrologueYard, data, feed, prompts)
	var beats: Array = data.array(data.raw, "beats")
	var first: Dictionary = beats[0]
	_talk_checkpoint = data.text(first, "checkpoint")
	_last_line = data.text(first, "last_line")
	var second: Dictionary = beats[1]
	_next_checkpoint = data.text(second, "checkpoint")
	var third: Dictionary = beats[2]
	_street_checkpoint = data.text(third, "checkpoint")
	street = PrologueStreet.new(feed, data.text(data.object(data.raw, "payphone"), "id"))
	_wave_checkpoint = data.text(data.object(data.raw, "arrival"), "checkpoint")
	patrol.place(stage.arena, false)
	_start(_talk_checkpoint, 1, 0)


func step(stage: ArenaStage, tick: int) -> void:
	prompts.step(tick)
	if stage.deaths != deaths:
		_restart(stage, tick)
		return
	if not stage.arena.rivet.alive():
		return
	if phase == Phase.STREET:
		street.step(stage as PrologueStage, tick)
		if street.end_tick == tick:
			_end(tick, "ended")
			end_card_reached.emit()
		elif street.end_tick >= 0 and tick == street.end_tick + PrologueStreet.END_TICKS:
			finished.emit()
		return
	if phase == Phase.BEAT_TWO:
		if battle.step(stage, tick):
			_end(tick, "cleared")
			phase = Phase.STREET
			(stage.plan as PrologueYard).exit_open = true
			_start(_street_checkpoint, 3, tick)
			street.enter(stage as PrologueStage, tick)
		return
	if phase == Phase.TALK:
		if not patrol.dale.alive():
			_begin_wave(stage, tick)
			return
		lines.advance(tick, stage.press_left)
		patrol.direct(stage.arena, lines.current)
		if lines.current == _last_line:
			strike_ready = true
			prompts.offer("strike", tick)
	else:
		_fight(stage, tick)


func _begin_wave(stage: ArenaStage, tick: int) -> void:
	dale_died = tick
	lines.interrupt(tick)
	prompts.clear(tick)
	_end(tick, "dale_down")
	phase = Phase.HANDS
	_start(_wave_checkpoint, 1, tick)
	patrol.panic(stage.arena)


func _fight(stage: ArenaStage, tick: int) -> void:
	if patrol.cleared():
		_end(tick, "cleared")
		done_tick = tick
		phase = Phase.BEAT_TWO
		prompts.clear(tick)
		stage.arena.shots.clear()
		_start(_next_checkpoint, 2, tick)
		wave_one = wave_one_result(stage)
		battle.enter(stage, patrol, tick)
		return
	if patrol.squad.shot_tick == tick:
		prompts.offer("guard", tick)
	for officer: ProloguePatrol.Officer in patrol.officers:
		if officer.body.alive() and officer.body.swing_tick == tick:
			prompts.offer("claw", tick)
	for shot: Shot in stage.arena.shots:
		var to_player: Vector2 = stage.arena.rivet.pos - shot.pos
		if not shot.from_rivet and to_player.dot(shot.vel) > 0.0 and to_player.length() < 5.0:
			prompts.offer("roll", tick, (stage.arena as PrologueCombat).first_catch_tick)


func wave_one_result(stage: ArenaStage) -> Dictionary:
	return {
		"spawned": patrol.officers.size(),
		"standing": stage.arena.hostiles_alive(),
		"pistol_rounds": patrol.squad.pistol_rounds,
		"first_catch_tick": (stage.arena as PrologueCombat).first_catch_tick,
		"player_shots": stage.shots_fired,
		"wheel": stage.pilot.wheel.order(),
	}


func _start(id: String, beat: int, tick: int) -> void:
	spans.append({"id": id, "beat": beat, "start_tick": tick})


func _end(tick: int, reason: String) -> void:
	spans.back()["end_tick"] = tick
	spans.back()["end_reason"] = reason


func _restart(stage: ArenaStage, tick: int) -> void:
	deaths = stage.deaths
	_end(tick, "death")
	var wave: bool = phase == Phase.HANDS
	var arena: CombatArena = stage.arena
	arena.shots.clear()
	arena.balls.clear()
	arena.rifle_drops.clear()
	arena.areas = null
	arena.rivet = Fighter.make(Fighter.Kind.RIVET, 0, stage.plan.rivet_start, arena.rivet.max_hp)
	arena.rivet.radius_m = arena.tuning.rivet["radius_m"]
	stage.pilot.motion = PlayerMotion.shipped()
	stage.pilot.melee = PlayerMelee.new()
	stage.pilot.shock = PlayerShock.shipped()
	stage.pilot.guard = PlayerGuard.new()
	arena.guard = stage.pilot.guard
	if phase == Phase.STREET:
		arena.rivet.pos = (stage.plan as PrologueYard).gate
		street.enter(stage as PrologueStage, tick)
		_start(_street_checkpoint, 3, tick)
		return
	if phase == Phase.BEAT_TWO:
		prompts.clear(tick)
		_start(_next_checkpoint, 2, tick)
		battle.enter(stage, patrol, tick)
		return
	patrol.place(arena, wave)
	prompts.clear(tick)
	if wave:
		arena.rivet.pos = patrol.wave_start
		_start(_wave_checkpoint, 1, tick)
	else:
		strike_ready = false
		lines.interrupt(tick)
		@warning_ignore("return_value_discarded")
		lines.begin(1, tick)
		_start(_talk_checkpoint, 1, tick)
		opening_restarted.emit(tick)
