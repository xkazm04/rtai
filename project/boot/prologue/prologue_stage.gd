class_name PrologueStage
extends ArenaStage
## Rivet may cross the factory threshold only once the last officer falls.
## Entry remains navigable for both police files.


func setup(ctx: WorldContext) -> void:
	super.setup(ctx)
	var combat: PrologueCombat = PrologueCombat.new(
		arena.tuning, ctx.events, ctx.rng.stream(&"combat")
	)
	combat.rivet = arena.rivet
	combat.guard_map = arena.guard_map
	combat.walls = walls
	arena = combat


func step(p_tick: int, tick_input: TickInput) -> void:
	var yard: PrologueYard = plan as PrologueYard
	var limit: float = yard.gate.y - arena.rivet.radius_m
	var from_y: float = arena.rivet.pos.y
	super.step(p_tick, tick_input)
	if not yard.exit_open and from_y < yard.gate.y:
		arena.rivet.pos.y = minf(arena.rivet.pos.y, limit)
