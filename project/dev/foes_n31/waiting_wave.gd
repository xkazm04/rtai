extends RefCounted
## n31 foes: one gauntlet wave's waiting counters, per archetype (read-only tallies, no sim state).

const Engaged = preload("res://dev/foes_n31/waiting_engaged.gd")


class Kind:
	extends RefCounted
	var melee: bool = false
	var attack_m: float = 0.0
	var n: int = 0
	var react_s: Array[float] = []
	var react_any_s: Array[float] = []
	var fired_before_clear: int = 0
	var never_fired: int = 0
	var never_fired_clear: int = 0
	var never_fired_clear_in: int = 0
	var rounds: int = 0
	var shot_dist_m: Array[float] = []
	var clear_ticks: int = 0
	var clear_idle_ticks: int = 0
	var clear_in_ticks: int = 0
	var clear_in_idle_ticks: int = 0
	## Clear-line ticks not engaged (waiting_engaged.gd); the *_idle_* ones are the strict rule.
	var clear_loose_ticks: int = 0
	var clear_in_loose_ticks: int = 0
	var token_ticks: int = 0
	var alive_ticks: int = 0
	var idle_speed_sum: float = 0.0

	func to_dict() -> Dictionary:
		var dt: float = SimClock.TICK_DT
		return {
			"melee": melee,
			"attack_m": attack_m,
			"n": n,
			"react_s": react_s,
			"react_any_s": react_any_s,
			"fired_before_clear": fired_before_clear,
			"never_fired": never_fired,
			"never_fired_clear": never_fired_clear,
			"never_fired_clear_in": never_fired_clear_in,
			"rounds": rounds,
			"shot_dist_m": shot_dist_m,
			"clear_s": r2(clear_ticks * dt),
			"clear_idle_s": r2(clear_idle_ticks * dt),
			"clear_in_s": r2(clear_in_ticks * dt),
			"clear_in_idle_s": r2(clear_in_idle_ticks * dt),
			"clear_unengaged_s": r2(clear_loose_ticks * dt),
			"clear_in_unengaged_s": r2(clear_in_loose_ticks * dt),
			"token_s": r2(token_ticks * dt),
			"alive_s": r2(alive_ticks * dt),
			"idle_speed_mps": r2(idle_speed_sum / maxi(clear_idle_ticks, 1)),
		}

	static func r2(x: float) -> float:
		return roundf(x * 100.0) / 100.0


var n: int = 0
var start_tick: int = -1
var last_tick: int = -1
var shots_begin: int = 0
var shots_end: int = -1
var kinds: Dictionary[StringName, Kind] = {}
## Second of wave time -> ids of ranged members that fired in it.
var _fired: Dictionary[int, Dictionary] = {}
var _ranged_alive_ticks: int = 0
var _ticks: int = 0
## Ticks with >= 3 ranged alive, and those of them that pressed (waiting_engaged.gd).
var _press_eligible: int = 0
var _press: int = 0
var _open: bool = false


func kind(id: StringName) -> Kind:
	if not kinds.has(id):
		kinds[id] = Kind.new()
	return kinds[id]


func note_fired(tick: int, foe_id: int) -> void:
	var second: int = floori((tick - start_tick) * SimClock.TICK_DT)
	if not _fired.has(second):
		_fired[second] = {}
	_fired[second][foe_id] = true


## Called once per tick for every wave that has spawned. `alive` counts its living members.
func close_tick(tick: int, alive: int, ranged_alive: int, shots_fired: int) -> void:
	if alive > 0:
		_open = true
		last_tick = tick
		_ticks += 1
		_ranged_alive_ticks += ranged_alive
	elif _open:
		_open = false
		shots_end = shots_fired


func close_press(alive: int, ranged_alive: int, pushing: int) -> void:
	if alive <= 0 or ranged_alive < Engaged.PRESS_MIN:
		return
	_press_eligible += 1
	_press += int(Engaged.pressing(ranged_alive, pushing))


func finish(shots_fired: int) -> void:
	if _open or shots_end < 0:
		shots_end = shots_fired


func to_dict(row: Dictionary, death_wave: int) -> Dictionary:
	var seconds: int = ceili((last_tick - start_tick + 1) * SimClock.TICK_DT)
	var firing: Array[int] = []
	for s: int in range(maxi(seconds, 0)):
		firing.append(_fired[s].size() if _fired.has(s) else 0)
	var by_kind: Dictionary = {}
	for id: StringName in kinds:
		by_kind[String(id)] = kinds[id].to_dict()
	return {
		"n": n,
		"seconds": row.get("seconds", -1.0),
		"observed_s": Kind.r2((last_tick - start_tick + 1) * SimClock.TICK_DT),
		"damage_taken": row.get("damage_taken", 0.0),
		"died": death_wave == n,
		"shots_result": row.get("shots", -1),
		"shots_probe": shots_end - shots_begin,
		"firing_per_s": firing,
		"ranged_alive_mean": Kind.r2(float(_ranged_alive_ticks) / maxi(_ticks, 1)),
		"press_eligible_s": Kind.r2(_press_eligible * SimClock.TICK_DT),
		"press_s": Kind.r2(_press * SimClock.TICK_DT),
		"archetypes": by_kind,
	}
