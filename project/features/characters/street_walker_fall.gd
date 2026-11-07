class_name StreetWalkerFall
extends RefCounted
## Lane n8 street: a dying walker's whole figure through StreetWalkerCards.DEATH_HOLD. FOLLOW (it6):
## the figure leans and shortens along the hidden parts' own head vector (feet -> head on screen),
## eased in, so at the swap the drawing lies where the parts' body lies. FOLLOW false = the it5
## topple: a fixed screen-x tip of DEATH_TIP, which jumped where the corpse lies north-south.
## DRAWN (it7): a row with a drawn fall grid (FALLS) keeps its figure through the whole death: it
## buckles, falls and lies along the blow (the facing whose fall points that way, mirrored as the
## head cards are), and the lying frame is the corpse. No swap to the parts, so no jump.

const FOLLOW: bool = true
## The it5 tip (rad at the swap) and the follow's limits (the figure's length, of standing).
const DEATH_TIP: float = 0.6
const MIN_LEN: float = 0.3
const MAX_LEN: float = 1.15
const LEN0: StringName = &"street_fall_len0"
## DRAWN false = the hold and the follow for every row (it6).
const DRAWN: bool = true
## view art -> card row -> fall grid (5 facings across, 3 frames down: buckle, mid-fall, lying;
## tools/art/street_fall.py, the feet at the cell centre, the still strip's px per metre).
const FALLS: Dictionary[String, Dictionary] = {
	"p70":
	{
		"ped/head_hair": "ped_suit_fall.png",
		"ped/head_hood": "ped_hood_fall.png",
		"ped/head_worker": "ped_worker_fall.png",
		"ped/head_cap": "ped_cap_fall.png",
		"ped/head_bald": "ped_elder_fall.png",
		"ped/head_hat": "ped_hat_fall.png",
		"ped/head_jogger": "ped_jogger_fall.png",
		"ped/head_punk": "ped_punk_fall.png",
		"ped/head_shopper": "ped_shopper_fall.png",
	},
}
const FALL_FRAMES: int = 3
## Each fall frame's start, of the death family's progress (the lying frame from FALL_AT[2] on).
const FALL_AT: PackedFloat32Array = [0.0, 0.18, 0.4]
## The px a standing figure of HEIGHT_M is drawn in the grid (the still strip's cell height).
const STILL_PX: float = 192.0
const OCT: StringName = &"street_fall_oct"


## The fall grid the person draws now ("" = none: alive, the row has none, or DRAWN off).
static func grid_of(rig: CutRig, art: String, row: String) -> String:
	if not DRAWN or not down(rig):
		return ""
	var rows: Dictionary = FALLS.get(art, {})
	return str(rows.get(row, ""))


## Dying or dead.
static func down(rig: CutRig) -> bool:
	return rig.dead or (rig.react != null and rig.react.dying)


## The fall frame for a death progress (the last frame once the family is over).
static func fall_frame(progress: float) -> int:
	var f: int = 0
	for i: int in FALL_AT.size():
		if progress >= FALL_AT[i]:
			f = i
	return f


## Faces, frames and sizes a fall grid card (s: the still's scale for this person; the corpse
## decay's sink read back from the rig, as CorpseFade shrinks the parts).
static func draw(rig: CutRig, card: Sprite2D, s: float) -> void:
	var r: HumanReact = rig.react
	if not card.has_meta(OCT):
		var blow: Vector2 = r.dir.rotated(rig.facing) if r != null else Vector2.DOWN
		card.set_meta(OCT, RigHeadCard.frame_of(blow.angle()))
	var f: Vector2i = card.get_meta(OCT)
	var p: float = r.progress() if r != null and r.dying else 1.0
	card.frame_coords = Vector2i(f.x, fall_frame(p))
	card.flip_h = f.y == 1
	var sink: float = absf(rig.scale.x) / maxf(CutRig.SC * rig.plan.size_k, 0.0001)
	var k: float = s * minf(sink, 1.0)
	card.global_rotation = 0.0
	card.global_scale = Vector2(k, k)
	card.global_position = rig.global_position


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
