class_name PrologueSquad
extends ArenaSquad
## The arrival uses the same enrolled fighters and rigs as the panic. The stage manager
## walks them to their marks until Dale falls, then the squad takes their next tick.

var talking: bool = true
var shot_tick: int = -1


func assign(arena: CombatArena) -> Array[Fighter]:
	return arena.hostiles if talking else super.assign(arena)


func step(h: Fighter, arena: CombatArena, rng: RandomNumberGenerator) -> Shot:
	if talking:
		return null
	var shot: Shot = super.step(h, arena, rng)
	if shot != null and shot.weapon == &"pistol":
		shot_tick = arena.tick
	return shot


func configure(arena: CombatArena, data: DataTable) -> void:
	var roster: EnemyRoster = pit.roster
	var row: Dictionary = data.object(data.raw, "arrival")
	roster.max_shooters = data.integer(row, "max_shooters")
	roster.max_melee = data.integer(row, "max_melee")
	roster.panic_ticks = CombatTuning.ticks(data.num(row, "panic_s"))
	var patrol: EnemyRoster.Archetype = roster.archetype(&"patrol_cop")
	patrol.morale = data.num(row, "panic_morale")
	patrol.cover_bias = 0.0
	# GuardBrain fires the production weapon. Give this arena a pistol from its roster
	# and apply the panic spread to the actual projectile, before collision on its first tick.
	var w: EnemyWeapon = patrol.weapon
	var gun: CombatTuning.Weapon = CombatTuning.Weapon.new()
	gun.id = w.id
	gun.burst = w.burst
	gun.burst_gap_ticks = w.burst_gap_ticks
	gun.cooldown_ticks = w.cooldown_ticks
	gun.damage_vs_rivet = w.damage
	gun.range_m = w.reach_m
	gun.speed_mps = w.speed_mps
	gun.spread_rad = deg_to_rad(data.num(row, "panic_spread_deg"))
	arena.tuning.weapons[w.id] = gun
	patrol.production_weapon = w.id
