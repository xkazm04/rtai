class_name FoeShield
extends RefCounted
## A planted tell locks the slab's direction. The short follow-through keeps the
## carrier under its walking speed cap, and the slab can connect only once per shove.

const LUNGE_TICKS: int = 15
const SLAB_HALF_M: float = 0.32

var lunge_left: int = 0
var block_tick: int = -1000
var block_dir: Vector2 = Vector2.ZERO


func step(mind: SquadMind, h: Fighter, arena: CombatArena, map: GuardRouteMap) -> void:
	var e: EnemyAgent = mind.agent
	if h.swing_left > 0:
		h.swing_left -= 1
		e.timer = h.swing_left
		e.state_ticks += 1
		if h.swing_left == 0:
			lunge_left = LUNGE_TICKS
			e.enter(EnemyAgent.State.FIRE, LUNGE_TICKS)
		return
	if lunge_left > 0:
		_lunge(e, h, arena, map)
		return
	e.cooldown = maxi(0, e.cooldown - 1)
	var pit: EnemyPit = arena.squad_ai.pit
	var walk: Vector2 = mind.velocity(pit, map, 0.0)
	if e.sees:
		var approach: Vector2 = EnemyMotor.arrive(
			e, pit.rivet_pos, e.arch.speed_mps, e.arch.preferred_m
		)
		walk = e.facing * maxf(0.0, approach.dot(e.facing))
	EnemyMotor.steer(e, walk, pit.rivet_pos, pit)
	if map.clear_line(h.pos, e.pos):
		h.pos = e.pos
	e.pos = h.pos
	h.facing = e.facing
	var to: Vector2 = pit.rivet_pos - h.pos
	if not e.sees or not e.token or e.cooldown > 0 or to.length() > e.arch.attack_m:
		return
	if absf(h.facing.angle_to(to)) > e.arch.turn_rad_per_tick:
		return
	e.vel = Vector2.ZERO
	e.aim = h.facing
	h.swing_tick = arena.tick
	h.swing_left = e.arch.telegraph_ticks
	e.enter(EnemyAgent.State.WINDUP, h.swing_left)
	arena.announce_tell(e.arch.weapon.id)


func _lunge(e: EnemyAgent, h: Fighter, arena: CombatArena, map: GuardRouteMap) -> void:
	var next: Vector2 = h.pos + e.aim * e.arch.speed_mps * SimClock.TICK_DT
	if map.region().has_point(next) and map.clear_line(h.pos, next):
		h.pos = next
	e.pos = h.pos
	lunge_left -= 1
	e.timer = lunge_left
	if lunge_left > 0:
		return
	e.enter(EnemyAgent.State.RECOVER, e.arch.weapon.cooldown_ticks)
	e.cooldown = e.arch.weapon.cooldown_ticks
	e.token = false
	e.shot_tick = arena.tick
	var delta: Vector2 = arena.rivet.pos - h.pos
	if not FoeShoveZone.connects(delta, e.aim, e.arch.weapon.reach_m, arena.rivet.radius_m):
		return
	if map.sight_line(h.pos, arena.rivet.pos):
		FoeAttacks.melee_hit(e, arena, map)
