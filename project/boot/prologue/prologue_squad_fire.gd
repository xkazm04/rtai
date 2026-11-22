class_name PrologueSquadFire
extends RefCounted
## The volley travels as ordinary enemy rifle rounds, one burst per surviving rifle.
## Lock a short lead on release so lateral motion matters and a direction change can evade it.

var volleys: int = 0
var _burst_at: int = -1
var _aims: Dictionary[int, Vector2] = {}
var _last_player: Vector2
var _velocity: Vector2
var _shotgun_angle: float


func _init(data: DataTable) -> void:
	_shotgun_angle = deg_to_rad(data.num(data.object(data.raw, "command"), "shotgun_half_deg"))


func reset(at: Vector2) -> void:
	volleys = 0
	_burst_at = -1
	_aims.clear()
	_last_player = at
	_velocity = Vector2.ZERO


func track(at: Vector2) -> void:
	_velocity = (at - _last_player) / SimClock.TICK_DT
	_last_player = at


func volley(arena: CombatArena, line: PrologueFormation, tick: int) -> void:
	volleys += 1
	_burst_at = tick
	_aims.clear()
	var rifle: EnemyWeapon = arena.squad_ai.pit.roster.weapons[&"rifle"]
	for h: Fighter in line.rifles:
		if h.alive() and _in_range(h, arena, rifle.reach_m):
			var flight: float = h.pos.distance_to(arena.rivet.pos) / rifle.speed_mps
			_aims[h.id] = arena.rivet.pos + _velocity * minf(flight, 0.5)


func step(arena: CombatArena, line: PrologueFormation, tick: int, ordering: bool) -> void:
	var roster: EnemyRoster = arena.squad_ai.pit.roster
	var rifle: EnemyWeapon = roster.weapons[&"rifle"]
	var since: int = tick - _burst_at
	var burst: bool = _burst_at >= 0 and since < rifle.burst * rifle.burst_gap_ticks
	for h: Fighter in line.rifles:
		if not h.alive() or not _in_range(h, arena, rifle.reach_m):
			continue
		if burst and since % rifle.burst_gap_ticks == 0 and _aims.has(h.id):
			_round(arena, h, rifle, h.pos.direction_to(_aims[h.id]))
		elif not burst and not ordering and (tick + h.id * 23) % rifle.cooldown_ticks == 0:
			_round(arena, h, rifle, h.pos.direction_to(arena.rivet.pos))
	for h: Fighter in line.shields:
		if h.alive():
			_baton(arena, h, roster.archetype(h.archetype))
	var boss: Fighter = line.boss
	var gun: EnemyWeapon = roster.archetype(boss.archetype).weapon
	if not ordering and tick >= boss.cooldown and _in_range(boss, arena, gun.reach_m):
		boss.cooldown = tick + gun.cooldown_ticks
		var dir: Vector2 = boss.pos.direction_to(arena.rivet.pos)
		for side: int in [-1, 0, 1]:
			_round(arena, boss, rifle, dir.rotated(side * _shotgun_angle))
			arena.shots.back().left_m = gun.reach_m


func _round(arena: CombatArena, h: Fighter, rifle: EnemyWeapon, direction: Vector2) -> void:
	h.facing = direction
	arena.shots.append(FoeAttacks.round_from(h, rifle))


func _in_range(h: Fighter, arena: CombatArena, reach: float) -> bool:
	return (
		h.pos.distance_to(arena.rivet.pos) <= reach
		and arena.guard_map.sight_line(h.pos, arena.rivet.pos)
	)


func _baton(arena: CombatArena, h: Fighter, arch: EnemyRoster.Archetype) -> void:
	var near: bool = _in_range(h, arena, arch.weapon.reach_m + arena.rivet.radius_m)
	if h.swing_left > 0:
		h.swing_left -= 1
		if h.swing_left == 0 and near:
			arena.hit_dir = h.pos.direction_to(arena.rivet.pos)
			arena.damage(arena.rivet, arch.weapon.damage, h.id, arch.weapon.id, &"melee")
	elif near and arena.tick >= h.cooldown:
		h.swing_tick = arena.tick
		h.swing_left = arch.telegraph_ticks
		h.cooldown = arena.tick + arch.weapon.cooldown_ticks
