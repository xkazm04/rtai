class_name VaultCourseRoute
extends RefCounted
## Each shot has the same 26 sprint ticks before its roll edge. Survey both sides of actual
## generated furniture to find a clear run-up. The survey is identical in both flag arms.

const SHOT: int = 126
const PRESS: int = 55
const RUN_UP: int = 26
const SUBJECTS: PackedStringArray = ["cover_low", "cover_high", "landing_blocked", "bench", "sedan"]

var start: Vector2
var dir: Vector2
var focus: Vector2
var subject: String


func set_shot(stage: ArenaStage, shot: int) -> bool:
	subject = SUBJECTS[shot]
	var motion: PlayerMotion = stage.pilot.motion
	var probe: VaultProbe = motion.vault.probe
	var targets: Dictionary[Rect2, String] = {}
	probe.stations(stage.stations, stage.plan.base)
	if shot < 3:
		var centers: Array[Vector2] = [Vector2(9, 18), Vector2(20, 20), Vector2(15, 13)]
		for box: Rect2 in probe.boxes:
			if box.get_center().is_equal_approx(centers[shot]):
				targets[box] = probe.boxes[box]
	else:
		probe.city = VaultCity.new(stage.cells)
		probe.city.collect(Rect2(stage.plan.base - Vector2(32, 32), Vector2(75, 75)), targets)
	var distance: float = 0.0
	for i: int in RUN_UP:
		var speed: float = minf(
			motion.sprint_mps, (i + 1) * motion.sprint_accel_mps2 * SimClock.TICK_DT
		)
		distance += speed * SimClock.TICK_DT
	var ordered: Array[Rect2] = targets.keys()
	if shot >= 3:
		var hub: Vector2 = stage.plan.base
		ordered.sort_custom(
			func(a: Rect2, b: Rect2) -> bool:
				return (
					a.get_center().distance_squared_to(hub)
					< b.get_center().distance_squared_to(hub)
				)
		)
	for box: Rect2 in ordered:
		if shot >= 3 and targets[box] != subject:
			continue
		for toward: Vector2 in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
			if _path(stage, box, toward, distance):
				return true
	return false


func _path(stage: ArenaStage, box: Rect2, toward: Vector2, distance: float) -> bool:
	var body: Fighter = stage.arena.rivet
	var probe: VaultProbe = stage.pilot.motion.vault.probe
	focus = box.get_center()
	dir = toward
	var face: Vector2 = focus - dir * dir.abs().dot(box.size) * 0.5
	var at: Vector2 = face - dir * (body.radius_m + 0.27)
	var hit: VaultProbe.Hit = probe.find(at, body.radius_m, dir * 9.3, dir)
	var want: String = "too_high" if subject == "cover_high" else "ok"
	if subject == "landing_blocked":
		want = subject
	if hit.reason != StringName(want) or hit.box != box:
		return false
	start = at - dir * distance
	for i: int in RUN_UP + 1:
		if not probe.clear_at(start.lerp(at, float(i) / RUN_UP), body.radius_m):
			return false
	return true


func input(k: int, actions: PlayerActions) -> TickInput:
	var moving: bool = k >= PRESS - RUN_UP and k <= PRESS
	var bits: int = 1 << actions.bit(&"sprint") if moving else 0
	if k == PRESS:
		bits |= 1 << actions.bit(&"roll")
	var axes: Vector2 = dir * TickInput.AXIS_MAX if moving else Vector2.ZERO
	return TickInput.new(bits, roundi(axes.x), roundi(axes.y))
