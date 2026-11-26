class_name StreetPatrolPose
extends RefCounted
## Sole and upper-body points in the cut PNG. A held drawing rolls slightly over its
## planted boot between pose centres. The airborne run passes translate as a whole.
const MAX_LEAN: float = 0.22
const MAX_STRETCH: float = 0.12
## n31-09: every anchored walk lands half a stance ahead, in every direction, after the settle
## easing, so the mid-point between the soles is the sim ground point where the contact discs draw.
## false = the old placement (centre-stance kinds only, walking up clamped to a quarter, applied
## before the easing): the disc runs 0..21 px ahead of the planted boot each stance.
const LAND_MID_STANCE: bool = true
const LANDING_EASE: float = 0.06
## n31-10: the footfall shortening keeps only its part across the travel. Along the travel
## it compounded (the eased body carries the last stance's shift into the next): 3.4 px a
## stance walking up, to the 14.4 px limit. false = the old shift, the planted sole up to
## 14 px off the disc walking N.
const SHIFT_ACROSS_TRAVEL: bool = true
## n31-10: on a walk's toe-off drawings the marked sole is the lifting planted heel, 15-46 cell
## px above the foot line, while the other boot already stands on it (cell alpha bottom 0..2).
## Registering that heel to the ground dropped the whole drawing (patrol side walk: the head
## pumped 8 px a stride). A side-view walk mark higher than TOE_OFF_PX registers on the foot
## line instead. false = the old registration. Runs keep every mark (lifted = the flight). The
## toward/away and three-quarter columns keep it: their screen vertical is also the travel, and
## the drop there stands in for the step forward the drawing lacks (held: S head travel 9 -> 15).
const HOLD_TOE_OFF: bool = true
const TOE_OFF_PX: float = 13.0
const SIDE_COLUMN: int = 2
## n31-13: a walk column that draws no forward step (S, N and the three-quarter columns) GLIDES:
## the stance origin follows the sim point every tick (mid-stance = the sim point), every mark
## registers on the foot line, so the head shows the drawn bob only, not a held stance then a
## jump (head travel 1.4-2.9 px, from 10-36 px; the boot skates the stance, 22-33 px). false =
## the foot lock on every column.
const GLIDE_NO_STEP: bool = true
## n31-15: how far a gliding column follows the sim point: 1.0 = the full glide, 0.0 = the foot
## lock; between, the stand point, the stride and the registered sole blend linearly.
const GLIDE_SHARE: float = 1.0

## On the sergeant sheet the drawn touchdown is near the pelvis. Centre the ground
## contact on the stance interval so his moving hip shadow crosses the planted boot.
var centre_stance: bool
var previous_body: Vector2
var stance_shift: Vector2
var new_stance: bool
var landing: Vector2
var eased_landing: Vector2
var marks: Array[Vector4]
var flight: bool
var count: int
var half: int
var row: int
var face: int
var texel: Vector2
var stride: Vector2
var glide_no_step: bool = GLIDE_NO_STEP
var glide_share: float = GLIDE_SHARE


func configure(path: String, drawings: int, running: bool) -> float:
	count = drawings
	half = drawings >> 1
	flight = running
	var low: bool = path.get_base_dir().get_file() == "p55"
	var foe: Array[Vector4] = CastCardKinds.foe_marks(path.get_file(), low)
	if not foe.is_empty():
		centre_stance = CastCardKinds.CENTRE_STANCE
		marks = foe
		return CastCardKinds.foe_step(path.get_file())
	if path.get_file() == CastWardenAnchors.EIGHT:
		centre_stance = true
		marks = CastWardenAnchors.WALK55 if low else CastWardenAnchors.WALK70
		return CastWardenAnchors.STEP_M
	if path.get_file() == StreetMulroneyAnchors.EIGHT:
		centre_stance = true
		marks = StreetMulroneyAnchors.WALK55 if low else StreetMulroneyAnchors.WALK70
		return StreetMulroneyAnchors.STEP_M
	if running:
		marks = StreetPatrolAnchors.RUN55 if low else StreetPatrolAnchors.RUN70
		return StreetPatrolAnchors.RUN_M
	marks = StreetPatrolAnchors.WALK55 if low else StreetPatrolAnchors.WALK70
	return StreetPatrolAnchors.WALK_M


func touchdown(travel: Vector2, distance: float) -> void:
	new_stance = true
	stance_shift = Vector2.ZERO
	if LAND_MID_STANCE:
		landing = travel * distance * 0.5
		return
	if not centre_stance:
		return
	landing = travel * distance * 0.5
	# The upper edge of the flattened hip shadow is closer than its lateral edge.
	landing.y = maxf(landing.y, -distance * 0.25)


func pose(
	at: Vector2, index: int, facing: Vector2i, scale_px: Vector2, fraction: float
) -> Transform2D:
	face = facing.x
	row = posmod(index, count)
	texel = Vector2(-scale_px.x if facing.y else scale_px.x, scale_px.y)
	at += Vector2.ZERO if LAND_MID_STANCE else landing
	var phase: int = posmod(row, half)
	var centre: Vector2 = _knot(phase)
	var offset: float = fraction - 0.5
	var neighbour: Vector2 = _knot(phase + (1 if offset > 0 else -1))
	var body: Vector2 = centre.lerp(neighbour, absf(offset))
	var ink: Vector4 = marks[face * count + row]
	var torso: Vector2 = Vector2(ink.z, ink.w)
	var basis_x: Vector2 = Vector2.RIGHT * scale_px.x
	var basis_y: Vector2 = Vector2.DOWN * scale_px.y
	if flight and phase == half - 1:
		return Transform2D(basis_x, basis_y, at + body - torso * texel)
	# Pivot the column through the body about the load-bearing sole. Horizontal ink
	# stays horizontal. Limit the lean and stretch, including on an abrupt reversal.
	var roll: Vector2 = (body - centre) / (ink.w - ink.y)
	var limit: Vector2 = Vector2(MAX_LEAN, MAX_STRETCH) * scale_px
	roll = roll.clamp(-limit, limit)
	return Transform2D(basis_x, basis_y + roll, at + centre - torso * texel - roll * ink.y)


func _knot(phase: int) -> Vector2:
	if flight and posmod(phase, half) == half - 1:
		return (_ground(phase - 1) + _ground(phase + 1)) * 0.5
	return _ground(phase)


func _ground(phase: int) -> Vector2:
	var start: int = row - posmod(row, half)
	var draw: int = posmod(start + phase, count)
	var first: Vector4 = marks[face * count + draw - posmod(draw, half)]
	var ink: Vector4 = marks[face * count + draw]
	var delta: Vector2 = Vector2(first.x - ink.x + ink.z, foot_y(first.y) - foot_y(ink.y) + ink.w)
	if centre_stance:
		var left: Vector4 = marks[face * count]
		var right: Vector4 = marks[face * count + half]
		delta -= Vector2(left.x + right.x, foot_y(left.y) + foot_y(right.y)) * 0.5
	return stride * floorf(float(phase) / half) + delta * texel


## The sole height a mark registers at (HOLD_TOE_OFF, GLIDE_NO_STEP).
func foot_y(sole_y: float) -> float:
	if glides(face):
		return sole_y * (1.0 - glide_share)
	var side: bool = HOLD_TOE_OFF and not flight and face == SIDE_COLUMN
	return 0.0 if side and sole_y < -TOE_OFF_PX else sole_y


## Where the stance stands (and its stride): a gliding column on the sim point, less the eased
## landing settle adds back; any other on the locked stance origin.
func stand_at(origin: Vector2, at: Vector2, step: Vector2, column: int) -> Vector2:
	if not glides(column):
		stride = step * half
		return origin
	stride = step * half * (1.0 - glide_share)
	return origin.lerp(at - eased_landing, glide_share)


## A walk drawn in this column glides with the sim point instead of locking its boot.
func glides(column: int) -> bool:
	return glide_no_step and not flight and column != SIDE_COLUMN


## A strafe can hand over between opposing drawn leads while the aim stays fixed.
## Roll about this drawing's planted boot as the torso catches up. Both the new
## foothold and the destination torso remain registered to the actor on every stance.
func settle(placed: Transform2D, ppm: float, continuous: bool) -> Transform2D:
	var ink: Vector4 = marks[face * count + row]
	var local: Vector2 = Vector2(-ink.z if texel.x < 0.0 else ink.z, ink.w)
	var target: Vector2 = placed * local + stance_shift
	var body: Vector2 = previous_body.move_toward(target, ppm * 0.30) if continuous else target
	previous_body = body
	if new_stance:
		# Shorten this particular footfall to the reachable point. Keep its sole fixed
		# until lift, and limit the correction so the figure never drifts from its rig.
		stance_shift = (body - target).limit_length(ppm * 0.45)
		if SHIFT_ACROSS_TRAVEL and LAND_MID_STANCE and not landing.is_zero_approx():
			var along: Vector2 = landing.normalized()
			stance_shift -= along * stance_shift.dot(along)
		new_stance = false
	placed.origin += stance_shift
	var roll: Vector2 = (body - placed * local) / (ink.w - ink.y)
	placed.y += roll
	placed.origin -= roll * ink.y
	# Past the easing: the body ease and stance shift would otherwise take the landing back. Eased
	# (LANDING_EASE ppm per tick) so a reversal does not jump the figure a whole stance.
	var reach: float = ppm * LANDING_EASE if continuous else INF
	eased_landing = eased_landing.move_toward(landing, reach)
	placed.origin += eased_landing if LAND_MID_STANCE else Vector2.ZERO
	return placed
