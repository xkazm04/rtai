class_name KerfBehind
extends RefCounted
## The primary slice can come from the back plate. Secondary cuts follow the travel direction.

var landing: Vector2
var hit_dir: Vector2
var path_dir: Vector2


static func resolve(
	stage: CollectCallStage, target: Fighter, behind_m: float, walls: ArenaWalls
) -> KerfBehind:
	var arena: CombatArena = stage.arena
	var from: Vector2 = arena.rivet.pos
	var reach: float = behind_m + target.radius_m
	var blink: KerfBehind = KerfBehind.new()
	blink.hit_dir = (target.pos - from).normalized()
	blink.path_dir = blink.hit_dir
	blink.landing = target.pos + blink.hit_dir * reach
	if not _front_blocks(arena, target, blink.hit_dir):
		return blink
	var spot: Vector2 = target.pos - target.facing * reach
	if not arena.squad_ai.pit.bounds.has_point(spot) or not _clear(stage, target.pos, spot, walls):
		return blink
	blink.landing = spot
	blink.hit_dir = target.facing
	blink.path_dir = from.direction_to(spot)
	arena.move_tally.record(MoveTable.BLINK_BEHIND)
	return blink


static func _front_blocks(arena: CombatArena, target: Fighter, ray: Vector2) -> bool:
	var squad: ArenaSquad = arena.squad_ai
	if squad == null or not squad.moves.kerf_blink_behind.enabled or not target.exposed:
		return false
	if FoeArmor.k(target, ray, KerfStage.KILL_KIND, squad, arena.tick) >= 1.0:
		return false
	var arch: EnemyRoster.Archetype = squad.pit.roster.archetype(target.archetype)
	return target.facing.dot(-ray) >= arch.shield_cos


static func _clear(
	stage: CollectCallStage, target: Vector2, spot: Vector2, walls: ArenaWalls
) -> bool:
	var rivet: Fighter = stage.arena.rivet
	if walls == null:
		walls = stage.arena.walls
	if walls != null:
		if walls.blocks(rivet.pos, spot) or walls.blocks(target, spot):
			return false
		if walls.push_out(spot, rivet.radius_m) != spot:
			return false
	return stage.cells == null or stage.cells.swept_clear(rivet.pos, spot, rivet.radius_m)
