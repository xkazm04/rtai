class_name RivetSwipe
extends RefCounted
## n11 (the owner's "melee attack follows always only one direction"): a strike's drawn cell only
## shows where its art points that way; elsewhere the figure keeps its facing cell and the game
## draws the swing's arc along the aim (RivetSwipeView). The claw cell (`rivet_frames` 11) is drawn
## reaching toward the camera, and a blade's FIRE_SIDE/FIRE_CAM cells along the side and camera.
## `enabled` false (--rivet-swipe=off) is the before: the one drawn cell in every direction.

## Octant 0 = screen right, +1 = 45 degrees toward the camera (RivetFrames.oct_of).
const CLAW_DRAWN: PackedByteArray = [0, 1, 1, 1, 0, 0, 0, 0]
const BLADE_DRAWN: PackedByteArray = [1, 0, 1, 0, 1, 0, 0, 0]

static var enabled: bool = true


static func claw_drawn(o: int) -> bool:
	return not enabled or CLAW_DRAWN[o] == 1


## The base strip's cell for a claw strike at octant `o`: the drawn reach, else the facing.
static func claw_cell(o: int, left: int) -> Vector2i:
	if claw_drawn(o):
		return Vector2i(RivetFrames.Cell.CLAW, left)
	return Vector2i(RivetFrames.BASE_OCT[o], 0)


static func blade_drawn(o: int) -> bool:
	return not enabled or BLADE_DRAWN[o] == 1


## True when the drawn cell has no swing of its own for this strike: bare claw off CLAW_DRAWN, or a
## blade whose held part is hidden (its strip draws the arc) off BLADE_DRAWN. A strip in
## RivetStrips.NO_ARC keeps its own held smear.
static func needs_arc(rig: CutRig, o: int) -> bool:
	if not enabled or not RivetFrames.drawn(rig) or rig.clips.strike_t < 0.0:
		return false
	var weapon: StringName = RivetFrames.weapon_of(rig)
	if weapon == &"":
		return RivetStrike.shows(rig.head_card) or not claw_drawn(o)
	return RivetStrips.hides_held(rig) and not blade_drawn(o)
