class_name TonnageCrack
extends RefCounted
## One timestamp identifies both the open interval and the stomp that spent its opening.


static func post_stomp(mind: SquadMind) -> bool:
	return (
		mind != null
		and mind.walker != null
		and mind.agent.state == EnemyAgent.State.RECOVER
		and mind.walker.attack != null
		and mind.walker.attack.melee
	)


static func on_hit(arena: CombatArena, h: Fighter, killer: int, weapon: StringName) -> void:
	var squad: ArenaSquad = arena.squad_ai
	if squad == null or not squad.moves.tonnage_armour_crack.enabled:
		return
	if killer != arena.rivet.id or weapon not in [&"stomp", &"stomp_wave", &"ram"]:
		return
	var mind: SquadMind = squad.minds.get(h.id)
	if not post_stomp(mind) or mind.walker.cracked_at >= mind.agent.shot_tick:
		return
	mind.walker.cracked_at = arena.tick
	arena.move_tally.record(MoveTable.ARMOUR_CRACK)


static func is_open(mind: SquadMind, row: MoveTable.ArmourCrack, tick: int) -> bool:
	if not row.enabled or mind == null or mind.walker == null:
		return false
	var opened: int = mind.walker.cracked_at
	return opened >= 0 and tick < opened + row.open_ticks


static func write_state(arena: CombatArena, h: Fighter, out: StreamPeerBuffer) -> void:
	var squad: ArenaSquad = arena.squad_ai
	if h.archetype != &"war_machine" or squad == null:
		return
	var row: MoveTable.ArmourCrack = squad.moves.tonnage_armour_crack
	var mind: SquadMind = squad.minds.get(h.id)
	if not row.enabled or mind == null or mind.walker.cracked_at < 0:
		return
	# A long recovery can outlast a short configured duration and still be spent.
	if (
		is_open(mind, row, arena.tick)
		or (post_stomp(mind) and mind.walker.cracked_at >= mind.agent.shot_tick)
	):
		out.put_32(mind.walker.cracked_at)
