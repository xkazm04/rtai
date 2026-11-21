class_name PlayerGuardInput
extends RefCounted
## Apply the stance to this tick's decoded command before the pilot moves or starts an attack.


static func prepare(pilot: StagePilot, stage: CollectCallStage, c: PlayerCommand) -> void:
	var arena: CombatArena = stage.arena
	var g: PlayerGuard = pilot.guard
	arena.guard = g
	var roll: bool = pilot.motion.can_roll() and c.was_pressed(pilot.actions, &"roll")
	g.step(c.is_held(pilot.actions, &"guard"), available(pilot, arena) and not roll)
	if not g.blocks_attack():
		return
	stage.intent.fire_at = Vector2.INF
	var mask: int = (
		(1 << pilot.actions.bit(&"sprint"))
		| (1 << pilot.actions.bit(&"melee"))
		| (1 << pilot.actions.bit(&"fire"))
	)
	c.held &= ~mask
	c.pressed &= ~mask
	pilot.melee.combo.cancel()
	pilot.shock.shock.held = false
	pilot.shock.shock.charge = 0
	pilot.throw.wound = -1
	if g.up() and c.aim == Vector2.ZERO:
		c.aim = arena.rivet.facing


static func available(pilot: StagePilot, arena: CombatArena) -> bool:
	return (
		arena.rivet.alive()
		and pilot.motion.phase not in [PlayerMotion.Phase.ROLL, PlayerMotion.Phase.VAULT]
		and pilot.motion.cover.spot == null
		and (
			pilot.ghosts == null
			or (pilot.ghosts.forms.settled() and pilot.ghosts.forms.current() == GhostForms.BASE)
		)
	)
