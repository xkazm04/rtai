class_name RigFootprintRun
extends RefCounted
## d5-cast: the measuring half of rig_footprint.gd (see there).

const PX_PER_M: float = 32.0
const TICKS: int = 90


static func measure(root: Node) -> Dictionary:
	var out: Dictionary = {}
	var plans: Dictionary[String, BodyPlan] = {
		"rivet": RigPool.plan_of(BodyPlan.Kind.RIVET),
		"rivet_mild": RivetPlan.build(RivetPlan.FORM_MILD),
		"rivet_day": RivetPlan.build(RivetPlan.FORM_DAY),
		"cop": RigPool.plan_of(BodyPlan.Kind.COP),
		"ped": RigPool.plan_of(BodyPlan.Kind.PED),
		"king": KingPlan.build(),
		"king_1_2": KingPlan.build(1.2),
	}
	for name: String in plans:
		var rig: CutRig = CutRig.new()
		root.add_child(rig)
		var look: RigVariant = RigVariant.crowd(0)
		if name.begins_with("rivet") or name.begins_with("king"):
			look = RigVariant.rivet()
		elif name == "cop":
			look = RigVariant.crowd(5)
		rig.setup(plans[name], look)
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
