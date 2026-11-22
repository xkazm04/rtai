class_name PrologueEncounter
extends ArenaHook
## Runs after combat and reads the interact edge StagePilot decoded for this tick.

signal finished
signal opening_restarted(tick: int)

enum Phase { TALK, HANDS, BEAT_TWO }

var lines: PrologueLines
var patrol: ProloguePatrol
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
var _next_line: String
var _next_checkpoint: String


func _init(feed: PrologueLines, stage: ArenaStage, data: DataTable) -> void:
	lines = feed
	patrol = ProloguePatrol.new(stage, data)
	var beats: Array = data.array(data.raw, "beats")
	var first: Dictionary = beats[0]
	_talk_checkpoint = data.text(first, "checkpoint")
	_last_line = data.text(first, "last_line")
	var second: Dictionary = beats[1]
	_next_line = data.text(second, "first_line")
	_next_checkpoint = data.text(second, "checkpoint")
	_wave_checkpoint = data.text(data.object(data.raw, "arrival"), "checkpoint")
	patrol.place(stage.arena, false)
	_start(_talk_checkpoint, 1, 0)


func step(stage: ArenaStage, tick: int) -> void:
	if stage.deaths != deaths:
		_restart(stage, tick)
		return
	if not stage.arena.rivet.alive() or phase == Phase.BEAT_TWO:
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
	prompts.clear()
	_end(tick, "dale_down")
	phase = Phase.HANDS
	_start(_wave_checkpoint, 1, tick)
	patrol.panic(stage.arena)


func _fight(stage: ArenaStage, tick: int) -> void:
	if patrol.cleared():
		_end(tick, "cleared")
		done_tick = tick
		phase = Phase.BEAT_TWO
		prompts.clear()
		stage.arena.shots.clear()
		_start(_next_checkpoint, 2, tick)
		@warning_ignore("return_value_discarded")
		lines.show_line(_next_line, tick)
		finished.emit()
		return
	if patrol.squad.shot_tick == tick:
		prompts.offer("guard", tick)
	for officer: ProloguePatrol.Officer in patrol.officers:
		if officer.body.alive() and officer.body.swing_tick == tick:
			prompts.offer("claw", tick)
	for shot: Shot in stage.arena.shots:
		var to_player: Vector2 = stage.arena.rivet.pos - shot.pos
		if not shot.from_rivet and to_player.dot(shot.vel) > 0.0 and to_player.length() < 5.0:
			prompts.offer("roll", tick)
	prompts.step(tick)


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
	patrol.place(arena, wave)
	prompts.clear()
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
