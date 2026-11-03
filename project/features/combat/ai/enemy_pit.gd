class_name EnemyPit
extends RefCounted
## The arena pit as data: enemies, cover boxes, shots in flight and Rivet as a moving circle the
## caller drives (input, or the PitDummy). One step() is one 60 Hz tick: squad tokens, every
## brain in id order, then shots. Deterministic: the `enemy_ai` RNG stream only (shot spread).
## Telegraphs and hits go out as Events (attack_telegraphed, player_hit) when a bus is given.

const NAIL_SPEED_MPS: float = 40.0
const NAIL_RANGE_M: float = 30.0
const MELEE_ARC_COS: float = 0.5

var roster: EnemyRoster
var agents: Array[EnemyAgent] = []
var shots: Array[Shot] = []
var cover: Array[Rect2] = []
var bounds: Rect2 = Rect2(-20.0, -14.0, 40.0, 28.0)
var rivet_pos: Vector2 = Vector2.ZERO
var rivet_vel: Vector2 = Vector2.ZERO
var rivet_radius: float = 0.42
var rivet_hp: float = 100.0
var tick: int = 0
var noise_pos: Vector2 = Vector2.ZERO
var noise_tick: int = -1
var stats: Dictionary[String, float] = {}
## Planted faults (TST-05) the scenario flips to prove its judges bite.
var plant_no_squad: bool = false
var plant_no_lock: bool = false
var _rng: RandomNumberGenerator
var _events: EventBus
var _next_id: int = 1


func _init(p_roster: EnemyRoster, rng: RandomNumberGenerator, events: EventBus = null) -> void:
	roster = p_roster
	_rng = rng
	_events = events
	for k: String in [
		"rivet_damage",
		"shots",
		"shot_hits",
		"swings",
		"swing_hits",
		"tells",
		"kills",
		"max_attackers",
		"nails",
		"nail_hits",
		"flinches",
		"tells_broken"
	]:
		stats[k] = 0.0


func spawn(arch_id: StringName, at: Vector2) -> EnemyAgent:
	var e: EnemyAgent = EnemyAgent.make(_next_id, roster.archetype(arch_id), at)
	_next_id += 1
	e.facing = (rivet_pos - at).normalized()
	e.cover_ref = cover
	agents.append(e)
	return e


func step() -> void:
	tick += 1
	if plant_no_squad:
		for e: EnemyAgent in agents:
			e.token = e.engaged()
	else:
		EnemySquad.assign(agents, rivet_pos, roster)
	var lock: int = roster.aim_lock_ticks
	if plant_no_lock:
		roster.aim_lock_ticks = -1
	for e: EnemyAgent in agents:
		EnemyBrain.step(e, self)
	roster.aim_lock_ticks = lock
	_step_shots()
	var attacking: int = 0
	for e: EnemyAgent in agents:
		var s: EnemyAgent.State = e.state
		attacking += 1 if (s == EnemyAgent.State.WINDUP or s == EnemyAgent.State.FIRE) else 0
	stats["max_attackers"] = maxf(stats["max_attackers"], attacking)


## Rivet fires a nail along `dir` (the noise every enemy within hearing_m reacts to).
func rivet_fire(dir: Vector2) -> void:
	var s: Shot = Shot.new()
	s.pos = rivet_pos + dir * (rivet_radius + 0.1)
	s.vel = dir.normalized() * NAIL_SPEED_MPS
	s.from_rivet = true
	s.damage = 1.0
	s.left_m = NAIL_RANGE_M
	shots.append(s)
	noise_pos = rivet_pos
	noise_tick = tick + 1
	stats["nails"] += 1.0


func alive() -> int:
	var n: int = 0
	for e: EnemyAgent in agents:
		n += 1 if e.alive() else 0
	return n


## The share of `squad` that has fallen (morale reads its own group, not every earlier wave).
func fallen_frac(squad: int = 0) -> float:
	var n: int = 0
	var down: int = 0
	for e: EnemyAgent in agents:
		if e.squad == squad:
			n += 1
			down += 0 if e.alive() else 1
	return 0.0 if n == 0 else float(down) / float(n)


## Cover spots other enemies have already claimed (so two never share a box side).
func claims(me: EnemyAgent) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for e: EnemyAgent in agents:
		if e != me and e.alive() and e.state == EnemyAgent.State.COVER:
			out.append(e.goal)
	return out


func holder_centroid() -> Vector2:
	var sum: Vector2 = Vector2.ZERO
	var n: int = 0
	for e: EnemyAgent in agents:
		if e.token and e.alive():
			sum += e.pos
			n += 1
	return Vector2.INF if n == 0 else sum / n


func tell(e: EnemyAgent) -> void:
	stats["tells"] += 1.0
	if _events != null:
		_events.attack_telegraphed.emit(e.arch.weapon.id)


func shoot(e: EnemyAgent) -> void:
	var dist: float = e.pos.distance_to(rivet_pos)
	var p: float = maxf(e.arch.accuracy(dist), 0.05)
	var cone: float = atan2(rivet_radius, maxf(dist, 0.5)) / p
	var s: Shot = Shot.new()
	var dir: Vector2 = e.aim.rotated(_rng.randf_range(-cone, cone))
	s.pos = e.pos + dir * (e.radius() + 0.1)
	s.vel = dir * e.arch.weapon.speed_mps
	s.from_rivet = false
	s.weapon = e.arch.weapon.id
	s.damage = e.arch.weapon.damage
	s.left_m = e.arch.weapon.reach_m
	s.shooter_id = e.id
	shots.append(s)
	stats["shots"] += 1.0
	e.shot_tick = tick


func swing(e: EnemyAgent) -> void:
	stats["swings"] += 1.0
	e.shot_tick = tick
	var to: Vector2 = rivet_pos - e.pos
	var reach: float = e.arch.weapon.reach_m + rivet_radius
	if to.length() <= reach and e.aim.dot(to.normalized()) >= MELEE_ARC_COS:
		stats["swing_hits"] += 1.0
		_hurt_rivet(e.arch.weapon.damage, e.arch.weapon.id)


## A hit on an enemy from `from_dir` (the direction the blow travels). Shields absorb in front.
func hurt(e: EnemyAgent, dmg: float, from_dir: Vector2) -> void:
	if not e.alive():
		return
	if e.facing.dot(-from_dir.normalized()) > 0.5:
		dmg *= e.arch.shield_front_mult
	e.hp -= dmg
	e.hurt_tick = tick
	e.hurt_dir = from_dir.normalized()
	if e.hp <= 0.0:
		e.enter(EnemyAgent.State.DEAD)
		e.token = false
		e.died_tick = tick
		stats["kills"] += 1.0
	elif e.arch.stagger_ticks > 0:
		stun(e, e.arch.stagger_ticks)
	elif e.state == EnemyAgent.State.PATROL:
		e.last_seen = rivet_pos
		e.enter(EnemyAgent.State.ALERT, e.arch.reaction_ticks)


## Interrupts `e` for `ticks` (a stagger, or the electroshock's stun): a windup is cancelled and
## its squad token handed back. The dead and the downed are left as they are.
func stun(e: EnemyAgent, ticks: int) -> void:
	if not e.alive() or e.state == EnemyAgent.State.DOWN:
		return
	e.token = false
	e.last_seen = rivet_pos
	e.vel *= 0.3
	e.enter(EnemyAgent.State.STAGGER, ticks)


## Rivet's sprint tackle: humans go down; robots and bosses stay blocked (owner: later).
func knock(e: EnemyAgent, down_ticks: int) -> bool:
	if e.arch.body != &"human" or not e.alive():
		return false
	e.token = false
	e.enter(EnemyAgent.State.DOWN, down_ticks)
	return true


func _step_shots() -> void:
	var keep: Array[Shot] = []
	for s: Shot in shots:
		if not _advance(s):
			keep.append(s)
	shots = keep


## Moves one shot a tick; true when it is spent (hit, cover, range).
func _advance(s: Shot) -> bool:
	var from: Vector2 = s.advance()
	if EnemySenses.blocked(from, s.pos, cover):
		return true
	if not s.from_rivet:
		if s.crossed(from, rivet_pos, rivet_radius):
			stats["shot_hits"] += 1.0
			_hurt_rivet(s.damage, s.weapon)
			return true
		return s.spent()
	for e: EnemyAgent in agents:
		if e.alive() and s.crossed(from, e.pos, e.radius()):
			stats["nail_hits"] += 1.0
			hurt(e, s.damage, s.vel)
			return true
	EnemySuppress.near_miss(self, s, from)
	return s.spent()


func _hurt_rivet(dmg: float, weapon: StringName) -> void:
	rivet_hp -= dmg
	stats["rivet_damage"] += dmg
	if _events != null:
		_events.player_hit.emit(weapon)
