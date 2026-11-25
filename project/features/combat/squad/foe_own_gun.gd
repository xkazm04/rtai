class_name FoeOwnGun
extends RefCounted
## n31 lever 5: with `squad.own_weapons` a production squad member fires its own enemies.json
## weapon (pistol, rifle, cannon) instead of the shared assault-rifle. The trigger keeps
## GuardBrain.trigger's cadence (the cooldown counts after the burst's last round), so
## ArenaSquad's token, sight, gait and burst-pause bookkeeping is unchanged. Each round deals
## the squad table's `own_weapon_damage` for that gun (Rivet hp), not the dev pit's damage.


## True when a production member fires its own gun. It still carries the production rifle id
## (its rig, its dropped rifle), so the squad table's switch alone decides, live.
static func carries(h: Fighter, e: EnemyAgent, roster: EnemyRoster) -> bool:
	var a: EnemyRoster.Archetype = e.arch
	if not roster.own_weapons or a.explicit_spawn or a.weapon == null or a.weapon.melee:
		return false
	return h.weapon == a.production_weapon


## One tick of the member's trigger: its own gun when it carries one, else the tuning rifle.
static func trigger(
	h: Fighter, mind: SquadMind, arena: CombatArena, pit: EnemyPit, rng: RandomNumberGenerator
) -> Shot:
	if not carries(h, mind.agent, pit.roster):
		return GuardBrain.trigger(h, arena.tuning, rng)
	var w: EnemyWeapon = mind.agent.arch.weapon
	if h.burst_left > 0:
		if h.burst_gap > 0:
			h.burst_gap -= 1
			return null
		aim(h, mind, pit, w)
		h.burst_left -= 1
		h.burst_gap = w.burst_gap_ticks
		var shot: Shot = FoeAttacks.round_from(h, w)
		shot.size = w.round
		shot.damage = pit.roster.own_damage.get(w.id, w.damage)
		return shot
	if h.cooldown > 0:
		h.cooldown -= 1
		return null
	h.burst_left = w.burst
	h.cooldown = w.cooldown_ticks
	return null


## The street rifle's lead (GuardBrain.street_aim) at the squad's `aim_lead` and this gun's round
## speed: a fresh line on a burst's first round, kept through the burst.
static func aim(h: Fighter, mind: SquadMind, pit: EnemyPit, w: EnemyWeapon) -> void:
	if pit.roster.aim_lead <= 0.0:
		return
	if h.burst_left == w.burst:
		var to: Vector2 = pit.rivet_pos - h.pos
		var flight_s: float = to.length() / maxf(w.speed_mps, 1.0)
		var led: Vector2 = EnemyBrain.led_offset(to, pit.rivet_vel, flight_s, pit.roster.aim_lead)
		mind.agent.aim = h.facing.rotated(to.angle_to(led))
	if mind.agent.aim != Vector2.ZERO:
		h.facing = mind.agent.aim
