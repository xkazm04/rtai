class_name StreetView
extends RefCounted
## Lane n8 street: the street cast's view-only steps under a tilt (CutRig.drive, after the head
## card). The riot shield's upright plate (RiotShieldCard), the crowd's nine pedestrian types
## (StreetCrowdCards), the walkers' whole figures (StreetWalkerCards), and the robot thug's steel
## lift: its dark gunmetal parts print as one solid ink mass at 32-48 px/m (n7 King REPORT); under a
## view row with card art each printed part's colour is scaled by THUG_LIFT before the print (the
## gang's x1.55 steel lift, gang_parts.py, done in the modulate, so the plates and joints separate.
## The head card draws raw and is not lifted). Straight down nothing here runs: `top` is unchanged.

## 1.0 = the dark thug (the before).
const THUG_LIFT: float = 1.55
const LIT: StringName = &"street_lit"


static func step(rig: CutRig) -> void:
	RiotShieldCard.step(rig)
	StreetCrowdCards.step(rig)
	StreetWalkerCards.step(rig)
	RivetFrames.step(rig)  # d9 rivet: Rivet's whole figure
	if rig.plan.art_dir == ThugPlan.ART_DIR and not rig.body.has_meta(LIT):
		_lift(rig)


## After the react's post pose (CutRig.drive): a drawn fall is placed again, since the post turns
## the card's parent (a cop's head-and-chest card hangs under the turned torso: the 3/4-away
## corpse drew upright, it8). Alive, with no fall grid or straight down (no card), nothing.
static func post(rig: CutRig) -> void:
	var card: Sprite2D = rig.head_card
	if card != null and card.vframes == StreetWalkerFall.FALL_FRAMES and card.visible:
		StreetWalkerCards.place(rig, card)


## Hides what StreetWalkerCards.step hid; an item freed since (a part dropped mid-fall) is skipped,
## not assigned through a typed loop (102 SCRIPT ERRORs in quest 1 Dock 9 on view's trial merge).
static func hide_all(items: Array[CanvasItem]) -> void:
	for i: int in items.size():
		if is_instance_valid(items[i]):
			items[i].visible = false


static func _lift(rig: CutRig) -> void:
	if not ViewMode.shared().cards or ViewMode.shared().art.is_empty():
		return
	rig.body.set_meta(LIT, true)
	var c: Color = Color(THUG_LIFT, THUG_LIFT, THUG_LIFT)
	for n: Node in rig.find_children("*", "Sprite2D", true, false):
		var spr: Sprite2D = n as Sprite2D
		if spr != rig.head_card and spr.material is ShaderMaterial:
			spr.self_modulate = c
