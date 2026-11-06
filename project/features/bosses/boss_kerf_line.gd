class_name BossKerfLine
extends RefCounted
## Kerf's blink line on a boss's own bodies (bosses.json `kerf_line_m`, generic): every blink
## Kerf made since the last step also cuts each live body of the boss script (BossMoves.bodies():
## Servo's drones) within `kerf_line_m` (plus its radius) of the line, as Kerf's slice (weapon
## kerf_slice, the dry cauterised kill). 0 = the blink cuts its one target only (ghost_attacks.json
## path_cut_m stays the crowd-wide owner's call). Deterministic: reads the sim's blink trail.

## The newest blink tick already cut (the trail keeps the last few blinks).
var seen_tick: int = -1
var cuts: int = 0


## Cut along the blinks newer than `seen_tick`; returns how many bodies this step cut.
func step(stage: ArenaStage, fight: BossFight) -> int:
	var width: float = fight.spec.kerf_line_m
	var g: GhostPilot = stage.pilot.ghosts if stage.pilot != null else null
	if width <= 0.0 or g == null or g.kerf == null:
		return 0
	var k: KerfStage = g.kerf
	var n: int = 0
	for i: int in k.trail_tick.size():
		if k.trail_tick[i] <= seen_tick:
			continue
		seen_tick = k.trail_tick[i]
		n += _cut(stage.arena, fight.moves.bodies(), k.trail_from[i], k.trail_to[i], width)
	cuts += n
	return n


static func _cut(
	arena: CombatArena, bodies: Array[Fighter], a: Vector2, b: Vector2, w: float
) -> int:
	var n: int = 0
	var dir: Vector2 = (b - a).normalized()
	for f: Fighter in bodies:
		if not f.alive():
			continue
		var near: Vector2 = Geometry2D.get_closest_point_to_segment(f.pos, a, b)
		if f.pos.distance_to(near) > w + f.radius_m:
			continue
		arena.hit_dir = dir
		arena.hit_at = f.pos
		arena.damage(f, f.hp, arena.rivet.id, &"kerf_slice", KerfStage.KILL_KIND)
		n += 1
	return n
