class_name DentStrap
extends RefCounted
## The held roof and the last loose length belong to the view. All movement uses the stage tick.

const SLACK_TICKS: int = 21
const FRAY_TICKS: int = 9
const SEGMENTS: int = 16
const AQUA: Color = Color("#CEFFF2")
const AMBER: Color = Color("#E9A23B")

var look: DentLook = DentLook.shipped()
var ground_m: Vector2
var heading: float
var travel_m: float = 0.0
var hand_px: Vector2
var roof_px: Vector2
var ppm: float
var reduced: bool
var tick: int = -1
var release_tick: int = -1
var held: bool = false
var _teal: Color
var _roof_height_m: float


func _init(teal: Color, roof_height_m: float) -> void:
	_teal = teal
	_roof_height_m = roof_height_m


func advance(car: VehicleBody, now: int, speed: float, blast_tick: int) -> void:
	if car != null:
		if held:
			# Keep neighbouring ticks distinguishable even at full link speed and a 30 Hz display.
			var feed: float = absf(speed) * look.strap_feed_k
			travel_m = fposmod(
				travel_m + feed * maxi(0, now - tick) * SimClock.TICK_DT, look.strap_tick_gap_m
			)
		else:
			travel_m = 0.0
		ground_m = car.pos
		heading = car.head.angle()
		release_tick = -1
	elif held:
		release_tick = now if blast_tick < tick else -1
	held = car != null
	tick = now


func showing() -> bool:
	return held or (release_tick >= 0 and tick - release_tick < SLACK_TICKS + FRAY_TICKS)


func fray() -> float:
	if release_tick < 0:
		return 0.0
	return clampf(float(tick - release_tick - SLACK_TICKS) / FRAY_TICKS, 0.0, 1.0)


func place(hand: Vector2, scale_ppm: float, still: bool, vm: ViewMode) -> void:
	hand_px = hand
	ppm = scale_ppm
	reduced = still
	roof_px = DentRoof.centre(ground_m, ppm, vm, _roof_height_m)


func width_px() -> float:
	return look.strap_width_m * ppm


func fill_at(heat: float) -> Color:
	return _teal.lerp(AMBER, clampf(heat, 0.0, 1.0))


func point(t: float) -> Vector2:
	var base: Vector2 = hand_px.lerp(roof_px, t)
	if t <= 0.0 or t >= 1.0:
		return base
	var bow: float = sin(PI * t) * ppm
	if not held:
		var slack: float = clampf(float(tick - release_tick) / SLACK_TICKS, 0.0, 1.0)
		return base + Vector2.DOWN * bow * look.strap_sag_m * slack
	var normal: Vector2 = hand_px.direction_to(roof_px).orthogonal()
	var shake: float = 0.0 if reduced else sin(tick * 0.53 + t * TAU)
	return base + normal * bow * look.strap_tremble_m * shake


func belt_path(end: float) -> PackedVector2Array:
	var path: PackedVector2Array = []
	for i: int in SEGMENTS + 1:
		@warning_ignore("return_value_discarded")
		path.append(point(end * i / SEGMENTS))
	return path


func paint(canvas: DentStrapCanvas, fill: Color, stripe: Color) -> void:
	var fade: float = 1.0 - fray()
	DentRoof.disc(canvas, roof_px, heading, ppm, Color(_teal, fade))
	var path: PackedVector2Array = belt_path(fade)
	var edge: float = look.strap_edge_m * ppm
	if hand_px.distance_squared_to(roof_px) > 0.01:
		canvas.stroke(path, Color(DentRoof.INK, fade), width_px())
		canvas.stroke(path, Color(fill, fade), width_px() - edge * 2.0)
		canvas.stroke(path, Color(stripe, fade), look.strap_stripe_m * ppm)
		_webbing(canvas, fade)
		if fade < 1.0:
			_threads(canvas, fade, fill)
	DentRoof.buckle(canvas, roof_px, heading, ppm, fade)


func _webbing(canvas: DentStrapCanvas, end: float) -> void:
	var length: float = hand_px.distance_to(roof_px)
	var gap: float = look.strap_tick_gap_m * ppm
	var offset: float = 0.0 if reduced else travel_m * ppm
	var half: float = width_px() * 0.5 - look.strap_edge_m * ppm
	for i: int in ceili(length * end / gap):
		var t: float = (i * gap + offset) / length
		if t >= end:
			break
		var p: Vector2 = point(t)
		var axis: Vector2 = p.direction_to(point(minf(1.0, t + 0.01)))
		var side: Vector2 = axis.orthogonal() * half
		canvas.line(
			p - side,
			p + side + axis * half * 0.5,
			Color(DentRoof.INK, end * look.strap_webbing_alpha),
			half * 0.42
		)


func _threads(canvas: DentStrapCanvas, end: float, fill: Color) -> void:
	var tip: Vector2 = point(end)
	var fwd: Vector2 = point(maxf(0.0, end - 0.05)).direction_to(tip)
	for i: int in range(-1, 2):
		var side: Vector2 = fwd.orthogonal() * width_px() * i * 0.23
		canvas.line(
			tip + side,
			tip + side * 1.7 + fwd * width_px() * (1.1 - 0.4 * absi(i)),
			Color(fill, end),
			ppm * look.strap_stripe_m
		)
