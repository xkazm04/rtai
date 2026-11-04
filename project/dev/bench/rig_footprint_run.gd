class_name RigFootprintRun
extends RefCounted
## d5-cast: the measuring half of rig_footprint.gd (see there).

const PX_PER_M: float = 32.0
const TICKS: int = 90


static func measure(root: Node) -> Dictionary:
	var out: Dictionary = {}
	var cop: BodyPlan = RigPool.plan_of(BodyPlan.Kind.COP)
	var ped: BodyPlan = RigPool.plan_of(BodyPlan.Kind.PED)
	## n5-cast: one row per cast member the lineup draws, [plan, look].
	var rows: Dictionary[String, Array] = {
		"rivet": [RigPool.plan_of(BodyPlan.Kind.RIVET), RigVariant.rivet()],
		"cop": [cop, RigVariant.crowd(5)],
		"cop_riot": [cop, RigVariant.crowd(6)],
		"cop_swat": [cop, RigVariant.crowd(RigVariant.SWAT)],
		"ped": [ped, RigVariant.crowd(0)],
		"ped_jacket": [ped, RigVariant.crowd(1)],
		"ped_hoodie": [ped, RigVariant.crowd(3)],
		"king": [KingPlan.build(), RigVariant.rivet()],
	}
	for name: String in rows:
		var rig: CutRig = CutRig.new()
		root.add_child(rig)
		var plan: BodyPlan = rows[name][0]
		var look: RigVariant = rows[name][1]
		rig.setup(plan, look)
		for i: int in TICKS:
			rig.drive(1.0 / 60.0)
		var box: Rect2 = _bounds(rig, false)
		var torso: Rect2 = _bounds(rig, true)
		out[name] = {
			"length_m": snappedf(box.size.x / PX_PER_M, 0.01),
			"width_m": snappedf(box.size.y / PX_PER_M, 0.01),
			"torso_depth_m": snappedf(torso.size.x / PX_PER_M, 0.01),
			"shoulder_m": snappedf(torso.size.y / PX_PER_M, 0.01),
			"size_k": rig.plan.size_k,
		}
		rig.queue_free()
	return out


## torso_only: the torso part alone (its plan-view span across = the shoulder span).
static func _bounds(rig: CutRig, torso_only: bool) -> Rect2:
	var box: Rect2 = Rect2()
	var first: bool = true
	for spr: Sprite2D in rig.sprites:
		if not _shown(spr, rig) or spr.texture == null:
			continue
		if torso_only and spr != rig.torso_spr:
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
