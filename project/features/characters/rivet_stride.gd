class_name RivetStride
extends RefCounted
## n10 world (the owner's "angle of movement"): a walk grid is drawn striding the way the figure
## faces and its row follows the aim, so a twin-stick strafe or backpedal walked the drawn legs
## across the ground. This is RigHips for a strip: past RigHips.BACKPEDAL_RAD the walk folds and
## the grid plays backwards, and the row turns toward the walk by at most TWIST_ROWS (a whole
## turn would point the drawn gun off the aim; the fire cells still draw the aim's own octant).

const OCT_RAD: float = PI * 0.25
## How far the legs' row may turn off the aim, in rows of 45 degrees; 0 = the row is the aim's.
const TWIST_ROWS: int = 1
## Rows past the halfway point a walk must lean before the row changes (a flicker guard).
const HOLD_ROWS: float = 0.25
## How far past the fold angle a walk must go to change between stepping forward and backward.
const FOLD_HOLD_RAD: float = deg_to_rad(15.0)
## The shortest time a turned row stays up: a reversal's frame of crossing never draws a row.
const DWELL_S: float = 0.1
const META_ROW: StringName = &"rivet_stride_row"
const META_AT: StringName = &"rivet_stride_at"
const META_BACK: StringName = &"rivet_stride_back"
## n11: how far past an octant's half-width the look must go before the drawn octant changes (a
## cursor resting on a boundary flipped the card every frame), and the octant last drawn.
const OCT_HOLD_RAD: float = deg_to_rad(4.0)
const OCT_AT: StringName = &"rivet_oct_at"
static var enabled: bool = true


## The drawn octant of the look (0 = screen right, +1 = 45 deg toward the camera): the aim the feed
## hands the rig, not the head (the facing spring lags it), held at the boundary.
static func oct_of(rig: CutRig) -> int:
	var a: float = rig.face_to
	var last: int = rig.get_meta(OCT_AT, -1)
	if last >= 0 and absf(angle_difference(a, last * OCT_RAD)) <= PI / 8.0 + OCT_HOLD_RAD:
		return last
	var o: int = posmod(roundi(a / OCT_RAD), 8)
	rig.set_meta(OCT_AT, o)
	return o


## The octant of the grid row drawn for a figure aiming along octant `o`. Below the hips' walking
## speed the row holds, so a reversal's one-tick stop does not snap it back to the aim.
static func row(rig: CutRig, o: int) -> int:
	if not enabled:
		return o
	var last: int = rig.get_meta(META_ROW, o)
	var held: int = wrapi(last - o, -4, 4)
	if absi(held) > TWIST_ROWS:
		held = 0
	if rig.vel_in.length() < RigHips.MOVE_PX_S:
		return posmod(o + held, 8)
	var rows: float = _folded(rig, o) / OCT_RAD
	var at: float = rig.get_meta(META_AT, -INF)
	var dwelt: bool = rig.t_alive - at >= DWELL_S
	if dwelt and absf(rows - held) > 0.5 + HOLD_ROWS:
		var turn: int = clampi(roundi(rows), -TWIST_ROWS, TWIST_ROWS)
		if turn != held:
			rig.set_meta(META_AT, rig.t_alive)
		held = turn
	var out: int = posmod(o + held, 8)
	rig.set_meta(META_ROW, out)
	return out


## +1 walks the grid forward, -1 backward (the walk is behind octant `o`: a backpedal).
static func direction(rig: CutRig, o: int) -> float:
	if not enabled or rig.vel_in.length() < RigHips.MOVE_PX_S:
		return 1.0
	return -1.0 if _backward(rig, _rel(rig, o)) else 1.0


static func _rel(rig: CutRig, o: int) -> float:
	return wrapf(rig.vel_in.angle() - o * OCT_RAD, -PI, PI)


static func _folded(rig: CutRig, o: int) -> float:
	var rel: float = _rel(rig, o)
	return wrapf(rel + PI, -PI, PI) if _backward(rig, rel) else rel


## The fold is latched so a strafe leaning back across the fold angle does not flip the row.
static func _backward(rig: CutRig, rel: float) -> bool:
	var was: bool = rig.get_meta(META_BACK, false)
	var limit: float = RigHips.BACKPEDAL_RAD + (-FOLD_HOLD_RAD if was else FOLD_HOLD_RAD)
	var back: bool = absf(rel) > limit
	rig.set_meta(META_BACK, back)
	return back
