class_name FoeRocketPose
extends RefCounted


## Project the cop's aimed pose around the planted boots after the rig pool draws it.
static func pose(h: Fighter, rigs: CharacterRigs, i: int, looks: ArenaSquadLooks) -> void:
	looks.swing(h, rigs.feed, i)
	if h.archetype == &"rocket_trooper":
		_kneel.call_deferred(h, rigs)


static func _kneel(h: Fighter, rigs: CharacterRigs) -> void:
	if not is_instance_valid(rigs):
		return
	var rig: CutRig = rigs.rig_for(h.id)
	if rig == null:
		return
	var tucked: bool = h.alive() and h.tell_left > 0
	if tucked:
		rig.set_meta(&"rocket_kneel", true)
		var k: Vector2 = Vector2(1.32, 0.60)
		MotionRigPose.place(rig, Transform2D(0.0, k, 0.0, Vector2.ZERO))
	elif rig.has_meta(&"rocket_kneel"):
		rig.remove_meta(&"rocket_kneel")
		MotionRigPose.place(rig, Transform2D.IDENTITY)
