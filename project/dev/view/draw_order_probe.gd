class_name DrawOrderProbe
extends RefCounted
## View lab (docs/view-lab/PLAN.md, registry measured-draw-order): counts the draw-order failures
## of the actors under the current --view instead of eyeballing them. Every SAMPLE_EVERY ticks it
## takes each visible CutRig's ground point (its global position) and, when the King's throne-car
## stands, the car's footprint; for each pair whose drawn shapes overlap on screen it checks that
## the one nearer the camera (larger ground y; the camera sits south) draws over the other.
## The draw rank of a node is its effective z (z_index summed up the relative chain), then tree
## order. Two rigs whose effective z sit closer than PART_SPAN draw their parts interleaved (each
## part at the rig z plus its own offset): counted as `mixed`, a failure of its own kind.
## Dev only (arena --order-probe); reads the scene, writes nothing.

const SAMPLE_EVERY: int = 6
const PART_SPAN: int = 16
const BODY_W_M: float = 0.9
const BODY_H_M: float = 1.8

var samples: int = 0
var pairs: int = 0
var wrong: int = 0
var mixed: int = 0
var car_pairs: int = 0
var car_wrong: int = 0
var _order: Dictionary[Node, int] = {}


func sample(root: Node, tick: int) -> void:
	if tick % SAMPLE_EVERY != 0:
		return
	samples += 1
	_order.clear()
	var rigs: Array[CutRig] = []
	var cars: Array[KingBodyView] = []
	_walk(root, rigs, cars)
	var p: float = SimConst.PX_PER_M
	var h: float = absf(ViewMode.shared().lift_px(BODY_H_M).y)
	for i: int in rigs.size():
		for j: int in range(i + 1, rigs.size()):
			_rig_pair(rigs[i], rigs[j], p, h)
	for car: KingBodyView in cars:
		for rig: CutRig in rigs:
			_car_pair(car, rig, p, h)


func summary() -> String:
	return (
		"order-probe view=%s samples %d rig pairs %d wrong %d mixed %d car pairs %d car wrong %d"
		% [ViewMode.shared().id, samples, pairs, wrong, mixed, car_pairs, car_wrong]
	)


func _walk(n: Node, rigs: Array[CutRig], cars: Array[KingBodyView]) -> void:
	_order[n] = _order.size()
	if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
		return
	if n is CutRig:
		rigs.append(n as CutRig)
	elif n is KingBodyView:
		cars.append(n as KingBodyView)
	for c: Node in n.get_children():
		_walk(c, rigs, cars)


func _rig_pair(a: CutRig, b: CutRig, p: float, h: float) -> void:
	var d: Vector2 = b.global_position - a.global_position
	if absf(d.x) >= BODY_W_M * p or absf(d.y) >= maxf(h, BODY_W_M * p) or d.y == 0.0:
		return
	pairs += 1
	var front: CutRig = b if d.y > 0.0 else a
	var back: CutRig = a if front == b else b
	var dz: int = eff_z(front) - eff_z(back)
	if absi(dz) < PART_SPAN:
		mixed += 1
	elif dz < 0:
		wrong += 1


## The car (phase 1 driving, phase 2+ the stalled wreck): a rig north of it whose body rises into
## it must draw under it, one south of it whose body rises over it must draw over it.
func _car_pair(car: KingBodyView, rig: CutRig, p: float, h: float) -> void:
	var f: BossFight = car.fight
	if f == null or f.body == null:  # King on the roof stands inside the footprint: skipped below
		return
	var km: KingMoves = f.moves as KingMoves
	var at: Vector2 = f.body.pos
	var dir: Vector2 = f.body.facing
	if f.phase >= 2:
		if km == null or km.car_at == Vector2.INF:
			return
		at = km.car_at
		dir = km.car_facing
	var c: Vector2 = car.to_global(Ink.px(at))
	var hl: float = KingBodyView.CAR_LEN_M * p * 0.5
	var hw: float = KingBodyView.CAR_W_M * p * 0.5
	var ex: float = absf(dir.x) * hl + absf(dir.y) * hw
	var ey: float = absf(dir.y) * hl + absf(dir.x) * hw
	var r: Vector2 = rig.global_position
	var roof: float = absf(ViewMode.shared().lift_px(KingCarStack.ROOF_M).y)
	if absf(r.x - c.x) >= ex + BODY_W_M * p * 0.5:
		return
	var north: bool = r.y < c.y - ey and r.y > c.y - ey - roof
	var south: bool = r.y > c.y + ey and r.y - h < c.y + ey
	if not (north or south):
		return
	car_pairs += 1
	var rig_over: bool = _rank(rig) > _rank(car)
	if rig_over == north:
		car_wrong += 1


func _rank(n: CanvasItem) -> int:
	return eff_z(n) * 100000 + _order.get(n, 0)


static func eff_z(n: CanvasItem) -> int:
	var z: int = 0
	var at: CanvasItem = n
	while at != null:
		z += at.z_index
		if not at.z_as_relative:
			break
		at = at.get_parent() as CanvasItem
	return z
