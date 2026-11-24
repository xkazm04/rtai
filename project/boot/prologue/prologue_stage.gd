class_name PrologueStage
extends ArenaStage
## Rivet may cross the factory threshold only once the last officer falls.
## Entry remains navigable for both police files.

var at_receiver: bool = false
## Capture StagePilot's decoded edge before StageActions consumes a press near the phone.
var interacted: bool = false


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
	if at_receiver:
		tick_input = TickInput.new(tick_input.buttons & (1 << pilot.actions.bit(&"interact")))
	super.step(p_tick, tick_input)
	if not yard.exit_open and from_y < yard.gate.y:
		arena.rivet.pos.y = minf(arena.rivet.pos.y, limit)


func _move() -> void:
	interacted = intent.interact
	var combat: PrologueCombat = arena as PrologueCombat
	if combat.catcher != null:
		if (
			tick >= combat.pinned_until
			or not combat.catcher.alive()
			or pilot.motion.phase == PlayerMotion.Phase.ROLL
			or pilot.melee.busy()
		):
			combat.catcher = null
	for h: Fighter in combat.hostiles:
		if h.archetype == FoeWardenCardView.ID:
			FoeWardenCardView.set_catch(h, h == combat.catcher, tick)
	if at_receiver or combat.catcher != null:
		intent.move_by = Vector2.ZERO
		intent.move_to = Vector2.INF
	super._move()
