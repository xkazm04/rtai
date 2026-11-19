class_name VehicleDoorView
extends RefCounted
## The city character pass and the vehicle pass share this view on their actor canvas. Only
## the drawn rig row, its opacity and the car card offset change. No simulation state is written.

## A short step at the door keeps the regular walking cadence, even through the fade.
const WALK_MPS: float = 2.0
const META: StringName = &"vehicle_door_view"
const ACTOR: int = RivetBody.RIVET_ACTOR_ID

var drawn_foot: Vector2
var opacity: float = 1.0
var _car: VehicleBody
var _seated: VehicleBody
var _timed: bool
var _enter: bool
var _began: int
var _from: Vector2
var _last_foot: Vector2
var _nudge: Vector2
var _svc: VehicleService
var _canvas: CanvasLayer
var _rig_for: Callable
var _inside: bool
var _styled: CanvasItem
var _relative: bool


func attach(view: Node, svc: VehicleService) -> void:
	_svc = svc
	_last_foot = svc.world.player_pos()
	@warning_ignore("return_value_discarded")
	view.ready.connect(_mounted.bind(view), CONNECT_ONE_SHOT)


func _mounted(view: Node) -> void:
	_canvas = view.get_parent() as CanvasLayer
	if _canvas != null:
		_canvas.set_meta(META, self)


func detach() -> void:
	if is_instance_valid(_canvas) and _canvas.get_meta(META, null) == self:
		_canvas.remove_meta(META)
	_car = null
	opacity = 1.0
	tint()


## The city offers its next rig row immediately before adding Rivet. During the walk
## supply that row through the normal writer and let the caller skip its stationary foot.
static func on_foot(
	rig_for: Callable, put_row: Callable, row: int, tick: int, standing: bool
) -> bool:
	var host: Node2D = rig_for.get_object() as Node2D
	var canvas: CanvasLayer = host.get_parent() as CanvasLayer
	if canvas == null or not canvas.has_meta(META):
		return standing
	var v: VehicleDoorView = canvas.get_meta(META)
	v._rig_for = rig_for
	v.pose(put_row, row, tick, canvas.get_final_transform())
	return standing and not v.walking()


func pose(put_row: Callable, row: int, tick: int, screen: Transform2D) -> void:
	var d: VehicleDoors = _svc.doors
	if not d.view or (d.car != null and d.sheltered):
		_car = null
		opacity = 1.0
		_nudge = Vector2.ZERO
	elif d.car != null:
		_car = d.car
		_enter = d.entering
		_from = d.origin
		_began = tick - d.elapsed
	elif _timed:
		_car = null  # The last timed step seated him, released him or was interrupted.
	elif _svc.driving != _seated:
		_enter = _svc.driving != null
		_car = _svc.driving if _enter else _seated
		_began = tick
		_from = _last_foot
	_timed = d.car != null
	_seated = _svc.driving
	_last_foot = _svc.world.player_pos()
	var ticks: int = d.enter_ticks if _enter else d.exit_ticks
	if _car == null or tick - _began >= ticks:
		_car = null
		drawn_foot = _last_foot
		opacity = 1.0
		_nudge = Vector2.ZERO
		return
	var u: float = clampf(float(tick - _began) / ticks, 0.0, 1.0)
	_draw_step(put_row, row, u, screen)


func _draw_step(put_row: Callable, row: int, u: float, screen: Transform2D) -> void:
	var d: VehicleDoors = _svc.doors
	var door: Vector2 = VehicleDoorPath.driver_door(_car, d.radius)
	var at: Vector2 = d.foot if _timed else _from.lerp(door, smoothstep(0.0, 0.7, u))
	if not _enter and not _timed:
		at = door.lerp(_last_foot, smoothstep(0.25, 1.0, u))
	var inside: float = smoothstep(0.58, 1.0, u) if _enter else 1.0 - smoothstep(0.0, 0.42, u)
	var prev: Vector2 = drawn_foot
	drawn_foot = at.lerp(_car.pos, inside * 0.72)
	_inside = inside > 0.0
	opacity = minf(1.0, 1.8 * (1.0 - inside))
	var walk: Vector2 = ((drawn_foot - prev) / SimClock.TICK_DT).limit_length(WALK_MPS)
	@warning_ignore("return_value_discarded")
	put_row.call(
		row, ACTOR, BodyPlan.Kind.RIVET, drawn_foot * SimConst.PX_PER_M, walk * SimConst.PX_PER_M
	)
	var side: Vector2 = _car.head.orthogonal()
	var px: float = screen.basis_xform(side).length() * SimConst.PX_PER_M
	_nudge = side * (sin(PI * u) / maxf(px, 0.001))


func walking() -> bool:
	return _car != null


func car_position(b: VehicleBody) -> Vector2:
	return b.pos + _nudge if b == _car else b.pos


## Inside the door, take Rivet out of the actors' +100 z band. His rig's local depth
## levels and parts then sit below even a car card drawn under a nearby pedestrian.
## Restore the original relative depth when the foot clears the sill or the rig returns.
func tint() -> void:
	if _car == null and not is_instance_valid(_styled):
		return
	var rig: CanvasItem = null
	if _car != null and _rig_for.is_valid():
		rig = _rig_for.call(ACTOR)
	if rig != _styled:
		if is_instance_valid(_styled):
			_styled.z_as_relative = _relative
			_styled.modulate.a = 1.0
		_styled = rig
		if rig != null:
			_relative = rig.z_as_relative
	if rig != null:
		rig.z_as_relative = _relative and not _inside
		rig.modulate.a = opacity
