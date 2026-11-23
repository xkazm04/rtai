class_name StreetPatrolPose
extends RefCounted
## Sole and upper-body points in the cut PNG. A held drawing rolls slightly over its
## planted boot between pose centres. The airborne run passes translate as a whole.
const MAX_LEAN: float = 0.22
const MAX_STRETCH: float = 0.12

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
	if path.get_file() == StreetMulroneyAnchors.EIGHT:
		marks = StreetMulroneyAnchors.WALK55 if low else StreetMulroneyAnchors.WALK70
		return StreetMulroneyAnchors.STEP_M
	if running:
		marks = StreetPatrolAnchors.RUN55 if low else StreetPatrolAnchors.RUN70
		return StreetPatrolAnchors.RUN_M
	marks = StreetPatrolAnchors.WALK55 if low else StreetPatrolAnchors.WALK70
	return StreetPatrolAnchors.WALK_M


func pose(
	at: Vector2, index: int, facing: Vector2i, scale_px: Vector2, fraction: float
) -> Transform2D:
	face = facing.x
	row = posmod(index, count)
	texel = Vector2(-scale_px.x if facing.y else scale_px.x, scale_px.y)
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
	return stride * floorf(float(phase) / half) + delta * texel
