class_name OhmBoltView
extends RefCounted
## Connect the current cast to its painted fork and the exact fighters named by struck.

var rims: OhmVictimRims = OhmVictimRims.new()
var _fork: OhmFork
var _tips: PackedVector2Array = []


func attach(ink: OhmView) -> void:
	rims.stage = ink.stage
	rims.ppm = ink.ppm
	rims.calm = ink.reduced_motion
	ink.add_child(rims)
	ink.z_index = RenderLayers.z(&"vehicles") + 1


func paint(ink: OhmView, o: OhmStage) -> void:
	var age: int = ink.stage.tick - o.bolt_tick if o.bolt_tick >= 0 else -1
	if o.on() and (age in [0, 1, 2] or o.cast.delay_ticks > 0 or _has_links(ink, o, age)):
		_find_fork(ink, o)
		if is_instance_valid(_fork) and _fork.is_visible_in_tree():
			_tips = _fork.points_on(ink)
			var facing: Vector2 = ink.stage.arena.rivet.facing
			OhmFork.flare(ink, _tips[2], facing, age, _fork.vent)
	if age < 0 or o.bolt_path.size() < 2:
		return
	if rims.car_contact(o) and age < OhmVictimRims.FADE_TICKS:
		var left: float = 1.0 - float(age) / OhmVictimRims.FADE_TICKS
		OhmVictimRims.ring(ink, rims.target(o, 1), rims.radius(o, 1), left)
	if _has_links(ink, o, age):
		for index: int in o.bolt_path.size() - 1:
			_link(ink, o, index, age)


func _has_links(ink: OhmView, o: OhmStage, age: int) -> bool:
	var last: int = o.bolt_path.size() - 2
	var hang: int = ceili(OhmView.HANG_S / SimClock.TICK_DT)
	return last >= 0 and age >= 0 and age < hang + OhmBoltDraw.delay(last, ink.reduced_motion)


func _find_fork(ink: OhmView, o: OhmStage) -> void:
	if is_instance_valid(_fork) and _fork.stage == o and _fork.is_visible_in_tree():
		return
	_fork = null
	for node: Node in ink.get_tree().get_nodes_in_group(OhmFork.GROUP):
		var fork: OhmFork = node as OhmFork
		if fork.stage == o and fork.is_visible_in_tree():
			_fork = fork
			return


func _link(ink: OhmView, o: OhmStage, index: int, age: int) -> void:
	var alpha: float = OhmBoltDraw.fade(age, index, ink.reduced_motion)
	if alpha <= 0.0:
		return
	var src: int = o.bolt_from[index + 1]
	var b: Vector2 = rims.target(o, index + 1)
	var a: Vector2
	var start_r: float
	if src == 0:
		if _tips.is_empty():
			return
		a = _tips[2]
		start_r = minf(OhmBoltDraw.JOIN_M * ink.ppm, 0.4 * a.distance_to(b))
		OhmBoltDraw.prongs(ink, _tips, a + a.direction_to(b) * start_r, alpha)
	else:
		a = rims.target(o, src)
		start_r = rims.radius(o, src)
	var end_r: float = rims.radius(o, index + 1)
	if a.distance_to(b) <= start_r + end_r:
		return
	var dir: Vector2 = a.direction_to(b)
	var line: PackedVector2Array = [a + dir * start_r, b - dir * end_r]
	OhmBoltDraw.link(ink, line, index, age)


static func jag(
	a: Vector2, b: Vector2, seed_i: int, amplitude_m: float, ppm: float
) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array([a])
	var n: int = maxi(2, ceili(a.distance_to(b) / (OhmView.STEP_M * ppm)))
	var side: Vector2 = (b - a).orthogonal().normalized()
	for k: int in range(1, n):
		var h: float = sin(float(seed_i * 31 + k * 17) * 12.9898) * 43758.5453
		var off: float = (h - floorf(h) - 0.5) * 2.0 * amplitude_m * ppm
		@warning_ignore("return_value_discarded")
		pts.append(a.lerp(b, float(k) / n) + side * off)
	@warning_ignore("return_value_discarded")
	pts.append(b)
	return pts
