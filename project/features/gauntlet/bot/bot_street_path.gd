class_name BotStreetPath
extends RefCounted
## Follow the street's body-clear bends. Give a blocked corner a committed sideways
## step if two seconds of attempted travel have not moved Rivet a quarter metre.

const STUCK_TICKS: int = 2 * SimClock.TICK_RATE
const STEP_TICKS: int = SimClock.TICK_RATE / 2
const PROGRESS_M: float = 0.25

var _anchor: Vector2
var _since: int = 0
var _last: int = -2
var _side: Vector2
var _last_bend: Vector2
var _step_until: int = 0
var _shared: GuardRouteMap
var _wide: GuardRouteMap
var _use_wide: bool = false


## The shared grid admits a guard through the one-metre kiosk gap. Rivet is
## wider. Inflate the solids before rasterizing so A* can exclude that cell.
func clearance(map: GuardRouteMap, boxes: Array[Rect2], radius: float, guard_radius: float) -> void:
	if map == _shared:
		return
	_shared = map
	_wide = null
	_use_wide = false
	if map != null and radius > guard_radius:
		var wider: Array[Rect2] = []
		for box: Rect2 in boxes:
			wider.append(box.grow(radius - guard_radius))
		_wide = GuardRouteMap.new(map.region(), wider, null, guard_radius)


func toward(map: GuardRouteMap, at: Vector2, goal: Vector2, tick: int) -> Vector2:
	if map == null:
		return at.direction_to(goal)
	if tick > _last + 1 or at.distance_to(_anchor) >= PROGRESS_M:
		_anchor = at
		_since = tick
	if tick > _last + 1:
		_step_until = tick
	_last = tick
	if tick < _step_until:
		return _side
	var stuck: bool = tick - _since >= STUCK_TICKS
	if stuck and _wide != null:
		_use_wide = true
	if _use_wide:
		map = _wide
	var direct: Vector2 = at.direction_to(goal)
	if stuck or not map.clear_line(at, goal):
		for corner: Vector2 in map.route(at, goal):
			if at.distance_to(corner) > 0.15:
				var bend: Vector2 = at.direction_to(corner)
				if not stuck or (bend.dot(direct) < 0.9 and bend.dot(_last_bend) < 0.9):
					_last_bend = bend
					if stuck:
						_since = tick
					return bend
				break
	if stuck:
		_since = tick
		_step_until = tick + STEP_TICKS
		var side: Vector2 = direct.orthogonal()
		if side.y * at.y > 0.0:
			side = -side
		_side = side if map.clear_line(at, at + side) else -side
		return _side
	return direct
