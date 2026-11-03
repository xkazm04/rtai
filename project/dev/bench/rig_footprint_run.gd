class_name RigFootprintRun
extends RefCounted
## d5-cast: the measuring half of rig_footprint.gd (see there).

const PX_PER_M: float = 32.0
const TICKS: int = 90


static func measure(root: Node) -> Dictionary:
	var out: Dictionary = {}
	var kinds: Dictionary = {
		"rivet": BodyPlan.Kind.RIVET, "cop": BodyPlan.Kind.COP, "ped": BodyPlan.Kind.PED
	}
	for name: String in kinds:
		var kind: BodyPlan.Kind = kinds[name]
		var rig: CutRig = CutRig.new()
		root.add_child(rig)
		var look: RigVariant = RigVariant.rivet() if name == "rivet" else RigVariant.crowd(0)
		if name == "cop":
			look = RigVariant.crowd(5)
		rig.setup(RigPool.plan_of(kind), look)
		for i: int in TICKS:
			rig.drive(1.0 / 60.0)
		var box: Rect2 = _bounds(rig)
		out[name] = {
			"length_m": snappedf(box.size.x / PX_PER_M, 0.01),
			"width_m": snappedf(box.size.y / PX_PER_M, 0.01),
			"size_k": rig.plan.size_k,
		}
		rig.queue_free()
	return out


static func _bounds(rig: CutRig) -> Rect2:
	var box: Rect2 = Rect2()
	var first: bool = true
	for spr: Sprite2D in rig.sprites:
		if not _shown(spr, rig) or spr.texture == null:
			continue
		var r: Rect2 = spr.global_transform * spr.get_rect()
		box = r if first else box.merge(r)
		first = false
	return box


static func _shown(n: CanvasItem, rig: CutRig) -> bool:
	var c: Node = n
	while c != null and c != rig:
		if c is CanvasItem and not (c as CanvasItem).visible:
			return false
		c = c.get_parent()
	return true
