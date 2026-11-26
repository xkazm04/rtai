class_name DentLane
extends RefCounted
## n31 ghost 15 (the owner: no placement marker, a short wind-up, then the ram). Dent's ram lane
## runs from Rivet's side along the aim to the spot. A hold-mode row lays it at the release; a
## drop-mode row lays it on the press and keeps it through the wind-up (a foe can step out).


## Lay the lane from Rivet's side along the ghost's facing to its spot, both wall-clipped; the
## facing follows the lane. False when the lane has no length (nothing is rammed).
static func lay(stage: CollectCallStage, ghost: GhostDeploy) -> bool:
	var rivet: Fighter = stage.arena.rivet
	var side: Vector2 = ghost.facing.orthogonal() * rivet.radius_m
	ghost.origin = GhostDeploySpot.clip(stage, rivet.pos, rivet.pos + side)
	ghost.spot = GhostDeploySpot.clip(stage, ghost.origin, ghost.spot)
	var dir: Vector2 = ghost.origin.direction_to(ghost.spot)
	if dir == Vector2.ZERO:
		return false
	ghost.facing = dir
	return true


## An exposed live hostile within half_m of the lane: its centre (hold), or its body (drop:
## the foe's radius counts, as in Tonnage's circle).
static func reaches(foe: Fighter, from: Vector2, to: Vector2, half_m: float, body: bool) -> bool:
	if not foe.alive() or not foe.exposed:
		return false
	var near: Vector2 = Geometry2D.get_closest_point_to_segment(foe.pos, from, to)
	return near.distance_to(foe.pos) <= half_m + (foe.radius_m if body else 0.0)
