class_name StreetPatrolPose
extends RefCounted
## Sole and upper-body points in the cut PNG. A held drawing rolls slightly over its
## planted boot between pose centres. The airborne run passes translate as a whole.
const MAX_LEAN: float = 0.22
const MAX_STRETCH: float = 0.12

## On the sergeant sheet the drawn touchdown is near the pelvis. Centre the ground
## contact on the stance interval so his moving hip shadow crosses the planted boot.
var centre_stance: bool
var previous_body: Vector2
var stance_shift: Vector2
var new_stance: bool
var landing: Vector2
var marks: Array[Vector4]
var flight: bool
var count: int
var half: int
var row: int
var face: int
var texel: Vector2
var stride: Vector2


func configure(path: String, drawings: int, running: bool) -> float:
	count = drawings
	half = drawings >> 1
	flight = running
	var low: bool = path.get_base_dir().get_file() == "p55"
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
	at += landing
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
	var delta: Vector2 = Vector2(first.x - ink.x + ink.z, first.y - ink.y + ink.w)
	if centre_stance:
		var left: Vector4 = marks[face * count]
		var right: Vector4 = marks[face * count + half]
		delta -= Vector2(left.x + right.x, left.y + right.y) * 0.5
	return stride * floorf(float(phase) / half) + delta * texel


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
		new_stance = false
	placed.origin += stance_shift
	var roll: Vector2 = (body - placed * local) / (ink.w - ink.y)
	placed.y += roll
	placed.origin -= roll * ink.y
	return placed
