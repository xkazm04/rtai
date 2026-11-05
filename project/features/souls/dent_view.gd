class_name DentView
extends Node2D
## Dent on the arena's actor layer (lane ghost-powers), render only. While a car is seized: a
## soul-teal tether from Rivet's hands (HANDS_M ahead) to the car, sagging and trembling, and a
## heat halo round the car that climbs from a dull amber to white-hot with DentStage.heat (the
## pulse quickens once the overload is armed). On the blast: an ink shock ring and an amber
## fireball with a hot core over BLAST_S (reduced motion: the ring only). A seize that finds no car
## (none in range, or no car service: quest 1) lashes the tether out along the aim to its reach,
## then it frays into dashes and three teal sparks over MISS_S (reduced motion: it fades whole).
## Reads DentStage only.

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const WARM: Color = Color("#C9822E")
const HOT: Color = Color(1.0, 0.97, 0.86)
const HANDS_M: float = 0.5
const SAG_M: float = 0.6
const SEGMENTS: int = 14
const BLAST_S: float = 0.45
const FIRE: Color = Color("#E9A23B")
const BURST_POINTS: int = 9
const MISS_S: float = 0.4
const MISS_DASHES: int = 10
## The dev car camera's hold on the blast (s) and its ease per frame.
const CAM_HOLD_S: float = 1.0
const CAM_EASE: float = 0.15

var dent: DentStage = null
var stage: CollectCallStage = null
var ppm: float = 32.0
var reduced_motion: bool = false
## The dev `--cam=car` (TonnageHook sets it): the view's camera frames Rivet and the seized car
## (their midpoint, eased), then holds on the blast for CAM_HOLD_S. View only: the sim's focus is
## untouched (on the city block it leans the view by city_lean_m, like `--cam=fight`).
var follow_cam: CollectCallView = null
## False hides the missed reach (dev `--no-dent-miss`: the A/B before, iteration 8).
var miss_on: bool = not OS.get_cmdline_user_args().has("--no-dent-miss")
var _cam_at: Vector2 = Vector2.INF


func _process(_delta: float) -> void:
	if follow_cam != null and dent != null and stage != null:
		_follow()
	queue_redraw()


func _follow() -> void:
	var rivet: Vector2 = stage.arena.rivet.pos
	var want: Vector2 = rivet
	if dent.car != null:
		want = rivet.lerp(dent.car.pos, 0.5)
	elif dent.blast_tick >= 0 and (stage.tick - dent.blast_tick) * SimClock.TICK_DT < CAM_HOLD_S:
		want = rivet.lerp(dent.blast_at, 0.5)
	_cam_at = want if _cam_at == Vector2.INF else _cam_at.lerp(want, CAM_EASE)
	if follow_cam.city != null:
		follow_cam.city_lean_m = _cam_at - rivet
	else:
		follow_cam.focus = _cam_at


func _draw() -> void:
	if dent == null or stage == null:
		return
	if dent.car != null:
		var rivet: Fighter = stage.arena.rivet
		var hands: Vector2 = (rivet.pos + rivet.facing.normalized() * HANDS_M) * ppm
		_halo(dent.car.pos * ppm, dent.heat)
		_tether(hands, dent.car.pos * ppm)
	if miss_on and dent.miss_tick >= 0 and dent.car == null:
		var miss_age: float = (stage.tick - dent.miss_tick) * SimClock.TICK_DT
		if miss_age <= MISS_S:
			_miss(miss_age / MISS_S)
	if dent.blast_tick >= 0:
		var age: float = (stage.tick - dent.blast_tick) * SimClock.TICK_DT
		if age <= BLAST_S:
			_blast(dent.blast_at * ppm, age / BLAST_S)


func _tether(a: Vector2, b: Vector2) -> void:
	var pts: PackedVector2Array = PackedVector2Array()
	var side: Vector2 = (b - a).orthogonal().normalized()
	for i: int in SEGMENTS + 1:
		var t: float = float(i) / SEGMENTS
		var sag: float = sin(t * PI) * SAG_M * ppm * 0.4
		var shake: float = 0.0 if reduced_motion else sin(stage.tick * 0.9 + i * 1.7) * 2.0
		@warning_ignore("return_value_discarded")
		pts.push_back(a.lerp(b, t) + side * (sag + shake))
	draw_polyline(pts, Color(INK, 0.7), 5.0)
	draw_polyline(pts, TEAL, 2.0)
	draw_circle(b, 4.0, TEAL)


func _halo(c: Vector2, heat: float) -> void:
	var armed: bool = heat >= dent.num(&"arm_k")
	var rate: float = 0.5 if armed else 0.2
	var pulse: float = 0.5 + 0.5 * sin(stage.tick * rate) if not reduced_motion else 0.6
	var col: Color = WARM.lerp(HOT, heat)
	var r: float = (1.6 + 0.4 * heat) * ppm
	draw_circle(c, r, Color(col, (0.1 + 0.3 * heat) * (0.6 + 0.4 * pulse)))
	draw_arc(c, r, 0.0, TAU, 40, Color(col, 0.4 + 0.5 * heat), 2.0 + 2.0 * heat)


func _blast(c: Vector2, k: float) -> void:
	var r: float = dent.num(&"blast_radius_m") * ppm * (1.0 - pow(1.0 - k, 3.0))
	if not reduced_motion:
		_fireball(c, r * 0.7, k)
	draw_arc(c, r, 0.0, TAU, 48, Color(INK, 1.0 - k), lerpf(10.0, 2.0, k))


## The car bomb's fireball: a jagged ink-rimmed burst, amber outside and cream-hot inside, that
## swells and burns down over BLAST_S (no red: red is blood only).
func _fireball(c: Vector2, r: float, k: float) -> void:
	var fade: float = 1.0 - k
	var pts: PackedVector2Array = PackedVector2Array()
	for i: int in BURST_POINTS * 2:
		var a: float = TAU * i / (BURST_POINTS * 2) + 0.2 * sin(i * 2.3)
		var reach: float = r * (1.0 if i % 2 == 0 else 0.62 + 0.1 * sin(i * 1.7))
		@warning_ignore("return_value_discarded")
		pts.push_back(c + Vector2.from_angle(a) * reach)
	draw_colored_polygon(pts, Color(FIRE, 0.9 * fade))
	@warning_ignore("return_value_discarded")
	pts.append(pts[0])
	draw_polyline(pts, Color(INK, fade), 3.0)
	draw_circle(c, r * 0.45 * (1.0 - 0.5 * k), Color(HOT, fade))


## The reach that found no car, `k` 0..1: out to range_m along the aim, then frayed and gone.
func _miss(k: float) -> void:
	var rivet: Fighter = stage.arena.rivet
	var from: Vector2 = rivet.pos + rivet.facing.normalized() * HANDS_M
	var reach: float = minf(from.distance_to(dent.miss_to), dent.link.num(&"range_m"))
	var tip: Vector2 = from + (dent.miss_to - from).normalized() * reach
	var a: Vector2 = from * ppm
	var b: Vector2 = a.lerp(tip * ppm, 1.0 if reduced_motion else minf(1.0, k / 0.35))
	var fade: float = 1.0 - k
	if reduced_motion or k < 0.35:
		draw_line(a, b, Color(INK, 0.6 * fade), 5.0)
		draw_line(a, b, Color(TEAL, fade), 2.0)
		return
	var fray: float = (k - 0.35) / 0.65
	for i: int in MISS_DASHES:
		var t0: float = float(i) / MISS_DASHES
		var t1: float = t0 + (1.0 - fray) / MISS_DASHES
		draw_line(a.lerp(b, t0), a.lerp(b, t1), Color(TEAL, fade), 2.0)
	var side: Vector2 = (b - a).orthogonal().normalized()
	for s: int in 3:
		var off: Vector2 = side * (s - 1) * 6.0 * (1.0 + fray) + (b - a).normalized() * fray * 8.0
		draw_circle(b + off, 2.5 * fade + 1.0, Color(TEAL, fade))
