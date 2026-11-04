class_name RangeDrill
extends RefCounted
## One range lane run headless: a shooter at the origin holds (auto) or clicks (semi) at one target
## `distance_m` down the lane, aiming at where it is now (no lead), until it drops or the clock
## runs out. A strafing target walks across the lane, so dodgeability shows as a lower hit rate.
## Returns the numbers the range station and the owner's TTK table read.

const TIMEOUT_TICKS: int = 600


class Lane:
	extends RefCounted
	var weapon: StringName = &"pistol"
	var distance_m: float = 10.0
	var target_hp: float = 100.0
	var target_radius_m: float = 0.35
	var strafe_mps: float = 0.0
	## A hostile holds the gun (enemy_fire scale: slower, weaker rounds); the target is Rivet.
	var enemy_shooter: bool = false


class Result:
	extends RefCounted
	var killed: bool = false
	var ttk_s: float = -1.0
	var shots: int = 0
	var hits: int = 0
	var digest: int = 0

	func hit_rate() -> float:
		return float(hits) / float(shots) if shots > 0 else 0.0


static func run(table: WeaponTable, lane: Lane, rng: RandomNumberGenerator) -> Result:
	var sim: ProjectileSim = ProjectileSim.new(rng, table)
	var trig: Trigger = Trigger.new(table.weapon(lane.weapon))
	var target: RangeTarget = RangeTarget.make(
		1, Vector2(lane.distance_m, 0.0), lane.target_hp, lane.target_radius_m
	)
	target.walk = Vector2(0.0, lane.strafe_mps)
	var team: int = Projectile.TEAM_ENEMY if lane.enemy_shooter else Projectile.TEAM_PLAYER
	target.team = Projectile.TEAM_PLAYER if lane.enemy_shooter else Projectile.TEAM_ENEMY
	sim.targets.append(target)
	var res: Result = Result.new()
	for tick: int in TIMEOUT_TICKS:
		_strafe_turn(target, lane, tick)
		trig.step()
		# a charge gun is held on (the tap bolt, then the charged one), like the arena bot
		var held: bool = trig.spec.auto or trig.spec.charge_ticks > 0 or tick % 2 == 0
		if trig.pull(held):
			sim.fire(trig, Vector2(0.4, 0.0), target.pos, team, 0)
		sim.step(tick)
		if not target.alive():
			res.killed = true
			res.ttk_s = float(tick + 1) * SimClock.TICK_DT
			break
	res.shots = sim.shots_fired
	res.hits = sim.hits_landed
	res.digest = sim.digest()
	return res


## A strafer reverses every 1.5 s (a player-like juke across the lane, +-2.25 m at 3 m/s).
static func _strafe_turn(target: RangeTarget, lane: Lane, tick: int) -> void:
	if lane.strafe_mps > 0.0 and tick > 0 and tick % 90 == 0:
		target.walk = -target.walk
