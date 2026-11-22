class_name GhostDeploySpot
extends RefCounted
## Deployment uses the thrown weapon's cursor reach. Clip the entire segment so a cursor
## beyond a thin wall stays on the near side. An unobstructed segment needs one test.


static func clip(stage: CollectCallStage, from: Vector2, to: Vector2) -> Vector2:
	if clear(stage, from, to):
		return to
	var near: Vector2 = from
	var far: Vector2 = to
	for _i: int in 12:
		var mid: Vector2 = (near + far) * 0.5
		if clear(stage, from, mid):
			near = mid
		else:
			far = mid
	return near


static func clear(stage: CollectCallStage, from: Vector2, to: Vector2) -> bool:
	if stage.arena.walls != null and stage.arena.walls.blocks(from, to):
		return false
	return stage.cells == null or stage.cells.swept_clear(from, to, ArenaWalls.FACE_NUDGE_M)


## Prefer the nearest body to the cursor. Otherwise take the nearest to the forward aim
## line in Kerf's existing targeting cone. Stable hostile order breaks equal distances.
static func kerf_target(
	stage: CollectCallStage, spot: Vector2, facing: Vector2, attacks: GhostAttacks
) -> Fighter:
	var row: GhostAttacks.DeployRow = attacks.deploy[KerfStage.GHOST]
	var cone: float = deg_to_rad(attacks.num(KerfStage.GHOST, &"cone_deg"))
	var from: Vector2 = stage.arena.rivet.pos
	var snap: Fighter = null
	var line: Fighter = null
	var snap_dist: float = INF
	var line_dist: float = INF
	for foe: Fighter in stage.arena.hostiles:
		var to: Vector2 = foe.pos - from
		if not foe.alive() or to.length() > row.range_m or not clear(stage, from, foe.pos):
			continue
		var distance: float = foe.pos.distance_to(spot)
		if distance <= row.snap_m and distance < snap_dist:
			snap = foe
			snap_dist = distance
		var off_line: float = absf(facing.cross(to))
		if absf(facing.angle_to(to)) <= cone and off_line < line_dist:
			line = foe
			line_dist = off_line
	return snap if snap != null else line
