class_name KillPlasmaArt
extends Node2D
## The hot blade's stroke and airborne blood share a cut line. The ground print lives with
## KillGround. Both use the same patterned droplet endpoints without advancing the combat RNG.

const COOL_TICKS: int = 40
const FLIGHT_TICKS: int = 19
const DROPS: int = 19
const AMBER: Color = KillCutEdge.HEAT_AMBER

var clock: SignatureKills
var born: int
var pixels: float
var direction: Vector2
var lift_m: float
var phase: float
var edges: Array[KillCutEdge] = []


static func attach(
	parent: KillSplitFx, parts: Array[Node2D], at: Vector2, line: Vector2, lift: float
) -> void:
	var v: KillPlasmaArt = KillPlasmaArt.new()
	v.clock = parent.kills
	v.born = v.clock.tick
	v.pixels = parent.ppm
	v.position = at * v.pixels
	v.direction = line
	v.lift_m = lift
	v.phase = at.x + at.y + lift
	for piece: int in [SignatureKill.HALF_A, SignatureKill.HALF_B]:
		if parts[piece] != null:
			for child: Node in parts[piece].get_children():
				if child is KillCutEdge:
					v.edges.append(child as KillCutEdge)
	parent.add_child(v)


static func heat(age: int) -> float:
	return clampf(1.0 - float(age) / COOL_TICKS, 0.0, 1.0)


func _process(_delta: float) -> void:
	var age: int = clock.tick - born
	for edge: KillCutEdge in edges:
		if is_instance_valid(edge):
			edge.heat = heat(age)
			edge.queue_redraw()
	if age >= COOL_TICKS:
		queue_free()
	else:
		queue_redraw()


## Ground-relative displacement and radius, in metres. The rendered fan varies with the cut.
static func drop(i: int, line: Vector2, seed_angle: float) -> Vector3:
	var side: float = sin(float(i) * 2.4 + seed_angle)
	var spread: float = fposmod(float(i) * 0.618 + seed_angle * 0.07, 1.0)
	var offset: Vector2 = line.rotated(side * 0.70) * (0.33 + spread * 1.68)
	return Vector3(offset.x, offset.y, 0.045 + (1.0 - spread) * 0.085)


static func ground_print(mark: KillMarks.Mark, push_out: Callable) -> KillMarks.Mark:
	var stain: KillMarks.Mark = KillMarks.Mark.new()
	stain.at = mark.at
	stain.dir = mark.dir
	stain.blot_m = 0.51
	for i: int in DROPS:
		@warning_ignore("return_value_discarded")
		stain.drops.append(drop(i, mark.dir, mark.at.x + mark.at.y))
	if push_out.is_valid():
		KillMarks.clip(stain, push_out)
	return stain


func _draw() -> void:
	var age: int = clock.tick - born
	if age < 0 or age >= FLIGHT_TICKS:
		return
	var t: float = float(age + 1) / FLIGHT_TICKS
	for i: int in DROPS:
		var d: Vector3 = drop(i, direction, phase)
		var end: Vector2 = Vector2(d.x, d.y + lift_m)
		var p: Vector2 = end * t + Vector2.UP * (2.4 * t * (1.0 - t))
		var tail: Vector2 = p - direction * (1.0 - t) * d.z * 2.6
		draw_line(tail * pixels, p * pixels, KillMarkArt.BLOOD_DARK, d.z * pixels * 1.8, true)
		draw_circle(p * pixels, d.z * pixels * 0.81, KillMarkArt.BLOOD)
	if age < KillSplitFx.STREAK_TICKS:
		_sweep(float(age) / KillSplitFx.STREAK_TICKS)


func _sweep(t: float) -> void:
	var normal: Vector2 = direction.orthogonal()
	var start: Vector2 = -direction * (1.25 - t * 0.8)
	var end: Vector2 = direction * (1.0 + t * 0.55)
	var width: float = 0.16 * (1.0 - t)
	var ribbon: PackedVector2Array = PackedVector2Array(
		[
			start * pixels,
			(direction * 0.38 + normal * width) * pixels,
			end * pixels,
			(direction * 0.16 - normal * width * 0.5) * pixels
		]
	)
	draw_colored_polygon(ribbon, Color(AMBER, 1.0 - t))
	draw_line(
		start * pixels,
		end * pixels,
		Color(MeleeSmearView.HOT, 1.0 - t),
		pixels * width * 0.65,
		true
	)
