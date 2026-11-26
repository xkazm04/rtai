class_name GhostN31Geometry
extends RefCounted
## n31 measure (dev only): Tonnage's footprint as a what-if. Half (main as shipped): foes at or
## ahead of the spot along the facing, within radius_m of spot + facing x ahead_m, the foe's body
## not added. Full: a disc of radius_m around the centre plus the foe's body radius, no facing
## test; at_rivet centres it on Rivet at the press tick instead of the deploy spot.

var radius_m: float = 4.0
var full: bool = false
var at_rivet: bool = false
var ahead_m: float = 0.9


func _init(p_radius: float, p_full: bool, p_at_rivet: bool, p_ahead: float) -> void:
	radius_m = p_radius
	full = p_full
	at_rivet = p_at_rivet
	ahead_m = p_ahead


## The shipped footprint: radius 4, half-disc, centred on the spot (ahead 0.9 m).
static func shipped(ahead: float, radius: float) -> GhostN31Geometry:
	return GhostN31Geometry.new(radius, false, false, ahead)


func centre(spot: Vector2, rivet: Vector2) -> Vector2:
	return rivet if full and at_rivet else spot


## `at` is the deploy spot for the half-disc and the centre() for the full circle.
func hits(at: Vector2, facing: Vector2, foe_pos: Vector2, foe_radius: float) -> bool:
	if full:
		return at.distance_to(foe_pos) <= radius_m + foe_radius
	if (foe_pos - at).dot(facing) < 0.0:
		return false
	return (at + facing * ahead_m).distance_to(foe_pos) <= radius_m


func label() -> String:
	if not full:
		return "half r%s" % str(radius_m)
	return "full r%s at %s" % [str(radius_m), "rivet" if at_rivet else "spot"]


func to_dict() -> Dictionary:
	return {
		"radius_m": radius_m,
		"shape": "full" if full else "half",
		"at": "rivet" if at_rivet else "spot",
		"label": label(),
	}
