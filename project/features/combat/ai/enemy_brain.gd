class_name EnemyBrain
extends RefCounted
## One enemy's decision per tick: sense, then the state's step. Patrol -> alert (reaction time)
## -> engage. With a squad token and in range it winds up (the tell: aim line or raised arm),
## the aim tracks until aim_lock ticks before the shot and then locks, so a player who moves
## dodges; then fire and recover. Without a token it repositions: cover, flank or orbit at its
## preferred range while strafing (ranged flankers keep orbiting one way: the squad spreads).
## Losing too much of the squad breaks morale (panic, then regroup).

const S := EnemyAgent.State
const FLANK_RAD: float = 1.75
const STRAFE_FLIP_TICKS: int = 150
const WAIT_RING_M: float = 3.2


static func step(e: EnemyAgent, pit: EnemyPit) -> void:
	if e.state == S.DEAD:
		return
	e.state_ticks += 1
	e.cooldown = maxi(e.cooldown - 1, 0)
	e.sees = EnemySenses.sees(e, pit.rivet_pos, pit.roster, pit.cover)
	if e.sees:
		e.last_seen = pit.rivet_pos
	match e.state:
		S.PATROL, S.ALERT:
			_patrol(e, pit)
		S.DOWN, S.PANIC, S.RECOVER:
			_timed(e, pit)
		S.WINDUP:
			_windup(e, pit)
		S.FIRE:
			_fire(e, pit)
		_:
			_engage(e, pit)


static func _patrol(e: EnemyAgent, pit: EnemyPit) -> void:
	var heard: bool = pit.noise_tick == pit.tick and EnemySenses.hears(e, pit.noise_pos, pit.roster)
	if e.state == S.PATROL and (e.sees or heard):
		e.last_seen = pit.rivet_pos if e.sees else pit.noise_pos
		e.enter(S.ALERT, e.arch.reaction_ticks)
	if e.state == S.ALERT:
		e.timer -= 1
		if e.timer <= 0:
			e.enter(S.ENGAGE)
		EnemyMotor.move(e, Vector2.ZERO, e.last_seen, pit.agents, pit)
		return
	var walk: Vector2 = EnemyMotor.arrive(e, e.goal, e.arch.speed_mps * 0.4)
	EnemyMotor.move(e, walk, e.goal, pit.agents, pit)


static func _timed(e: EnemyAgent, pit: EnemyPit) -> void:
	e.timer -= 1
	var desired: Vector2 = Vector2.ZERO
	if e.state == S.PANIC:
		desired = (e.pos - pit.rivet_pos).normalized() * e.arch.speed_mps
	if e.state != S.DOWN:
		EnemyMotor.move(e, desired, e.last_seen, pit.agents, pit)
	if e.timer <= 0:
		e.token = false
		e.enter(S.ENGAGE)


static func _engage(e: EnemyAgent, pit: EnemyPit) -> void:
	if not e.broke and e.arch.morale < 1.0 and pit.fallen_frac() > e.arch.morale:
		e.broke = true
		e.token = false
		e.enter(S.PANIC, pit.roster.panic_ticks)
		return
	var dist: float = e.pos.distance_to(e.last_seen)
	var w: EnemyRoster.Weapon = e.arch.weapon
	var in_range: bool = dist <= (w.reach_m if w.melee else e.arch.attack_m)
	if e.token and e.cooldown == 0 and e.sees and in_range:
		e.enter(S.WINDUP, e.arch.telegraph_ticks)
		e.aim = (e.last_seen - e.pos).normalized()
		pit.tell(e)
		EnemyMotor.move(e, Vector2.ZERO, e.last_seen, pit.agents, pit)
		return
	var flip: bool = e.state_ticks % STRAFE_FLIP_TICKS == STRAFE_FLIP_TICKS - 1
	if flip and not (e.arch.flanks and not e.melee()):
		e.strafe_sign = -e.strafe_sign
	EnemyMotor.move(e, _reposition(e, pit), e.last_seen, pit.agents, pit)


static func _reposition(e: EnemyAgent, pit: EnemyPit) -> Vector2:
	var a: EnemyRoster.Archetype = e.arch
	if not e.token and a.uses_cover and not e.melee():
		var spot: Vector2 = EnemySenses.best_cover(e, pit.rivet_pos, pit.cover, pit.claims(e))
		if spot != Vector2.INF:
			e.state = S.COVER
			e.goal = spot
			return EnemyMotor.arrive(e, spot, a.speed_mps)
	if not e.sees:
		e.state = S.ENGAGE
		return EnemyMotor.arrive(e, e.last_seen, a.speed_mps, 1.0)
	if e.melee():
		return _hold_range(e, pit, a.preferred_m if e.token else WAIT_RING_M)
	if not e.token and a.flanks:
		e.state = S.FLANK
		e.goal = _flank_spot(e, pit)
		return EnemyMotor.arrive(e, e.goal, a.speed_mps, 0.6)
	e.state = S.ENGAGE
	return _hold_range(e, pit, a.preferred_m)


## Close or open to `ring` metres (a smooth radial term: no jitter at the edge) while strafing.
static func _hold_range(e: EnemyAgent, pit: EnemyPit, ring: float) -> Vector2:
	if EnemySenses.blocked(e.pos, pit.rivet_pos, pit.cover):
		return EnemyMotor.arrive(e, pit.rivet_pos, e.arch.speed_mps, ring)
	var to: Vector2 = pit.rivet_pos - e.pos
	var dist: float = maxf(to.length(), 0.001)
	var dir: Vector2 = to / dist
	var radial: float = clampf(dist - ring, -1.0, 1.0)
	var side: Vector2 = dir.orthogonal() * e.strafe_sign
	return dir * radial * e.arch.speed_mps + side * e.arch.strafe_mps


## A spot on Rivet's flank: rotated away from where the shooting squad stands.
static func _flank_spot(e: EnemyAgent, pit: EnemyPit) -> Vector2:
	var anchor: Vector2 = pit.holder_centroid()
	if anchor == Vector2.INF:
		anchor = e.pos
	var base: Vector2 = (anchor - pit.rivet_pos).normalized()
	var spot: Vector2 = pit.rivet_pos + base.rotated(FLANK_RAD * e.strafe_sign) * e.arch.preferred_m
	spot = EnemySenses.push_out(spot, e.radius(), pit.cover)
	return spot.clamp(pit.bounds.position, pit.bounds.end)


static func _windup(e: EnemyAgent, pit: EnemyPit) -> void:
	e.timer -= 1
	if not e.aim_locked(pit.roster.aim_lock_ticks):
		e.aim = (pit.rivet_pos - e.pos).normalized()
	var creep: Vector2 = Vector2.ZERO
	if e.melee():
		creep = EnemyMotor.arrive(e, pit.rivet_pos, e.arch.speed_mps * 0.35, 0.9)
	EnemyMotor.move(e, creep, e.pos + e.aim, pit.agents, pit)
	if e.timer <= 0:
		e.enter(S.FIRE)
		e.burst_left = e.arch.weapon.burst
		e.burst_gap = 0


static func _fire(e: EnemyAgent, pit: EnemyPit) -> void:
	var w: EnemyRoster.Weapon = e.arch.weapon
	EnemyMotor.move(e, Vector2.ZERO, e.pos + e.aim, pit.agents, pit)
	if e.burst_gap > 0:
		e.burst_gap -= 1
		return
	if w.melee:
		pit.swing(e)
	else:
		pit.shoot(e)
	e.burst_left -= 1
	e.burst_gap = w.burst_gap_ticks
	if e.burst_left <= 0:
		e.cooldown = w.cooldown_ticks
		e.enter(S.RECOVER, pit.roster.recover_ticks)
