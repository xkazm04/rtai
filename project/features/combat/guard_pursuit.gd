class_name GuardPursuit
extends RefCounted
## A mobile guard's route around static cover. While it has a clear approach its usual
## rifle brain owns movement and attack range. No wall-clock time or randomness enters a chase.

const CHECK_TICKS: int = 15
const REPLAN_M: float = 2.0

var _map: GuardRouteMap
var _ticks: int = 0
var _blocked: bool = false
var _route: PackedVector2Array = PackedVector2Array()
var _next: int = 0
var _goal: Vector2 = Vector2.INF
var _from: Vector2 = Vector2.INF


func _init(map: GuardRouteMap) -> void:
	_map = map


func blocked_goal() -> Vector2:
	return _goal if _blocked else Vector2.INF


## True while rounding cover (or holding at an unreachable target). A locked burst calls
## this only once it finishes, so turning a corner cannot redirect rounds already committed.
func advance(g: Fighter, target: Vector2, speed: float) -> bool:
	if (_ticks + g.id) % CHECK_TICKS == 0:
		_refresh(g, target)
	elif _ticks == 0:
		# Check sight immediately, but give each spawn its own search slot.
		_blocked = not _map.clear_line(g.pos, target)
	_ticks += 1
	if not _blocked:
		return false
	if _next < _route.size():
		var waypoint: Vector2 = _route[_next]
		g.facing = g.pos.direction_to(waypoint)
		g.pos = g.pos.move_toward(waypoint, speed * SimClock.TICK_DT)
		if g.pos == waypoint:
			_next += 1
	return true


func _refresh(g: Fighter, target: Vector2) -> void:
	_blocked = not _map.clear_line(g.pos, target)
	if not _blocked:
		_goal = Vector2.INF
		_route.clear()
		return
	var moved: bool = target.distance_squared_to(_goal) >= REPLAN_M * REPLAN_M
	var stranded: bool = (
		_next >= _route.size() and (g.pos.distance_to(_from) >= REPLAN_M or target != _goal)
	)
	var off_path: bool = _next < _route.size() and not _map.clear_line(g.pos, _route[_next])
	if moved or stranded or off_path:
		_route = _map.route(g.pos, target)
		_next = 0
		_goal = target
		_from = g.pos
