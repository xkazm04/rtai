class_name GhostFlight
extends Node2D
## The shadow and tail stay in the ground frame. The optional body mount carries only the art.
## An instance is specific to one rig. Its tuning is shared by all instances of that form.

var hover: GhostHover
var shadow: GhostShadow
var tail: GhostTail
var _mount: Node2D
var _row: GhostHoverRow
var _last: Vector2 = Vector2.INF
var _facing: float = 0.0


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


## Mounting keeps locomotion at a constant point in the body's local frame.
func mount(body: Node2D) -> void:
	_mount = Node2D.new()
	add_child(_mount)
	_mount.add_child(body)


func step(at_px: Vector2, facing: float, ticks: int) -> void:
	if ticks <= 0:
		return
	var start: Vector2 = at_px if _last == Vector2.INF else _last
	var angle: float = facing if _last == Vector2.INF else _facing
	for i: int in range(1, ticks + 1):
		var k: float = float(i) / ticks
		var spot: Vector2 = start.lerp(at_px, k)
		var yaw: float = lerp_angle(angle, facing, k)
		hover.step(spot, yaw, 1)
		var body_yaw: float = yaw + body_rotation()
		var anchor: Vector2 = (_row.tail.anchor_m * SimConst.PX_PER_M).rotated(body_yaw)
		tail.step(spot + hover.lag_px + anchor, body_yaw, hover.speed_mps, hover.lift_m, 1)
	shadow.step(at_px, hover.lift_m)
	_last = at_px
	_facing = facing
	if _mount != null:
		_mount.position = at_px + body_offset()
		_mount.rotation = body_rotation()
		_mount.scale = body_scale()


func body_offset() -> Vector2:
	return hover.lag_px + ViewMode.shared().lift_px(hover.lift_m)


func body_scale() -> Vector2:
	var across: float = cos(hover.bank)
	if ViewMode.shared().is_flat():
		return Vector2(1.0, across) * (1.0 + 0.045 * hover.lift_m)
	return Vector2(across, 1.0)


func body_rotation() -> float:
	return -0.3 * hover.bank
