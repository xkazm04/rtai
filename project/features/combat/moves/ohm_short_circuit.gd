class_name OhmShortCircuit
extends RefCounted
## Every bolt applies electro stun. A flagged machine can also take a short circuit.
## Its exclusive stun and immunity deadlines both run from the bolt's release tick.


static func strike(arena: CombatArena, h: Fighter, tick: int, legacy_ticks: int) -> bool:
	PlayerShock.stun_on(PlayerShock.areas_of(arena), h, legacy_ticks)
	return short_machine(arena, h, tick)


static func short_machine(arena: CombatArena, h: Fighter, tick: int) -> bool:
	var squad: ArenaSquad = arena.squad_ai
	if squad != null and squad.moves.ohm_short_circuit.enabled and squad.owns(h):
		var arch: EnemyRoster.Archetype = squad.pit.roster.archetype(h.archetype)
		if arch.machine:
			return _apply(squad.mind_for(h), h, tick, squad.moves.ohm_short_circuit)
	return false


static func _apply(mind: SquadMind, h: Fighter, tick: int, row: MoveTable.ShortCircuit) -> bool:
	if tick < mind.immune_until:
		return false
	var duration: int = row.boss_stun_ticks if mind.walker != null else row.stun_ticks
	mind.stun_until = tick + duration
	mind.immune_until = tick + row.immune_ticks
	var agent: EnemyAgent = mind.agent
	agent.token = false
	agent.vel = Vector2.ZERO
	h.tell_left = 0
	h.swing_left = 0
	if mind.turret != null:
		mind.turret.phase = FoeTurret.Phase.IDLE
	if mind.shield != null:
		mind.shield.lunge_left = 0
	if agent.state in [EnemyAgent.State.WINDUP, EnemyAgent.State.FIRE]:
		agent.enter(EnemyAgent.State.ENGAGE)
	return true


static func held(squad: ArenaSquad, h: Fighter) -> bool:
	var mind: SquadMind = squad.minds.get(h.id)
	return mind != null and squad.pit.tick < mind.stun_until


static func write_state(squad: ArenaSquad, h: Fighter, out: StreamPeerBuffer) -> void:
	if squad == null:
		return
	var mind: SquadMind = squad.minds.get(h.id)
	if mind != null and mind.stun_until > 0:
		out.put_32(mind.stun_until)
		out.put_32(mind.immune_until)
