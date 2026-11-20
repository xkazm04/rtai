class_name GhostMorphFx
extends Node2D
## The transformation's effects, drawn over the body from GhostForms' progress (k 0..1, stage):
## a teal burst ring that blows out from the body, teal seams that crack open across the figure
## (stage 0) and close on the new form (stage 1), steam puffs that roll out at the swap, and
## sparks thrown along fixed spokes (deterministic: no RNG, the angles come from the spoke index).
## The form-to-form switch is the same burst, short and without the steam (the teal flash).
## beat() is the camera punch (zoom 1 + BEAT_ZOOM at the swap, easing out); reduced motion turns the
## punch and the spark travel off and keeps a static ring (the read stays, the motion goes).
## Units: world px at PX_PER_M around this node's origin (the body's centre).

const PX_PER_M: float = 32.0
const TEAL: Color = Color(0.18, 0.77, 0.71)
const TEAL_HI: Color = Color(0.72, 1.0, 0.95)
const STEAM: Color = Color(0.93, 0.9, 0.84)
const SPARK: Color = Color(1.0, 0.86, 0.45)
const INK: Color = Color(0.106, 0.082, 0.09)
const SPOKES: int = 14
const BEAT_ZOOM: float = 0.06

var reduced_motion: bool = false
## The ring's reach in metres (the form's footprint grows it: Tonnage blows out wider).
var reach_m: float = 2.0
var _k: float = 1.0
var _stage: int = 0
var _on: bool = false
var _flash: bool = false
var _ground: Node2D
var _body_at: Vector2


## Feeds one frame of the running transformation; on = false hides everything.
func show_progress(on: bool, k: float, stage: int, flash: bool) -> void:
	_on = on
	_k = k
	_stage = stage
	_flash = flash
	queue_redraw()


## The camera zoom factor for this frame (1.0 when off or under reduced motion).
func beat() -> float:
	if not _on or reduced_motion:
		return 1.0
	var d: float = absf(_k - 0.5)
	return 1.0 + BEAT_ZOOM * maxf(0.0, 1.0 - d * 4.0)


## Rims and steam share the camera's ground projection. Lift the seams onto the current
## card's chest (or the mounted rig's centre in the overhead view).
func pose_body(drawn: GhostDrawn, ground_at: Vector2) -> void:
	if drawn == null:
		if _ground != null:
			_ground.hide()
			z_index = 0
		return
	if _ground == null:
		_ground = Node2D.new()
		add_child(_ground)
		_ground.z_index = -2
		@warning_ignore("return_value_discarded")
		_ground.draw.connect(_ground_pass)
	z_index = 1
	_ground.show()
	_ground.queue_redraw()
	_body_at = Vector2.ZERO
	var vm: ViewMode = ViewMode.shared()
	if not vm.is_flat():
		var height: float = RivetFrames.HEIGHT_BY_ART.get(vm.art, RivetFrames.HEIGHT_M)
		_body_at.y = (
			-0.5 * height * RivetFrames.height_k * PlayerScale.k() * PX_PER_M / vm.ground_k()
		)
	if drawn.flight.visible:
		_body_at = drawn.flight.body_offset()
		var spr: Sprite2D = drawn.sprite()
		if spr != null and spr.is_visible_in_tree():
			_body_at = to_local(spr.to_global(spr.get_rect().get_center()))
		else:
			_body_at = to_local(ground_at + _body_at)


func _draw() -> void:
	if not _on:
		return
	var r: float = reach_m * PX_PER_M
	var fade: float = 1.0 - smoothstep(0.6, 1.0, _k)
	if _ground != null and _ground.visible:
		draw_set_transform(_body_at)
		_seams(r)
	else:
		_ring(self, r, fade)
		_seams(r)
		if not _flash:
			_steam(self, r)
	_sparks(r, fade)


func _ground_pass() -> void:
	if _on:
		var r: float = reach_m * PX_PER_M
		_ring(_ground, r, 1.0 - smoothstep(0.6, 1.0, _k))
		if not _flash:
			_steam(_ground, r)


func _ring(canvas: Node2D, r: float, fade: float) -> void:
	var ring_k: float = 0.6 if reduced_motion else smoothstep(0.0, 1.0, _k)
	canvas.draw_circle(Vector2.ZERO, r * 0.55, Color(TEAL, 0.22 * fade))
	canvas.draw_arc(
		Vector2.ZERO, r * (0.25 + 0.75 * ring_k), 0.0, TAU, 48, Color(TEAL, 0.9 * fade), 4.0
	)
	canvas.draw_arc(
		Vector2.ZERO, r * (0.2 + 0.6 * ring_k), 0.0, TAU, 48, Color(TEAL_HI, 0.6 * fade), 1.5
	)


## Teal cracks along the plate lines (the crown's own seam layout: a cross through the centre and
## an inset square): they open through stage 0 and close through stage 1.
func _seams(r: float) -> void:
	var open: float = 1.0 - absf(_k - 0.5) * 2.0
	if open <= 0.0:
		return
	var w: float = 3.0 * open + 1.0
	var arm: float = r * 0.36 * open
	var sq: float = r * 0.2 * open
	var lines: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(-arm, 0.0), Vector2(arm, 0.0)]),
		PackedVector2Array([Vector2(0.0, -arm), Vector2(0.0, arm)]),
		PackedVector2Array(
			[
				Vector2(-sq, -sq),
				Vector2(sq, -sq),
				Vector2(sq, sq),
				Vector2(-sq, sq),
				Vector2(-sq, -sq)
			]
		),
	]
	for pl: PackedVector2Array in lines:
		draw_polyline(pl, INK, w + 2.0)
	for pl: PackedVector2Array in lines:
		draw_polyline(pl, TEAL_HI, w)


## Steam rolls out from the swap (past the midpoint): lumpy paper puffs (three lobes each) under
## one shared ink rim, shrinking away instead of fading (a faded puff printed as a grey disc).
func _steam(canvas: Node2D, r: float) -> void:
	var t: float = clampf((_k - 0.4) / 0.6, 0.0, 1.0)
	if t <= 0.0 or t >= 1.0:
		return
	var lobes: Array[Vector3] = []
	for i: int in 8:
		var a: float = TAU * (float(i) + 0.5) / 8.0
		var travel: float = 0.35 if reduced_motion else 0.3 + 0.5 * t
		var at: Vector2 = Vector2.from_angle(a) * r * travel
		var rad: float = r * 0.1 * (1.0 - t) * (1.0 if i % 2 == 0 else 0.75)
		var side: Vector2 = Vector2.from_angle(a + PI * 0.5) * rad * 0.8
		for o: Vector2 in [Vector2.ZERO, side, -side * 0.9]:
			lobes.append(Vector3(at.x + o.x, at.y + o.y, rad * (1.0 if o == Vector2.ZERO else 0.7)))
	for l: Vector3 in lobes:
		canvas.draw_circle(Vector2(l.x, l.y), l.z + 2.0, INK)
	for l: Vector3 in lobes:
		canvas.draw_circle(Vector2(l.x, l.y), l.z, STEAM)


## Sparks fly out along fixed spokes as short streaks (static dots under reduced motion).
func _sparks(r: float, fade: float) -> void:
	for i: int in SPOKES:
		var a: float = TAU * float(i) / float(SPOKES) + 0.21 * float(i % 3)
		var speed: float = 0.7 + 0.3 * float((i * 5) % 7) / 6.0
		var d: float = 0.5 if reduced_motion else 0.15 + _k * speed
		var head: Vector2 = Vector2.from_angle(a) * r * d
		var tail: Vector2 = Vector2.from_angle(a) * r * maxf(0.0, d - 0.12)
		var c: Color = SPARK if i % 3 != 0 else TEAL_HI
		draw_line(tail, head, Color(c, fade), 2.0)
