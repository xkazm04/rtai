class_name PrologueShotgun
extends RefCounted
## All pellets leave one muzzle on one tick. The fixed fan puts fewer pellets on one
## body as the distance increases.

var shot_ticks: Array[int] = []
var _ready_tick: int = -1


func reset() -> void:
	shot_ticks.clear()
	_ready_tick = -1


## -1 outside the pump, otherwise the fraction of its back-and-forward travel completed.
func pump_progress(tick: int) -> float:
	if shot_ticks.is_empty() or tick >= _ready_tick:
		return -1.0
	var fired: int = shot_ticks.back()
	return float(tick - fired) / float(_ready_tick - fired)


func step(arena: CombatArena, boss: Fighter, gun: EnemyWeapon, tick: int) -> void:
	if tick < _ready_tick or boss.pos.distance_to(arena.rivet.pos) > gun.reach_m:
		return
	if not arena.guard_map.sight_line(boss.pos, arena.rivet.pos):
		return
	var aim: Vector2 = boss.pos.direction_to(arena.rivet.pos)
	if aim.is_zero_approx():
		aim = boss.facing
	boss.facing = aim
	for i: int in gun.pellets:
		var fraction: float = float(i) / maxi(gun.pellets - 1, 1)
		var angle: float = lerpf(-gun.spread_rad, gun.spread_rad, fraction)
		var pellet: Shot = FoeAttacks.round_from(boss, gun)
		pellet.vel = aim.rotated(angle) * gun.speed_mps
		arena.shots.append(pellet)
	shot_ticks.append(tick)
	_ready_tick = tick + gun.cooldown_ticks
