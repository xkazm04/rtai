class_name BotArenaFoe
extends RefCounted
## Project a live fighter and its visible windup or discharge into the pilot view.


static func read(fighter: Fighter, arena: CombatArena) -> BotView.Hostile:
	var foe: BotView.Hostile = BotView.Hostile.new()
	foe.id = fighter.id
	foe.pos = fighter.pos
	foe.radius = fighter.radius_m
	foe.facing = fighter.facing
	foe.archetype = fighter.archetype if fighter.archetype != &"" else &"contractor"
	foe.alive = fighter.alive()
	foe.hp = fighter.hp
	foe.robot = fighter.machine
	foe.shooter = fighter.weapon != &""
	_read_tell(fighter, foe, arena)
	return foe


static func _read_tell(fighter: Fighter, foe: BotView.Hostile, arena: CombatArena) -> void:
	var winding: bool = fighter.tell_left > 0 or fighter.swing_left > 0
	var squad: ArenaSquad = arena.squad_ai
	if squad != null and squad.minds.has(fighter.id):
		var agent: EnemyAgent = squad.minds[fighter.id].agent
		winding = winding or agent.state == EnemyAgent.State.WINDUP
		foe.tier = agent.arch.tier
		foe.front_cos = agent.arch.shield_cos
		if agent.arch.alt_weapon != null:
			foe.stomp_m = agent.arch.alt_weapon.splash_radius_m
			foe.tell_ticks = fighter.swing_left
			var cooldown: int = mini(
				agent.arch.weapon.cooldown_ticks, agent.arch.alt_weapon.cooldown_ticks
			)
			foe.opening = arena.tick - agent.shot_tick < cooldown
	if winding:
		if foe.archetype in [&"rocket_trooper", &"war_machine", &"robot_gunner"]:
			foe.tell = &"large"
		else:
			foe.tell = &"small" if foe.shooter else &"melee"
