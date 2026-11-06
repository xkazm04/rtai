class_name RigDepthSort
extends Node2D
## View lab (docs/view-lab/PLAN.md, registry measured-draw-order): under a tilted --view a body
## nearer the camera (larger ground y; the camera sits south) must draw over the body behind it.
## Each rig's parts carry their own z offsets (0 .. PART_SPAN - 1 over the rig), so two rigs at
## the same z interleave their parts (a far head over a near torso). Every frame, after the rigs
## have posed, this collects the actor layer's visible CutRigs, walks them far to near and gives
## each a depth level: 0 when it overlaps no farther rig on screen, else one more than the highest
## level among the farther rigs it overlaps. The rig's z is its depth_base (KingCarStack's
## behind-the-car z) plus level x STEP, so overlapping bodies never share a part band, while the
## common case (nobody overlapping) stays at level 0. Rivet's held weapon and reload magazine
## ride his level. Straight down (flat views) this node is never made: bit-identical.

const STEP: int = 32
## Behind-the-car rigs stay under the car (KingCarStack.BEHIND_Z + this many levels at most).
const BEHIND_MAX_LEVEL: int = 1
## Levels above this share the top band (the actors band is 100 wide: 2 x STEP + the parts' 31
## stays under the vehicles band).
const MAX_LEVEL: int = 2
## The on-screen body box used for the overlap test (m): width, and the height the tilt raises.
const BODY_W_M: float = 0.9
const BODY_H_M: float = 1.8

## The screen box (global px) north of the King's car where the cast's rigs draw behind the car
## (KingCarStack.BEHIND_Z), as KingCarStack.sort_rigs does for King's own rigs; empty = no car.
## Only near the car, so the boss's ground tells (z just under the actors) never cover Rivet.
static var far_box: Rect2 = Rect2()

var _layer: Node = null
## Rivet's followers (held weapon, magazine) and their own z before any level.
var _follow_base: Dictionary[CanvasItem, int] = {}


## Adds the sorter to the actor `layer` under a tilted view (pitch below 90); else nothing.
static func attach(layer: Node) -> void:
	if ViewMode.shared().is_flat():
		return
	far_box = Rect2()
	var s: RigDepthSort = RigDepthSort.new()
	s._layer = layer
	s.process_priority = 100  # after CharacterRigs and the boss views have posed this frame
	layer.add_child(s)


func _process(_delta: float) -> void:
	var rigs: Array[CutRig] = []
	var follow: Array[CanvasItem] = []
	for c: Node in _layer.get_children():
		_collect(c, 0, rigs, follow)
	var level: Dictionary[CutRig, int] = levels(rigs, _box())
	for rig: CutRig in rigs:
		if rig.get_parent() is CharacterRigs:
			var far: bool = far_box.has_point(rig.global_position)
			rig.depth_base = KingCarStack.BEHIND_Z if far else 0
		var top: int = BEHIND_MAX_LEVEL if rig.depth_base < 0 else MAX_LEVEL
		rig.z_index = rig.depth_base + mini(level[rig], top) * STEP
	for f: CanvasItem in follow:
		_follow(f)


## The depth level of every rig (see the class doc); `box` = the body box in screen px.
static func levels(rigs: Array[CutRig], box: Vector2) -> Dictionary[CutRig, int]:
	var order: Array[CutRig] = rigs.duplicate()
	order.sort_custom(func(a: CutRig, b: CutRig) -> bool: return _foot(a).y < _foot(b).y)
	var out: Dictionary[CutRig, int] = {}
	for i: int in order.size():
		var at: Vector2 = _foot(order[i])
		var lv: int = 0
		for j: int in i:
			var d: Vector2 = at - _foot(order[j])
			if absf(d.x) < box.x and d.y < box.y and d.y > 0.0:
				lv = maxi(lv, out[order[j]] + 1)
		out[order[i]] = lv
	return out


static func _foot(rig: CutRig) -> Vector2:
	return rig.global_position


func _box() -> Vector2:
	var p: float = SimConst.PX_PER_M
	var h: float = absf(ViewMode.shared().lift_px(BODY_H_M).y)
	return Vector2(BODY_W_M * p, maxf(h, BODY_W_M * p))  # as DrawOrderProbe measures


## Rigs up to three levels down (layer > CharacterRigs > rig; layer > KingBodyView > KingRigs >
## rig), and Rivet's held weapon and magazine views.
func _collect(n: Node, depth: int, rigs: Array[CutRig], follow: Array[CanvasItem]) -> void:
	if n is CutRig:
		if (n as CutRig).is_visible_in_tree():
			rigs.append(n as CutRig)
		return
	if n is RivetHeldView or n is WeaponMagView:
		follow.append(n as CanvasItem)
		return
	if depth >= 2:
		return
	for c: Node in n.get_children():
		_collect(c, depth + 1, rigs, follow)


func _follow(f: CanvasItem) -> void:
	if not _follow_base.has(f):
		_follow_base[f] = f.z_index
	var rig: CutRig = null
	if f is RivetHeldView:
		var h: RivetHeldView = f as RivetHeldView
		rig = h.rigs.rig_for(h.rivet_id) if h.rigs != null else null
	elif f is WeaponMagView:
		var m: WeaponMagView = f as WeaponMagView
		rig = m.rigs.rig_for(m.rivet_id) if m.rigs != null else null
	f.z_index = _follow_base[f] + (rig.z_index if rig != null else 0)
