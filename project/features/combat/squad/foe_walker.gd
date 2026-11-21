class_name FoeWalker
extends RefCounted
## The chassis traverses at the row's turn rate. The cannon tracks a ground point
## through its tell and locks on release. Both attacks leave the vents open.

const BAND_HALF_M: float = 3.0

var landing: Vector2
var attack: EnemyWeapon


func step(mind: SquadMind, h: Fighter, arena: CombatArena, map: GuardRouteMap) -> Shot:
	var e: EnemyAgent = mind.agent
	if e.state == EnemyAgent.State.WINDUP:
		return _windup(e, h, arena, map)
	if h.cooldown > 0:
		h.cooldown -= 1
		if e.state == EnemyAgent.State.RECOVER:
			e.timer = h.cooldown
			if h.cooldown == 0:
				e.enter(EnemyAgent.State.ENGAGE)
			return null
	var target: Vector2 = arena.rivet.pos
	var distance: float = h.pos.distance_to(target)
	var stomp: bool = distance <= e.arch.alt_weapon.reach_m
	var error: float = distance - e.arch.preferred_m
	var in_band: bool = absf(error) <= BAND_HALF_M
	var walk: Vector2 = Vector2.ZERO
	if not e.sees:
		walk = mind.velocity(arena.squad_ai.pit, map, 0.0)
	elif not in_band and not stomp:
		walk = h.pos.direction_to(target) * signf(error) * e.arch.speed_mps
	EnemyMotor.steer(e, walk, target, arena.squad_ai.pit)
	if map.clear_line(h.pos, e.pos):
		h.pos = e.pos
	e.pos = h.pos
	h.facing = e.facing
	if not e.token or not e.has_shot_at(target) or h.cooldown > 0:
		return null
	e.state_ticks += 1
	var settled: bool = in_band or e.state_ticks >= e.arch.reaction_ticks
	var aligned: bool = absf(h.facing.angle_to(target - h.pos)) <= e.arch.turn_rad_per_tick
	if stomp or (settled and aligned):
		_start(e, h, arena, stomp)
	return null


func _start(e: EnemyAgent, h: Fighter, arena: CombatArena, stomp: bool) -> void:
	e.vel = Vector2.ZERO
	attack = e.arch.alt_weapon if stomp else e.arch.weapon
	if stomp:
		landing = h.pos
		h.swing_tick = arena.tick
		h.swing_left = e.arch.alt_telegraph_ticks
	else:
		landing = arena.rivet.pos
		h.tell_left = e.arch.telegraph_ticks
	e.aim = h.facing
	e.enter(EnemyAgent.State.WINDUP, h.tell_left + h.swing_left)
	arena.announce_tell(attack.id)


func _windup(e: EnemyAgent, h: Fighter, arena: CombatArena, map: GuardRouteMap) -> Shot:
	if attack.melee:
		landing = h.pos
		h.swing_left -= 1
	else:
		landing = arena.rivet.pos
		e.aim = h.pos.direction_to(landing)
		EnemyMotor.turn_toward(e, e.aim)
		h.facing = e.facing
		h.tell_left -= 1
	e.timer = h.tell_left + h.swing_left
	e.state_ticks += 1
	if e.timer > 0:
		return null
	h.cooldown = attack.cooldown_ticks
	e.enter(EnemyAgent.State.RECOVER, h.cooldown)
	e.shot_tick = arena.tick
	e.token = false
	if not attack.melee:
		return arena.squad_ai.rockets.launch(h, attack, landing, arena, map)
	var blast: Shot = FoeAttacks.round_from(h, attack)
	blast.pos = h.pos
	blast.size = EnemyRounds.size_of(attack.id)
	arena.squad_ai.rockets.burst.emit(h.pos, attack.splash_radius_m, blast)
	if (
		h.pos.distance_to(arena.rivet.pos) <= attack.splash_radius_m
		and map.sight_line(h.pos, arena.rivet.pos)
	):
		arena.hit_dir = h.pos.direction_to(arena.rivet.pos)
		arena.hit_at = arena.rivet.pos
		arena.damage(arena.rivet, attack.splash_damage, h.id, attack.id, &"blown")
	return null


## Radius of the ground warning this tick. The foot ring reaches full width before impact.
func ring_radius(e: EnemyAgent) -> float:
	if e.state != EnemyAgent.State.WINDUP:
		return 0.0
	if not attack.melee:
		return attack.splash_radius_m
	var progress: float = float(e.state_ticks + 1) / e.arch.alt_telegraph_ticks
	return attack.splash_radius_m * lerpf(0.25, 1.0, progress)
