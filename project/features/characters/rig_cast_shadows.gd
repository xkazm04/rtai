class_name RigCastShadows
extends Node2D
## View lab (docs/view-lab/PLAN.md, top_lift): a height cue that needs no tilt. Each body casts a
## ground shadow away from the sun (ViewMode.cast_dir) as long as its height times
## ViewMode.cast_k: narrow at the feet, the shoulders wide, a head blob at the far end, so a
## standing body throws a long figure and a downed one (c_sprawl) a short smudge. Drawn on the
## actor layer just under the boss's ground tells. Only made when the view row sets cast_k
## (the shipped `top` does not: bit-identical). Render only: reads the rigs, never the sim.

## Shadow ink, as KingCarStack.SHADOW (the riso print inks it like the car's contact shadow).
const SHADOW: Color = Color(0.09, 0.075, 0.106, 0.38)
## A body's height in hip heights (RigTilt: torso 0.55 and head 0.45 above the hips).
const BODY_IN_HIPS: float = 2.0
## The shadow's shoulder width in hip heights, the feet's and the head's in shoulder widths.
const WIDTH_IN_HIPS: float = 0.55
const FEET_K: float = 0.4
const HEAD_K: float = 0.5
## Where the shoulders and the head's centre fall along the shadow (0 feet, 1 the top).
const SHOULDER_AT: float = 0.72
const HEAD_AT: float = 0.9

var _layer: Node = null


## Adds the shadows to the actor `layer` when the view casts them (cast_k > 0); else nothing.
static func attach(layer: Node) -> void:
	if ViewMode.shared().cast_k <= 0.0:
		return
	var s: RigCastShadows = RigCastShadows.new()
	s._layer = layer
	s.z_index = RenderLayers.z(&"actors") - 2 + RigDepthSort.ground_dz()
	s.process_priority = 100  # after the rigs have posed this frame
	layer.add_child(s)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var view: ViewMode = ViewMode.shared()
	for rig: CutRig in _rigs():
		var hip: float = RigTilt.hip_h(rig) * absf(rig.global_scale.x)
		var feet: Vector2 = to_local(rig.global_position)
		draw_colored_polygon(figure(feet, view.cast_dir(), hip * view.cast_k), SHADOW)


## The shadow of a body with its feet at `feet`, cast along `dir` (unit) by a hip height of
## `hip` px already scaled by cast_k: a tapered figure plus a head (one convex outline).
static func figure(feet: Vector2, dir: Vector2, hip: float) -> PackedVector2Array:
	var length: float = hip * BODY_IN_HIPS
	var side: Vector2 = dir.orthogonal() * maxf(hip, 1.0) * WIDTH_IN_HIPS * 0.5
	var sh: Vector2 = feet + dir * length * SHOULDER_AT
	var head: Vector2 = feet + dir * length * HEAD_AT
	var out: PackedVector2Array = PackedVector2Array(
		[
			feet - side * FEET_K,
			feet + side * FEET_K,
			sh + side,
			head + side * HEAD_K,
			feet + dir * length + side * 0.2,
			feet + dir * length - side * 0.2,
			head - side * HEAD_K,
			sh - side,
		]
	)
	return out


## Visible rigs up to three levels down (layer > CharacterRigs > rig; layer > KingBodyView >
## KingRigs > rig), as RigDepthSort collects them.
func _rigs() -> Array[CutRig]:
	var out: Array[CutRig] = []
	for c: Node in _layer.get_children():
		collect(c, 0, out)
	return out


## (PropOcclusion collects the same rigs.)
static func collect(n: Node, depth: int, out: Array[CutRig]) -> void:
	if n is CutRig:
		if (n as CutRig).is_visible_in_tree():
			out.append(n as CutRig)
		return
	if depth >= 2:
		return
	for c: Node in n.get_children():
		collect(c, depth + 1, out)


## The cast shadow of a box standing on `corners` (its footprint, the canvas's local px), its
## top thrown by `off` (the sun's direction x its height x cast_k): one convex sweep in SHADOW.
static func sweep(ci: CanvasItem, corners: PackedVector2Array, off: Vector2) -> void:
	var hull: PackedVector2Array = sweep_hull(corners, off)
	if hull.size() >= 3:
		ci.draw_colored_polygon(hull, SHADOW)


## The outline of that sweep (open: no repeated end point).
static func sweep_hull(corners: PackedVector2Array, off: Vector2) -> PackedVector2Array:
	var pts: PackedVector2Array = corners.duplicate()
	for c: Vector2 in corners:
		@warning_ignore("return_value_discarded")
		pts.append(c + off)
	var hull: PackedVector2Array = Geometry2D.convex_hull(pts)
	if hull.size() > 1:
		hull.remove_at(hull.size() - 1)  # convex_hull closes the loop
	return hull
