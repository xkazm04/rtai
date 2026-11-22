class_name BotArenaMoves
extends RefCounted
## Observe the same squad windows and landing checks that will resolve the attack.
## KerfBehind.resolve records a use, so prediction uses its read-only predicates.


static func observe(
	stage: ArenaStage, h: Fighter, foe: BotView.Hostile, me: BotView.Player
) -> void:
	var arena: CombatArena = stage.arena
	var squad: ArenaSquad = arena.squad_ai
	if squad == null or stage.pilot == null or not h.exposed:
		return
	var mind: SquadMind = squad.minds.get(h.id)
	if mind == null:
		return
	var ray: Vector2 = me.pos.direction_to(h.pos)
	var distance: float = me.pos.distance_to(h.pos)
	var moves: MoveTable = squad.moves
	if moves.tonnage_armour_crack.enabled and h.archetype == &"war_machine":
		foe.cracked = TonnageCrack.is_open(mind, moves.tonnage_armour_crack, arena.tick)
		foe.can_crack = (
			TonnageCrack.post_stomp(mind) and mind.walker.cracked_at < mind.agent.shot_tick
		)
	if moves.ohm_short_circuit.enabled and mind.agent.arch.machine:
		foe.short_held = OhmShortCircuit.held(squad, h)
		var ohm: OhmStage = stage.pilot.ohm
		foe.can_short = (
			(me.form == &"ohm" or me.forms.has(&"ohm"))
			and not foe.short_held
			and mind.immune_until <= arena.tick
			and distance > 0.01
			and distance <= ohm.num(&"range_m")
			and absf(me.facing.angle_to(ray)) < deg_to_rad(ohm.num(&"cone_deg"))
			and not stage.walls.blocks(me.pos, h.pos)
		)
	if moves.kerf_blink_behind.enabled and (me.form == &"kerf" or me.forms.has(&"kerf")):
		var kerf: KerfStage = stage.pilot.kerf
		if distance > kerf.num(&"range_m") or not KerfBehind._front_blocks(arena, h, ray):
			return
		var spot: Vector2 = h.pos - h.facing * (kerf.num(&"behind_m") + h.radius_m)
		foe.can_blink = (
			squad.pit.bounds.has_point(spot)
			and KerfBehind._clear(stage, h.pos, spot, stage.walls)
			and kerf.pick(stage, ray) == h
		)
