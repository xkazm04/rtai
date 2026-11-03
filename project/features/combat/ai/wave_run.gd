class_name WaveRun
extends RefCounted
## Runs one difficulty curve of pit waves on an EnemyPit, before each pit.step(): a wave's
## enemies walk in spawn_gap apart, already hunting Rivet (alert for their reaction time);
## when the last of them falls a breather starts, then the next wave. report() holds the numbers
## per wave (time to clear, damage Rivet took, shots and hits) for the difficulty ASK.

enum Phase { BREATHER, SPAWNING, FIGHTING, DONE }

var phase: Phase = Phase.BREATHER
var index: int = -1
## Planted fault (TST-05): the next wave starts the moment this one has spawned (no clear, no
## breather), so waves pile up.
var plant_overlap: bool = false
var _waves: Array[Array] = []
var _ids: Array[String] = []
var _breather: int = 0
var _gap: int = 0
var _pending: Array[Dictionary] = []
var _members: Array[EnemyAgent] = []
var _until: int = 0
var _report: Array[Dictionary] = []
var _start: Dictionary[String, float] = {}
var _max_alive: int = 0


func _init(table: PitWaves, curve: StringName = &"") -> void:
	_waves = table.waves(curve)
	_ids = table.wave_ids(curve)
	_breather = table.breather_ticks
	_gap = table.spawn_gap_ticks


func done() -> bool:
	return phase == Phase.DONE


func report() -> Array[Dictionary]:
	return _report


func step(pit: EnemyPit) -> void:
	_max_alive = maxi(_max_alive, pit.alive())
	match phase:
		Phase.BREATHER:
			if pit.tick >= _until:
				_open(pit)
		Phase.SPAWNING:
			if pit.tick >= _until:
				_spawn_one(pit)
		Phase.FIGHTING:
			if _alive() == 0:
				_close(pit)


func _open(pit: EnemyPit) -> void:
	index += 1
	if index >= _waves.size():
		phase = Phase.DONE
		return
	_pending.assign(_waves[index])
	_members.clear()
	_max_alive = pit.alive()
	for k: String in ["rivet_damage", "shots", "shot_hits", "swings", "swing_hits", "nails"]:
		_start[k] = pit.stats[k]
	_start["tick"] = pit.tick
	phase = Phase.SPAWNING
	_spawn_one(pit)


func _spawn_one(pit: EnemyPit) -> void:
	var s: Dictionary = _pending.pop_front()
	var arch: StringName = s["arch"]
	var at: Vector2 = s["at"]
	var e: EnemyAgent = pit.spawn(arch, at)
	e.last_seen = pit.rivet_pos
	e.enter(EnemyAgent.State.ALERT, e.arch.reaction_ticks)
	e.squad = index
	_members.append(e)
	_until = pit.tick + _gap
	if not _pending.is_empty():
		return
	phase = Phase.FIGHTING
	if plant_overlap:
		_close(pit)
		_until = pit.tick


func _close(pit: EnemyPit) -> void:
	var r: Dictionary = {"wave": _ids[index], "enemies": _members.size()}
	r["start_s"] = snappedf(_start["tick"] * SimClock.TICK_DT, 0.01)
	r["seconds"] = snappedf((pit.tick - int(_start["tick"])) * SimClock.TICK_DT, 0.01)
	for k: String in _start:
		if k != "tick":
			r[k] = pit.stats[k] - _start[k]
	r["max_alive"] = _max_alive
	r["cleared"] = _alive() == 0
	_report.append(r)
	phase = Phase.BREATHER
	_until = pit.tick + _breather


func _alive() -> int:
	var n: int = 0
	for e: EnemyAgent in _members:
		n += 1 if e.alive() else 0
	return n
