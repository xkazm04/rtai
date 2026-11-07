class_name RivetWalk
extends RefCounted
## d9 rivet (Call 2): bare-claw Rivet's drawn 4-frame stride, when the art key has one
## (`rivet_walk.png`, tools/art/rivet_walk.py: 4 frames x 8 rows in RivetFrames' base cell order).
## Picked by the stride phase while he walks with no weapon out; a drawn stride carries no built
## bob or sway. --rivet-walk=bob keeps the facing card with the bob (the before).

const STRIP: String = "rivet_walk.png"
const FRAMES: int = 4
const ROWS: int = 8
static var enabled: bool = true


## The walk grid under `art`, "" when it is off, the art has none, or he is not walking bare-claw.
static func path_of(rig: CutRig, art: String, weapon: StringName) -> String:
	if not enabled or weapon != &"" or rig.speed_now <= RivetFrames.MOVING:
		return ""
	if rig.dead or rig.clips.rolling() or rig.clips.hit_t > 0.0 or rig.clips.strike_t >= 0.0:
		return ""
	if rig.clips.active() == RigClips.Clip.PUNCH:
		return ""
	var path: String = RivetStrips.DIR + art + "/" + STRIP
	return path if ResourceLoader.exists(path) else ""


## The grid frame for octant `o` at stride phase `phase` (one cycle = a full stride, two steps).
static func frame_of(o: int, phase: float) -> int:
	var col: int = mini(int(fposmod(phase, 1.0) * FRAMES), FRAMES - 1)
	return RivetFrames.BASE_OCT[o] * FRAMES + col
