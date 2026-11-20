class_name GhostFlight
extends Node2D
## The shadow and tail stay in the ground frame. The optional body mount carries only the art.
## An instance is specific to one rig. Its tuning is shared by all instances of that form.

var hover: GhostHover
var shadow: GhostShadow
## Overlay source. Its centreline and half-widths include the ribbon's projected lift.
var tail: GhostTail
var _mount: Node2D
var _row: GhostHoverRow
var _last: Vector2 = Vector2.INF
var _facing: float = 0.0
var _emerge: float = 1.0


static func make(form_id: StringName) -> GhostFlight:
	var row: GhostHoverRow = GhostHoverRow.of(form_id)
	if row == null:
		return null
	var flight: GhostFlight = GhostFlight.new()
	flight._row = row
	flight.hover = GhostHover.new(row)
	flight.shadow = GhostShadow.new(row.shadow)
	flight.tail = GhostTail.new(row.tail)
	flight.add_child(flight.shadow)
	flight.add_child(flight.tail)
	return flight


## Render fraction of the visible half of a transformation. The hover clock keeps running.
func set_emerge(k: float) -> void:
	var amount: float = clampf(k, 0.0, 1.0)
	if amount == _emerge:
		return
	_emerge = amount
	tail.emerge = amount
	shadow.pool_open = amount
	if _last != Vector2.INF:
		_place(_last)


## Mounting keeps locomotion at a constant point in the body's local frame.
func mount(body: Node2D) -> void:
	_mount = Node2D.new()
	add_child(_mount)
	_mount.add_child(body)


## Hidden forms have no ribbon to integrate. On re-entry, discard their old world-space trail.
func step(at_px: Vector2, facing: float, ticks: int) -> void:
	if not visible:
		_last = Vector2.INF
		return
	if _last == Vector2.INF:
		hover.reset(at_px, facing)
		_last = at_px
		_facing = facing
		tail.reset(_anchor(at_px, facing), facing, hover.lift_m)
		_place(at_px)
	if ticks <= 0:
		return
	for i: int in range(1, ticks + 1):
		var k: float = float(i) / ticks
		var spot: Vector2 = _last.lerp(at_px, k)
		var yaw: float = lerp_angle(_facing, facing, k)
		hover.step(spot, yaw, 1)
		var body_yaw: float = yaw + body_rotation()
		tail.step(_anchor(spot, body_yaw), body_yaw, hover.speed_mps, hover.lift_m, 1)
	_last = at_px
	_facing = facing
	_place(at_px)


func _anchor(spot: Vector2, yaw: float) -> Vector2:
	var local_px: Vector2 = _row.tail.anchor_m * SimConst.PX_PER_M * body_scale()
	return spot + hover.lag_px * _emerge + local_px.rotated(yaw)


func _place(at_px: Vector2) -> void:
	shadow.step(at_px, hover.lift_m * _emerge)
	if _mount != null:
		var pose: Transform2D = Transform2D(
			_facing + body_rotation(), body_scale(), 0.0, at_px + body_offset()
		)
		# The rig supplies its own facing. Squash in its facing frame at every compass angle.
		_mount.transform = pose * Transform2D(-_facing, Vector2.ZERO)


func body_offset() -> Vector2:
	return (hover.lag_px + ViewMode.shared().lift_px(hover.lift_m)) * _emerge


func body_scale() -> Vector2:
	var across: float = cos(hover.bank * _emerge)
	if ViewMode.shared().is_flat():
		return Vector2(1.0, across) * (1.0 + 0.045 * hover.lift_m * _emerge)
	return Vector2(across, 1.0)


func body_rotation() -> float:
	return -0.3 * hover.bank * _emerge


func fade_from() -> float:
	return _row.fade_from


func belt_fraction() -> float:
	return _row.belt_width_k


## Align the first strip cross-section with the posed belt, including the sprite's lunge.
func set_belt(world_px: Vector2, width_px: float) -> void:
	if _last == Vector2.INF:
		return
	var yaw: float = _facing + body_rotation()
	var anchor: Vector2 = _anchor(_last, yaw) + ViewMode.shared().lift_px(hover.lift_m * _emerge)
	tail.align_socket(tail.to_local(world_px) - anchor, width_px / absf(tail.global_scale.x))


## Start inside the stern so turning cannot expose a gap ahead of the root. The row controls
## any anchor that the form artist has already placed farther aft.
func set_rig_belt(span_px: float, yaw: float) -> void:
	if _last == Vector2.INF:
		return
	var aft: float = minf(0.0, -span_px * 0.14 - _row.tail.anchor_m.x * SimConst.PX_PER_M)
	var width: float = span_px * maxf(0.36, belt_fraction())
	tail.align_socket(Vector2(aft, 0.0).rotated(yaw), width)
