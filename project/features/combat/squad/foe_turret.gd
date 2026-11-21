class_name FoeTurret
extends RefCounted
## The sentry commits its lane when the tell starts. Rivet can cross it or get behind
## the fixed mount during cooling. All rounds follow the same facing the aim line draws.

enum Phase { IDLE, TELL, SWEEP, COOL }

const HALF_ARC: float = PI * 25.0 / 180.0

var phase: Phase = Phase.IDLE
var _start: Vector2
var _angle: float = 0.0
var _gap: int = 0
var _rounds: int = 0


func step(e: EnemyAgent, h: Fighter, arena: CombatArena) -> Shot:
	h.cooldown = maxi(h.cooldown - 1, 0)
	if phase in [Phase.TELL, Phase.SWEEP] and not e.token:
		phase = Phase.IDLE
		h.tell_left = 0
		e.enter(EnemyAgent.State.ENGAGE)
	match phase:
		Phase.IDLE:
			if e.token and h.cooldown == 0 and e.has_shot_at(arena.rivet.pos):
				_start = h.pos.direction_to(arena.rivet.pos).rotated(-HALF_ARC)
				if _start.is_zero_approx():
					_start = h.facing
				phase = Phase.TELL
				h.tell_left = e.arch.telegraph_ticks
				e.enter(EnemyAgent.State.WINDUP, h.tell_left)
				arena.announce_tell(h.weapon)
		Phase.TELL:
			_aim(e, h)
		Phase.SWEEP:
			return _sweep(e, h, arena)
		Phase.COOL:
			if h.cooldown == 0:
				phase = Phase.IDLE
				e.enter(EnemyAgent.State.ENGAGE)
	return null


func _aim(e: EnemyAgent, h: Fighter) -> void:
	EnemyMotor.turn_toward(e, _start)
	h.facing = e.facing
	e.aim = h.facing
	e.state_ticks += 1
	if absf(h.facing.angle_to(_start)) > 0.001:
		return
	h.tell_left -= 1
	e.timer = h.tell_left
	if h.tell_left > 0:
		return
	phase = Phase.SWEEP
	h.tell_left = 1
	e.enter(EnemyAgent.State.FIRE)
	_angle = 0.0
	_rounds = 0
	_gap = 0


func _sweep(e: EnemyAgent, h: Fighter, arena: CombatArena) -> Shot:
	if _angle > 2.0 * HALF_ARC + 0.0001:
		phase = Phase.COOL
		h.tell_left = 0
		h.cooldown = e.arch.weapon.cooldown_ticks
		e.enter(EnemyAgent.State.RECOVER, h.cooldown)
		e.token = false
		return null
	h.facing = _start.rotated(_angle)
	e.facing = h.facing
	e.aim = h.facing
	_angle += e.arch.turn_rad_per_tick
	if _gap > 0:
		_gap -= 1
		return null
	var w: EnemyWeapon = e.arch.weapon
	_rounds += 1
	var interval: int = w.burst_gap_ticks
	if _rounds == w.burst:
		_rounds = 0
		interval *= 2
	_gap = maxi(0, interval - 1)
	e.shot_tick = arena.tick
	return FoeAttacks.round_from(h, w)
