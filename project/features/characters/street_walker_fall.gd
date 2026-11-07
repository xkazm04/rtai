class_name StreetWalkerFall
extends RefCounted
## Lane n8 street: a dying walker's whole figure through StreetWalkerCards.DEATH_HOLD. FOLLOW (it6):
## the figure leans and shortens along the hidden parts' own head vector (feet -> head on screen),
## eased in, so at the swap the drawing lies where the parts' body lies. FOLLOW false = the it5
## topple: a fixed screen-x tip of DEATH_TIP, which jumped where the corpse lies north-south.

const FOLLOW: bool = true
## The it5 tip (rad at the swap) and the follow's limits (the figure's length, of standing).
const DEATH_TIP: float = 0.6
const MIN_LEN: float = 0.3
const MAX_LEN: float = 1.15
const LEN0: StringName = &"street_fall_len0"


## (rotation rad, the figure's length factor) for the rig now; (0, 1) when not dying in the hold.
static func pose(rig: CutRig, card: Sprite2D) -> Vector2:
	var r: HumanReact = rig.react
	var hold: float = StreetWalkerCards.DEATH_HOLD
	if r == null or not r.dying or hold <= 0.0:
		if card.has_meta(LEN0):
			card.remove_meta(LEN0)
		return Vector2(0.0, 1.0)
	var k: float = clampf(r.progress() / hold, 0.0, 1.0)
	var e: float = k * k
	var v: Vector2 = rig.head.global_position - rig.global_position
	if not FOLLOW:
		return Vector2(_side(rig, v.x) * DEATH_TIP * e, 1.0)
	if not card.has_meta(LEN0):
		card.set_meta(LEN0, maxf(v.length(), 1.0))
	var len0: float = card.get_meta(LEN0)
	var lean: float = atan2(v.x, -v.y) if v.length() > 1.0 else 0.0
	var length: float = clampf(v.length() / len0, MIN_LEN, MAX_LEN)
	return Vector2(lean * e, lerpf(1.0, length, e))


## The it5 side: toward where the hidden head is falling on screen, else away from the blow.
static func _side(rig: CutRig, fall: float) -> float:
	if absf(fall) > 1.0:
		return signf(fall)
	var blow: Vector2 = rig.react.dir.rotated(rig.facing)
	return signf(blow.x) if blow.x != 0.0 else 1.0
