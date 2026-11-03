class_name DodgeDrill
extends RefCounted
## Rivet against one EnemyGunner for `seconds`, headless: how many enemy rounds land when he
## stands, juke-strafes on a timer, or reacts to the tell with a sidestep. The proof that enemy
## fire is readable: the reacting player should take far fewer hits than the one standing still.

enum Policy { STAND, STRAFE, REACT }

## A sidestep on the tell: 0.4 s of strafe (about 1.8 m), then stand.
const REACT_TICKS: int = 24


class Setup:
	extends RefCounted
	var weapon: StringName = &"pistol"
	var distance_m: float = 12.0
	var speed_mps: float = 4.5
	var policy: Policy = Policy.REACT
	var seconds: float = 10.0
	var no_lock: bool = false
	## Human reaction time before the sidestep starts (0 = a perfect read).
	var react_delay_ticks: int = 0


class Result:
	extends RefCounted
	var volleys: int = 0
	var rounds: int = 0
	var hits: int = 0
	var damage: float = 0.0
	var digest: int = 0

	func on_hit(_t: RangeTarget, amount: float, _c: StringName, _d: Vector2) -> void:
		hits += 1
		damage += amount

	func hit_rate() -> float:
		return float(hits) / float(rounds) if rounds > 0 else 0.0

	func to_dict() -> Dictionary:
		return {
			"volleys": volleys,
			"rounds": rounds,
			"hits": hits,
			"hit_rate": snappedf(hit_rate(), 0.001),
			"damage": snappedf(damage, 0.1),
		}


static func run(table: WeaponTable, s: Setup, rng: RandomNumberGenerator) -> Result:
	var sim: ProjectileSim = ProjectileSim.new(rng, table)
	var rivet: RangeTarget = RangeTarget.make(1, Vector2(s.distance_m, 0.0), 1.0e6, 0.42)
	rivet.team = Projectile.TEAM_PLAYER
	sim.targets.append(rivet)
	var gun: EnemyGunner = EnemyGunner.make(2, Vector2.ZERO, s.weapon, table)
	gun.track_through_lock = s.no_lock
	var res: Result = Result.new()
	if sim.hit.connect(res.on_hit) != OK:
		return res
	var side: float = 1.0
	var move_left: int = 0
	var was_telling: bool = false
	for tick: int in roundi(s.seconds * SimClock.TICK_RATE):
		if gun.telling() and not was_telling:
			res.volleys += 1
			side = -side
			move_left = REACT_TICKS + s.react_delay_ticks
		was_telling = gun.telling()
		rivet.walk = _walk(s, tick, side, move_left)
		move_left = maxi(move_left - 1, 0)
		gun.step(sim, rivet.pos)
		sim.step(tick)
	res.rounds = sim.shots_fired
	res.digest = sim.digest()
	return res


static func _walk(s: Setup, tick: int, side: float, move_left: int) -> Vector2:
	match s.policy:
		Policy.STRAFE:
			var dir: float = 1.0 if (tick / 90) % 2 == 0 else -1.0
			return Vector2(0.0, dir * s.speed_mps)
		Policy.REACT:
			var stepping: bool = move_left > 0 and move_left <= REACT_TICKS
			return Vector2(0.0, side * s.speed_mps) if stepping else Vector2.ZERO
	return Vector2.ZERO
