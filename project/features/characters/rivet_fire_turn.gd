class_name RivetFireTurn
extends RefCounted
## n17 rivet-strike (DEFECTS #10): the drawn fire cell (its painted flash and recoil) is held on
## the trigger's cooldown (RivetFrames.FIRE, FIRE_TICKS), whatever he does next; when he turned to
## another screen octant before it ran out, the new facing's fire cell flashed with no round
## (weapon:pistol at 64 px/m: the kill at t337, the camera fire cell flashing t339-340). The latch
## now holds only in the octant the last round left in; a new round (the recoil kick) re-seats it,
## so an automatic turning while it fires keeps its fire cells. `--rivet-fire-turn=keep`
## (CastFlags) = before. Render only.

const OCT: StringName = &"rivet_fire_oct"

static var enabled: bool = true


## True while the fire latch is up and holds for `rig`'s present octant.
static func held(rig: CutRig) -> bool:
	var latch: bool = rig.get_meta(RivetFrames.FIRE, false) == true
	var o: int = RivetFrames.oct_of(rig)
	if not latch or absf(rig.clips.recoil) > RivetFrames.FIRE_RECOIL:
		rig.set_meta(OCT, o)
	if not enabled:
		return latch
	var at: int = rig.get_meta(OCT, o)
	return latch and at == o
