class_name ElectricWreckFx
extends RobotShutdownFx
## Independent of the live rig and RNG. The bolt pushes the chassis away from Rivet, while
## the clamp hangs it from the core and drops it back toward him. Loose plates stay on the floor.

const STEEL: Color = Color("#545c67")
const EDGE: Color = Color("#b5afa1")
const CREAM: Color = Color("#fff1c4")
const PLATE: PackedVector2Array = [
	Vector2(-0.19, -0.09), Vector2(0.10, -0.12), Vector2(0.21, 0.03), Vector2(-0.12, 0.13)
]

var bolt: bool = false
var card: Sprite2D


static func for_row(row: SignatureKill, rig: CutRig = null) -> RobotShutdownFx:
	if row.weapon == &"electric_shutdown":
		return RobotShutdownFx.new()
	var wreck: ElectricWreckFx = ElectricWreckFx.new()
	wreck.bolt = row.weapon == &"electro_bolt_shutdown"
	wreck.card = ElectricChassis.card_of(rig, row.victim)
	return wreck


func _copy(body: Node2D, victim: StringName, dir: Vector2) -> void:
	if card != null:
		body.free()
		super._copy(card, &"", dir)
		return
	super._copy(body, victim, dir)
	if victim in [&"robot_thug", &"robot_gunner"]:
		ElectricChassis.fit_core(chassis, ppm, joint_m, side)


func _process(_delta: float) -> void:
	var age: int = clock.tick - born
	var fall: float = smoothstep(0.0, float(fold_ticks), float(age - shake_ticks))
	var rise: float = smoothstep(0.0, 11.0, float(age))
	if bolt:
		var recoil: float = sin(PI * clampf(age / 9.0, 0.0, 1.0))
		pivot.position = Vector2(side * (0.27 * recoil + 0.42 * fall), 0.0) * ppm
		pivot.rotation = side * deg_to_rad(8.0 * recoil + fall_deg * 1.12 * fall)
		pivot.scale.y = 1.0 - 0.20 * fall
	else:
		var lift: float = rise * (1.0 - fall) * (0.36 if still else 1.34)
		pivot.position = Vector2(side * (0.18 * rise - 0.66 * fall), -lift) * ppm
		pivot.rotation = -side * deg_to_rad(12.0 * rise + fall_deg * 0.70 * fall)
		pivot.scale.y = 1.0 - 0.53 * fall
	if age >= 5 and not exposed_steel:
		exposed_steel = true
		_expose_steel()
	chassis.modulate = Color.WHITE.lerp(Color("#a49e96"), fall)
	(pivot.get_child(1) as Node2D).queue_redraw()
	queue_redraw()


func _lights(ci: Node2D) -> void:
	var age: int = clock.tick - born
	var core: Vector2 = Vector2.UP * joint_m
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2(side, 1.0) * ppm)
	if bolt:
		ci.draw_circle(core, 0.21, DARK)
		if age < shake_ticks:
			_bolt_current(ci, core, age)
	else:
		if age < shake_ticks + 6:
			_clamp(ci, core, age)
		ci.draw_circle(core, 0.18, DARK)
		if age < shake_ticks:
			ci.draw_circle(core, 0.13, AMBER)
			ci.draw_circle(core, 0.07, Color.WHITE)
		elif age < shake_ticks + 20:
			_core_burst(ci, core, float(age - shake_ticks) / 20.0)
		if age >= shake_ticks:
			_smoke(ci, age - shake_ticks)


func _bolt_current(ci: Node2D, core: Vector2, age: int) -> void:
	if age < 6:
		_arc(ci, [core + Vector2(-1.35, 0.10), core + Vector2(-0.62, -0.05), core])
	var branch: float = clampf((age + 1.0) / 8.0, 0.1, 1.0)
	for sign_y: float in [-1.0, 1.0]:
		var joint: Vector2 = core + Vector2(0.33, 0.28 * sign_y) * branch
		var outlet: Vector2 = core + Vector2(0.76, 0.64 * sign_y) * branch
		_arc(ci, [core, joint, joint + Vector2(-0.04, 0.20 * sign_y), outlet])
		ci.draw_circle(outlet, 0.075, CREAM)


func _clamp(ci: Node2D, core: Vector2, age: int) -> void:
	var spread: float = lerpf(0.44, 0.19, smoothstep(0.0, 4.0, age))
	var wrist: Vector2 = core + Vector2(-0.76, 0.0)
	for jaw: float in [-1.0, 1.0]:
		var prong: PackedVector2Array = [
			wrist, core + Vector2(-0.38, jaw * spread), core + Vector2(-0.08, jaw * spread * 0.6)
		]
		ci.draw_polyline(prong, DARK, 0.15, true)
		ci.draw_polyline(prong, EDGE, 0.08, true)
		_arc(ci, [prong[2], core + Vector2(0.12, jaw * 0.20), core])
	ci.draw_circle(wrist, 0.11, STEEL)
	ci.draw_circle(wrist, 0.046, AMBER)


func _arc(ci: Node2D, points: PackedVector2Array) -> void:
	ci.draw_polyline(points, AMBER, 0.12, true)
	ci.draw_polyline(points, Color.WHITE, 0.048, true)


func _core_burst(ci: Node2D, core: Vector2, u: float) -> void:
	for i: int in 7:
		var dir: Vector2 = Vector2.UP.rotated(TAU * i / 7.0)
		var end: Vector2 = core + dir * (0.28 + u * 0.64)
		ci.draw_line(end - dir * 0.18, end, CREAM, 0.065, true)
	ci.draw_arc(core, 0.20 + 0.35 * u, 0.0, TAU, 18, Color(AMBER, 1.0 - u), 0.07, true)


func _draw() -> void:
	var age: int = clock.tick - born
	var eject: int = 5 if bolt else shake_ticks
	if not bolt and age < shake_ticks:
		_lift_arc(age)
	if age >= eject:
		for i: int in 4 if bolt else 3:
			_fragment(i, age - eject)


## The fixed lower end stays by Rivet's wrist as the upper end rises with the captured frame.
func _lift_arc(age: int) -> void:
	var wrist: Vector2 = Vector2(-0.95, -0.57)
	var core: Vector2 = (pivot.transform * (Vector2.UP * joint_m * ppm)) / ppm
	core.x *= side
	var bend: Vector2 = wrist.lerp(core, 0.48)
	var kink: float = 0.13 if age / 3 % 2 == 0 or still else -0.13
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(side, 1.0) * ppm)
	draw_polyline(
		[wrist, bend + Vector2(kink, 0), bend + Vector2(-kink, -0.18), core], DARK, 0.16, true
	)
	_arc(self, [wrist, bend + Vector2(kink, 0), bend + Vector2(-kink, -0.18), core])


func _fragment(i: int, age: int) -> void:
	var u: float = clampf(float(age) / (22.0 + 4.0 * i), 0.0, 1.0)
	var sign_x: float = -1.0 if i % 2 == 0 else 1.0
	var reach: float = (0.81 + 0.26 * i) if bolt else (0.38 + 0.17 * i)
	var origin: Vector2 = Vector2(0.0, -joint_m) if bolt else Vector2(0.18, -joint_m - 1.34)
	var land: Vector2 = Vector2(origin.x + sign_x * reach, -0.15 + 0.11 * i)
	var at: Vector2 = origin.lerp(land, u)
	at.y -= 2.7 * u * (1.0 - u)
	at.x *= side
	var size: float = 1.0 if bolt else 0.64
	draw_set_transform(at * ppm, sign_x * u * (4.0 + i), Vector2.ONE * ppm * size)
	draw_colored_polygon(PLATE, STEEL)
	draw_line(PLATE[0], PLATE[1], EDGE, 0.05, true)
	draw_line(PLATE[2], PLATE[3], DARK, 0.06, true)


func _smoke(ci: Node2D, age: int) -> void:
	if age > 102:
		return
	ci.draw_set_transform_matrix(pivot.transform.affine_inverse().scaled_local(Vector2.ONE * ppm))
	var fade: float = 1.0 - smoothstep(65.0, 102.0, age)
	for i: int in 5:
		var u: float = fmod(age + 7.0 * i, 36.0) / 36.0
		var at: Vector2 = Vector2(side * (-0.50 + 1.05 * u), -0.33 - 1.20 * u)
		at.x += 0.10 * sin(TAU * u + i)
		var alpha: float = (1.0 - u) * fade
		ci.draw_circle(at, 0.12 + u * 0.17, Color(DARK, alpha * 0.76))
		ci.draw_circle(at + Vector2(0.025, -0.035), 0.09 + u * 0.14, Color(EDGE, alpha * 0.68))
