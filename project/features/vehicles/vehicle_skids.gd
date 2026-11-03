class_name VehicleSkids
extends Node2D
## Tyre marks under the service cars (render only, VehicleView's child): while a car slides above
## MIN_V (a drift or a handbrake turn), each rear wheel lays an ink dash from where it last
## stamped to where it is now (at least STEP_M apart). The marks live in a ring of CAP dashes;
## the oldest fade out as new ones land, so no frame delta or clock is read and nothing goes back
## to the sim. Drawn in the shadow ink, under the cars and their shadows.

const CAP: int = 480
const MIN_V: float = 4.0
const STEP_M: float = 0.35
const REAR_M: float = 1.45
const TRACK_M: float = 0.8
const WIDTH_PX: float = 5.0
const INK: Color = Color(0.09, 0.075, 0.106, 0.62)

var service: VehicleService = null
## Dashes as from / to pairs in world px, a ring of CAP; _head is the next slot to write.
var _from: PackedVector2Array = PackedVector2Array()
var _to: PackedVector2Array = PackedVector2Array()
var _head: int = 0
var _count: int = 0
## Per car id: the two rear wheels' last stamped points (world px), while it keeps sliding.
var _last: Dictionary[int, PackedVector2Array] = {}


func _init() -> void:
	@warning_ignore("return_value_discarded")
	_from.resize(CAP)
	@warning_ignore("return_value_discarded")
	_to.resize(CAP)


## Dashes laid so far (evidence and tests).
func dashes() -> int:
	return _count


func _process(_delta: float) -> void:
	if service == null:
		return
	var changed: bool = false
	for b: VehicleBody in service.cars:
		changed = _track(b) or changed
	if changed:
		queue_redraw()


func _track(b: VehicleBody) -> bool:
	if not b.sliding or b.speed() < MIN_V or b.state == VehicleBody.State.WRECK:
		@warning_ignore("return_value_discarded")
		_last.erase(b.id)
		return false
	var right: Vector2 = Vector2(-b.head.y, b.head.x)
	var rear: Vector2 = b.pos - b.head * REAR_M
	var now: PackedVector2Array = PackedVector2Array(
		[(rear + right * TRACK_M) * SimConst.PX_PER_M, (rear - right * TRACK_M) * SimConst.PX_PER_M]
	)
	var was: PackedVector2Array = _last.get(b.id, PackedVector2Array())
	if was.is_empty():
		_last[b.id] = now
		return false
	if was[0].distance_to(now[0]) < STEP_M * SimConst.PX_PER_M:
		return false
	for w: int in 2:
		_from[_head] = was[w]
		_to[_head] = now[w]
		_head = (_head + 1) % CAP
		_count += 1
	_last[b.id] = now
	return true


func _draw() -> void:
	var n: int = mini(_count, CAP)
	for k: int in n:
		var i: int = (_head - n + k + CAP) % CAP
		var c: Color = INK
		c.a *= float(k + 1) / float(n) if n == CAP else 1.0
		draw_line(_from[i], _to[i], c, WIDTH_PX)
