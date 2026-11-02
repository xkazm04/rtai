class_name WaveDirector
extends RefCounted
## Escalating waves (quest collect-call b4/b5: 49 enemies in 6 waves, wave 6 the quartermaster
## alone). Waves belong to an encounter (a marker name); start() runs that encounter's waves in
## table order: each spawns its count one per spawn_gap at its spawn points in turn, and the
## next starts wave_gap after the last of the previous one is down. No timer on the player.


class Wave:
	extends RefCounted
	var id: String = ""
	var encounter: String = ""
	var count: int = 0
	var boss: String = ""
	var spawns: Array[String] = []


class Spawn:
	extends RefCounted
	var wave: String = ""
	var point: String = ""
	var boss: String = ""


var waves: Array[Wave] = []
var current: int = -1
var spawned: int = 0
## The wave that began on the last step (the wave-start cue), or -1.
var began: int = -1
var _encounter: String = ""
var _timer: int = 0
var _spawn_gap: int = 36
var _wave_gap: int = 120
var _cleared: Dictionary[String, bool] = {}


func _init(t: DataTable, rows: Array, gaps: Dictionary) -> void:
	_spawn_gap = CombatTuning.ticks(t.num(gaps, "spawn_gap_s"))
	_wave_gap = CombatTuning.ticks(t.num(gaps, "wave_gap_s"))
	for raw: Variant in rows:
		var row: Dictionary = raw if raw is Dictionary else {}
		var w: Wave = Wave.new()
		w.id = t.text(row, "id")
		w.encounter = t.text(row, "encounter")
		w.count = t.integer(row, "count")
		w.boss = str(row.get("boss", ""))
		for p: Variant in t.array(row, "spawns"):
			w.spawns.append(str(p))
		waves.append(w)


func total(encounter: String = "") -> int:
	var n: int = 0
	for w: Wave in waves:
		n += w.count if encounter == "" or w.encounter == encounter else 0
	return n


func start(encounter: String) -> void:
	if _encounter == encounter or _cleared.has(encounter):
		return
	_encounter = encounter
	current = _next_wave(-1)
	spawned = 0
	_timer = 0
	began = current


func running() -> bool:
	return current >= 0


func cleared(encounter: String) -> bool:
	return _cleared.get(encounter, false)


## One tick, given how many hostiles still stand. Returns the spawn due now, or null.
func step(alive: int) -> Spawn:
	began = -1
	if current < 0:
		return null
	var w: Wave = waves[current]
	if spawned < w.count:
		_timer -= 1
		if _timer > 0:
			return null
		_timer = _spawn_gap
		return _spawn(w)
	if alive > 0:
		return null
	_timer -= 1
	if _timer > -_wave_gap:
		return null
	current = _next_wave(current)
	spawned = 0
	_timer = 0
	began = current
	if current < 0:
		_cleared[_encounter] = true
	return null


func _spawn(w: Wave) -> Spawn:
	var s: Spawn = Spawn.new()
	s.wave = w.id
	s.point = w.spawns[spawned % w.spawns.size()]
	s.boss = w.boss
	spawned += 1
	return s


func _next_wave(after: int) -> int:
	for i: int in range(after + 1, waves.size()):
		if waves[i].encounter == _encounter:
			return i
	return -1
