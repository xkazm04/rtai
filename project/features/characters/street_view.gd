class_name StreetView
extends RefCounted
## Lane n8 street: the street cast's view-only steps under a tilt (CutRig.drive, after the head
## card). The riot shield's upright plate (RiotShieldCard), and the robot thug's steel lift: its
## dark gunmetal parts print as one solid ink mass at 32-48 px/m (n7 King REPORT); under a view row
## with card art each printed part's colour is scaled by THUG_LIFT before the print (the gang's
## x1.55 steel lift, gang_parts.py, done in the modulate, so the plates and joints separate. The
## head card draws raw and is not lifted). Straight down nothing here runs: `top` is unchanged.

## 1.0 = the dark thug (the before).
const THUG_LIFT: float = 1.55
const LIT: StringName = &"street_lit"


static func step(rig: CutRig) -> void:
	RiotShieldCard.step(rig)
	if rig.plan.art_dir == ThugPlan.ART_DIR and not rig.body.has_meta(LIT):
		_lift(rig)


static func _lift(rig: CutRig) -> void:
	if not ViewMode.shared().cards or ViewMode.shared().art.is_empty():
		return
	rig.body.set_meta(LIT, true)
	var c: Color = Color(THUG_LIFT, THUG_LIFT, THUG_LIFT)
	for n: Node in rig.find_children("*", "Sprite2D", true, false):
		var spr: Sprite2D = n as Sprite2D
		if spr != rig.head_card and spr.material is ShaderMaterial:
			spr.self_modulate = c
