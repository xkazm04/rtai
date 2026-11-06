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
## Also the view's cast shadows (RigCastShadows: only when the view row sets cast_k).
static func attach(layer: Node) -> void:
	RigCastShadows.attach(layer)
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
	var cards: Array[Sprite2D] = []
	for c: Node in _layer.get_children():
		_collect(c, 0, rigs, follow, cards)
	var level: Dictionary[CutRig, int] = levels(rigs, _box())
	if not cards.is_empty():
		level = _with_cards(rigs, cards)
	for rig: CutRig in rigs:
		if rig.get_parent() is CharacterRigs:
			var far: bool = far_box.has_point(rig.global_position)
			rig.depth_base = KingCarStack.BEHIND_Z if far else 0
		var top: int = BEHIND_MAX_LEVEL if rig.depth_base < 0 else MAX_LEVEL
		rig.z_index = rig.depth_base + mini(level[rig], top) * STEP
	for f: CanvasItem in follow:
		_follow(f)


## Ghost cards (GhostCard, d8 chars) sort with the rigs: each card's z is moved so its effective z
## sits at its own level's band over the cast's rigs; its host rig moves with it (Tonnage's walking
## legs, Ohm's ground arms), else they ride the ghost view's fixed z.
func _with_cards(rigs: Array[CutRig], cards: Array[Sprite2D]) -> Dictionary[CutRig, int]:
	var bodies: Array[Node2D] = []
	var half: Array[float] = []
	var b: Vector2 = _box()
	for r: CutRig in rigs:
		bodies.append(r)
		half.append(b.x * 0.5)
	for c: Sprite2D in cards:
		bodies.append(c.get_parent() as Node2D)
		half.append(c.texture.get_width() / float(c.hframes) * absf(c.global_scale.x) * 0.5)
	var lv: Array[int] = levels_w(bodies, half, b.y)
	var out: Dictionary[CutRig, int] = {}
	for i: int in rigs.size():
		out[rigs[i]] = lv[i]
	var base: int = eff_z(rigs[0].get_parent() as CanvasItem) if not rigs.is_empty() else 0
	for j: int in cards.size():
		var c: Sprite2D = cards[j]
		var want: int = base + mini(lv[rigs.size() + j], MAX_LEVEL) * STEP
		var host: Node2D = c.get_parent() as Node2D  # the whole ghost (legs, arms) moves with it
		host.z_index += want - eff_z(c)
	return out


## How far a ground-level view just under the actors (the boss's tell zones) drops under a tilt,
## so a body behind the King's car (BEHIND_Z) still stands over it; 0 straight down.
static func ground_dz() -> int:
	return 0 if ViewMode.shared().is_flat() else KingCarStack.BEHIND_Z


## The depth level of every rig (see the class doc); `box` = the body box in screen px.
static func levels(rigs: Array[CutRig], box: Vector2) -> Dictionary[CutRig, int]:
	var bodies: Array[Node2D] = []
	var half: Array[float] = []
	for r: CutRig in rigs:
		bodies.append(r)
		half.append(box.x * 0.5)
	var lv: Array[int] = levels_w(bodies, half, box.y)
	var out: Dictionary[CutRig, int] = {}
	for i: int in rigs.size():
		out[rigs[i]] = lv[i]
	return out


## levels() over bodies of their own half widths (px) at ground points (global positions); a pair
## overlaps when closer across than the two halves and nearer by less than `box_h`.
static func levels_w(bodies: Array[Node2D], half: Array[float], box_h: float) -> Array[int]:
	var idx: Array[int] = []
	for i: int in bodies.size():
		idx.append(i)
	idx.sort_custom(
		func(a: int, b: int) -> bool:
			return bodies[a].global_position.y < bodies[b].global_position.y
	)
	var out: Array[int] = []
	@warning_ignore("return_value_discarded")
	out.resize(bodies.size())
	for k: int in idx.size():
		var i: int = idx[k]
		var lv: int = 0
		for m: int in k:
			var j: int = idx[m]
			var d: Vector2 = bodies[i].global_position - bodies[j].global_position
			if absf(d.x) < half[i] + half[j] and d.y < box_h and d.y > 0.0:
				lv = maxi(lv, out[j] + 1)
		out[i] = lv
	return out


static func eff_z(n: CanvasItem) -> int:
	var z: int = 0
	var at: CanvasItem = n
	while at != null:
		z += at.z_index
		if not at.z_as_relative:
			break
		at = at.get_parent() as CanvasItem
	return z


static func _foot(rig: CutRig) -> Vector2:
	return rig.global_position


func _box() -> Vector2:
	var p: float = SimConst.PX_PER_M
	var h: float = absf(ViewMode.shared().lift_px(BODY_H_M).y)
	return Vector2(BODY_W_M * p, maxf(h, BODY_W_M * p))  # as DrawOrderProbe measures


## Rigs up to three levels down (layer > CharacterRigs > rig; layer > KingBodyView > KingRigs >
## rig), and Rivet's held weapon and magazine views.
func _collect(
	n: Node, depth: int, rigs: Array[CutRig], follow: Array[CanvasItem], cards: Array[Sprite2D]
) -> void:
	if n is Sprite2D and n.name == &"ghost_card":
		if (n as Sprite2D).is_visible_in_tree():
			cards.append(n as Sprite2D)
		return
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
		_collect(c, depth + 1, rigs, follow, cards)


func _follow(f: CanvasItem) -> void:
	if not _follow_base.has(f):
		_follow_base[f] = f.z_index
	var rig: CutRig = rig_of(f)
	f.z_index = _follow_base[f] + (rig.z_index if rig != null else 0)


## The rig a follower (Rivet's held weapon or reload magazine) rides; null for anything else.
static func rig_of(f: Node) -> CutRig:
	if f is RivetHeldView:
		var h: RivetHeldView = f as RivetHeldView
		return h.rigs.rig_for(h.rivet_id) if h.rigs != null else null
	if f is WeaponMagView:
		var m: WeaponMagView = f as WeaponMagView
		return m.rigs.rig_for(m.rivet_id) if m.rigs != null else null
	return null
