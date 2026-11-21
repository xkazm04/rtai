class_name FoeRocketPose
extends RefCounted


## The cop rig has no kneeling clip. Compress its aimed pose around the planted boots
## using the same projection as the cover crouch, after the rig pool has drawn this frame.
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
		var k: Vector2 = CoverView.scale_for(0.78, 1.0, ViewMode.shared().is_flat())
		MotionRigPose.place(rig, Transform2D(0.0, k, 0.0, Vector2.ZERO))
	elif rig.has_meta(&"rocket_kneel"):
		rig.remove_meta(&"rocket_kneel")
		MotionRigPose.place(rig, Transform2D.IDENTITY)
