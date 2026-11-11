class_name RivetFireTurn
extends RefCounted
## n17 rivet-strike (DEFECTS #10): the drawn fire cell (its painted flash and recoil) is held on
## the trigger's cooldown (RivetFrames.FIRE, FIRE_TICKS), whatever he does next; when he turned to
## another screen octant before it ran out, the new facing's fire cell flashed with no round
## (weapon:pistol at 64 px/m: the kill at t337, the camera fire cell flashing t339-340). The latch
## now holds only in the octant the last round left in; a new round (the recoil's rise) re-seats it,
## so an automatic turning while it fires keeps its fire cells. `--rivet-fire-turn=keep`
## (CastFlags) = before. Render only.

const OCT: StringName = &"rivet_fire_oct"
const KICK: StringName = &"rivet_fire_kick"

static var enabled: bool = true


## The fire latch (the recoil kick still up, or the trigger's FIRE_TICKS) for `rig`'s present
## octant: a round re-seats it (the kick rises), a turn with no new round drops it.
static func latched(rig: CutRig) -> bool:
	var kick: float = absf(rig.clips.recoil)
	var last: float = rig.get_meta(KICK, 0.0)
	rig.set_meta(KICK, kick)
	var latch: bool = (
		kick > RivetFrames.FIRE_RECOIL or rig.get_meta(RivetFrames.FIRE, false) == true
	)
	var o: int = RivetFrames.oct_of(rig)
	if not latch or kick > last + 0.01:
		rig.set_meta(OCT, o)
	if not enabled:
		return latch
	var at: int = rig.get_meta(OCT, o)
	return latch and at == o
