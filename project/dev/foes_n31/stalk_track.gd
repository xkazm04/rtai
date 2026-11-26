class_name StalkTrack
extends RefCounted
## n31 foes: the sticky followed foe and its per-second gait row. The gait is read through get()
## so a build without FoeGait reports mode "none".

var id: int = -1
var _ticks: int = 0
var _fight: int = 0
var _travel: int = 0
var _moved: float = 0.0
var _dist: float = 0.0
var _rounds: int = 0
var _last: Vector2 = Vector2.INF


## Keeps the same foe until it dies, then the nearest alive one of the archetype.
func pick(arena: CombatArena, archetype: StringName) -> Fighter:
	var best: Fighter = null
	var near: float = INF
	for h: Fighter in arena.hostiles:
		if not h.alive() or h.archetype != archetype:
			continue
		if h.id == id:
			return h
		var d: float = h.pos.distance_to(arena.rivet.pos)
		if d < near:
			near = d
			best = h
	if best != null:
		id = best.id
		_last = Vector2.INF
	return best


## Picks the foe (sticky) and, when `count`, adds this tick to the second's row.
func follow(arena: CombatArena, archetype: StringName, count: bool) -> Fighter:
	var foe: Fighter = pick(arena, archetype)
	if foe == null or not count:
		return foe
	var squad: ArenaSquad = arena.squad_ai
	var mind: SquadMind = squad.minds[foe.id] if squad != null and squad.minds.has(foe.id) else null
	note(arena, foe, mind)
	return foe


func note(arena: CombatArena, h: Fighter, mind: SquadMind) -> void:
	_ticks += 1
	_dist += h.pos.distance_to(arena.rivet.pos)
	if _last.is_finite():
		_moved += h.pos.distance_to(_last)
	_last = h.pos
	if mind == null:
		return
	var gait: Variant = mind.agent.get("gait")
	if gait is Object:
		var obj: Object = gait
		if obj.get("mode") == 0:
			_fight += 1
		else:
			_travel += 1
	if mind.agent.shot_tick == arena.tick:
		_rounds += 1


func flush(hz: int) -> Dictionary:
	var n: int = maxi(1, _ticks)
	var mode: String = "none"
	if _fight + _travel > 0:
		mode = "FIGHT" if _fight >= _travel else "TRAVEL"
	var row: Dictionary = {
		"id": id,
		"mode": mode,
		"fight_ticks": _fight,
		"travel_ticks": _travel,
		"speed_mps": snappedf(_moved * hz / n, 0.01),
		"dist_m": snappedf(_dist / n, 0.1),
		"rounds": _rounds,
	}
	_ticks = 0
	_fight = 0
	_travel = 0
	_moved = 0.0
	_dist = 0.0
	_rounds = 0
	return row
