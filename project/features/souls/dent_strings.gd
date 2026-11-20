class_name DentStrings
extends RefCounted
## Two independent roof lines per hand. All points are in the tether canvas's pixel space.

# Inset the cabin from the parked card footprint (which includes bumpers, hood and mirrors).
const CABIN: Vector2 = Vector2(0.36, 0.55)
const ROLL_M: float = 0.15
const HIT_TICKS: int = 8
const CORE_M: float = 1.0 / 32.0
const INK_M: float = 1.5 / 32.0

var strap: DentStrap
var left_px: Vector2
var turn: float
var _tilt: bool
var _lift: Vector2
var _hit_tick: int = -HIT_TICKS
var _strikes: int = 0


func _init(tether: DentStrap) -> void:
	strap = tether


func place(left: Vector2, steer: float, strikes: int, vm: ViewMode) -> void:
	if strap.held:
		left_px = left
		turn = steer
		if strikes > _strikes:
			_hit_tick = strap.tick
	_strikes = strikes
	_tilt = vm.cards
	_lift = vm.lift_px(ROLL_M) * strap.ppm / SimConst.PX_PER_M


## Left rear, left front, right rear, right front. Positive local y is the car's right.
func corner(i: int) -> Vector2:
	var side: float = -1.0 if i < 2 else 1.0
	var half_m: Vector2 = VehicleBody.PARKED_HALF * CABIN
	var inset: float = maxf(0.0, side * turn) if _tilt else 0.0
	var offset: Vector2 = Vector2(half_m.x if i % 2 else -half_m.x, side * half_m.y)
	offset = offset.move_toward(Vector2.ZERO, ROLL_M * inset)
	return strap.roof_px + offset.rotated(strap.heading) * strap.ppm + _lift * inset


func path(i: int) -> PackedVector2Array:
	var hand: Vector2 = left_px if i < 2 else strap.hand_px
	var end: Vector2 = corner(i)
	var sag: float = 0.0
	var down: Vector2 = Vector2.DOWN
	var shake: float = 0.0
	if not strap.held:
		sag = (
			strap.look.strap_sag_m
			* clampf(float(strap.tick - strap.release_tick) / DentStrap.SLACK_TICKS, 0.0, 1.0)
		)
	else:
		# Pay out the outside pair while the inside is reeled taut. For a shallow bow its
		# excess arc length grows as sag squared / span, so the payout also reads at distance.
		var outside: float = maxf(0.0, turn if i < 2 else -turn)
		var span_m: float = hand.distance_to(end) / strap.ppm
		down = hand.direction_to(end).orthogonal()
		if down.y < 0.0:
			down = -down
		sag = sqrt(1.5 * span_m * DentStringSteer.TRAVEL_M) * outside
		if not strap.reduced:
			shake = clampf(1.0 - float(strap.tick - _hit_tick) / HIT_TICKS, 0.0, 1.0)
	if is_zero_approx(shake) and is_zero_approx(sag):
		return PackedVector2Array([hand, end])
	var points: PackedVector2Array = [hand]
	for j: int in range(1, DentStrap.SEGMENTS):
		var t: float = float(j) / DentStrap.SEGMENTS
		var wave: float = sin(3.0 * TAU * t + strap.tick * 1.8 + i) * shake * 0.075
		var bend: Vector2 = down * sag + hand.direction_to(end).orthogonal() * wave
		@warning_ignore("return_value_discarded")
		points.append(hand.lerp(end, t) + bend * (sin(PI * t) * strap.ppm))
	@warning_ignore("return_value_discarded")
	points.append(end)
	return points


func paint(canvas: DentStrapCanvas, fill: Color) -> void:
	var alpha: float = 1.0 - strap.fray()
	for i: int in 4:
		var points: PackedVector2Array = path(i)
		canvas.stroke(points, Color(fill, 0.16 * alpha), strap.ppm * CORE_M * 4.0)
		canvas.stroke(points, Color(DentRoof.INK, alpha), strap.ppm * INK_M)
		canvas.stroke(points, Color(fill, alpha), strap.ppm * CORE_M)
		var end: Vector2 = points[-1]
		canvas.ring(end, strap.ppm * 0.088, Color(DentRoof.INK, alpha), strap.ppm * INK_M * 2.0)
		canvas.ring(end, strap.ppm * 0.088, Color(fill, alpha), strap.ppm * CORE_M)
