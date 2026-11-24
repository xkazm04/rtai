class_name PressureFates
extends RefCounted
## What became of each rifle round of a 6 m take: turned back, passed through the deflect roll,
## reached Rivet with no deflect at all (and whether the blade was mid-swing then), or missed.
## Dev measurement only: it watches the arena's shot list after each tick.

var returned: int = 0
var passed: int = 0
var unswung_hit: int = 0
var unswung_busy: int = 0
var missed: int = 0
## The first rounds, one line each: order, tick fired, tick in reach, swing index then, fate.
var log: Array[String] = []
var _count: int = 0
var _seen: Dictionary[int, Fate] = {}
var _reach_m: float


func _init(reach_m: float) -> void:
	_reach_m = reach_m


## After the stage stepped. `busy` is whether the blade is in a swing this tick.
func observe(arena: CombatArena, swing_index: int, tick: int) -> void:
	var busy: bool = swing_index != 0
	var live: Dictionary[int, bool] = {}
	for shot: Shot in arena.shots:
		if shot.from_rivet and not _seen.has(shot.get_instance_id()):
			continue
		var key: int = shot.get_instance_id()
		live[key] = true
		if not _seen.has(key):
			var fresh: Fate = Fate.new()
			fresh.order = _count
			fresh.fired_tick = tick
			_count += 1
			_seen[key] = fresh
		var row: Fate = _seen[key]
		row.gap = shot.pos.distance_to(arena.rivet.pos) - arena.rivet.radius_m
		row.stride = shot.vel.length() * SimClock.TICK_DT
		row.back = shot.from_rivet
		row.through = shot.has_meta(PlayerDeflect.PASSED)
		if row.gap <= _reach_m + 2.0 * row.stride:
			if row.reach_tick == 0:
				row.reach_tick = tick
				row.reach_swing = swing_index
			row.busy = row.busy or busy
	for key: int in _seen.keys():
		if not live.has(key):
			_settle(_seen[key])
			@warning_ignore("return_value_discarded")
			_seen.erase(key)


func summary() -> Dictionary:
	return {
		"fate_returned": returned,
		"fate_passed": passed,
		"fate_unswung_hit": unswung_hit,
		"fate_unswung_while_busy": unswung_busy,
		"fate_missed": missed,
	}


func _settle(row: Fate) -> void:
	var fate: String = "missed"
	if row.back:
		returned += 1
		fate = "returned"
	elif row.through:
		passed += 1
		fate = "passed"
	elif row.gap <= 2.0 * row.stride:
		unswung_hit += 1
		unswung_busy += int(row.busy)
		fate = "unswung"
	else:
		missed += 1
	if log.size() < 12:
		log.append(
			(
				"round %d fired %d in reach %d swing %d: %s"
				% [row.order, row.fired_tick, row.reach_tick, row.reach_swing, fate]
			)
		)


class Fate:
	extends RefCounted
	var gap: float = 0.0
	var stride: float = 0.0
	var back: bool = false
	var through: bool = false
	var busy: bool = false
	var order: int = 0
	var fired_tick: int = 0
	var reach_tick: int = 0
	var reach_swing: int = 0
