class_name DentView
extends Node2D
## The roof strap, overload and missed seize. Only this view remembers a released roof.

const TEAL: Color = HaulerLook.TEAL
const INK: Color = Color(0.09, 0.08, 0.07)
const HOT: Color = Color(1.0, 0.97, 0.86)
const HANDS_M: float = 0.5
const BLAST_S: float = 0.45
const FIRE: Color = DentStrap.AMBER
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
var debris_on: bool = (
	GhostAttacks.shipped().num(&"dent", &"blast_debris") > 0.0 and HitFeel.feel_flag() != "off"
)
var _overload: DentOverload
var _strap: DentStrap
var _body: DentBody
var _body_group: StringName
var _hand_offset: Vector2
var _anchor: Vector2
var _cam_at: Vector2 = Vector2.INF


func _ready() -> void:
	if dent == null or stage == null:
		return
	if DentLook.shipped().resolved() == "strap":
		_strap = DentStrap.new()
	_overload = DentOverload.new()
	_overload.bind(stage, dent)
	add_child(_overload)
	_body_group = DentBody.group_for(dent)
	_anchor = stage.pilot.ghosts.forms.table.form(DentStage.GHOST).anchor(&"hand_r")


func _process(_delta: float) -> void:
	if _strap != null:
		_strap.advance(dent.car, stage.tick, dent.link.speed, dent.blast_tick)
	if _overload != null:
		_overload.ppm = ppm
		_overload.still = reduced_motion
		_overload.queue_redraw()
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
	if _strap != null and _strap.showing():
		_tether()
	if miss_on and dent.miss_tick >= 0 and dent.car == null:
		var miss_age: float = (stage.tick - dent.miss_tick) * SimClock.TICK_DT
		if miss_age <= MISS_S:
			_miss(miss_age / MISS_S)
	if dent.blast_tick >= 0:
		var age: float = (stage.tick - dent.blast_tick) * SimClock.TICK_DT
		if age <= BLAST_S:
			_blast(dent.blast_at * ppm, age / BLAST_S)
		_debris(stage.tick - dent.blast_tick)
		_overload.spokes(self, stage.tick - dent.blast_tick)


## The blast's slabs, `age` ticks after it: WeaponFxDebris draws in Ink's 48 px/m world, so the
## view is scaled to this view's ppm around the canvas origin.
func _debris(age: int) -> void:
	if not debris_on:
		return
	var at: Vector2 = dent.blast_at
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * debris_scale())
	WeaponFxDebris.draw(self, Vector3(at.x, at.y, dent.num(&"blast_radius_m")), age)
	draw_set_transform(Vector2.ZERO)


func debris_scale() -> float:
	return ppm / Ink.PX_PER_M


func _tether() -> void:
	var rivet: Fighter = stage.arena.rivet
	var at: Vector2 = rivet.pos * ppm
	if _strap.held:
		if not is_instance_valid(_body):
			_body = get_tree().get_first_node_in_group(_body_group) as DentBody
		var hand: Vector2 = _body.grip_world() if _body != null else Vector2.INF
		if hand.is_finite():
			_hand_offset = to_local(hand) - at
		else:
			_hand_offset = _anchor.rotated(rivet.facing.angle()) * ppm
			_hand_offset += (
				ViewMode.shared().lift_px(_strap.look.hand_height_m) * ppm / SimConst.PX_PER_M
			)
	_strap.place(at + _hand_offset, ppm, reduced_motion, ViewMode.shared())
	var warmth: float = smoothstep(0.0, dent.num(&"arm_k"), dent.heat)
	var armed: bool = dent.heat >= dent.num(&"arm_k")
	var pulse: float = 0.5
	if not reduced_motion:
		pulse += 0.5 * sin(stage.tick * (0.52 if armed else 0.18))
	var fill: Color = DentStrap.fill_at(dent.heat).lerp(FIRE, warmth * (0.4 + 0.3 * pulse))
	var stripe: Color = DentStrap.AQUA.lerp(FIRE.lerp(HOT, pulse * 0.6), warmth)
	_strap.paint(self, fill, stripe)


func _blast(c: Vector2, k: float) -> void:
	var radius: float = dent.num(&"blast_radius_m") * ppm
	# The front hits the preview circle while it is still bright, then fades in place.
	var expansion: float = 1.0 - pow(1.0 - minf(1.0, (k + 0.035) / 0.65), 2.0)
	var r: float = radius * expansion
	if not reduced_motion:
		_fireball(c, r, k)
	var look: DentLook = DentLook.shipped()
	draw_arc(c, r, 0.0, TAU, 72, Color(INK, 1.0 - k), look.ring_ink_m * ppm, true)
	draw_arc(c, r, 0.0, TAU, 72, Color(FIRE, 1.0 - k), look.ring_edge_m * ppm, true)


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
