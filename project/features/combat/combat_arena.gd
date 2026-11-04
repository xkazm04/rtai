class_name CombatArena
extends RefCounted
## One fight as data: Rivet, the hostiles, shots in flight, arc balls, dropped rifles. Every hit
## goes through damage() (the chokepoint: humans have 1 hp, so any hit kills; kills emit
## Events.actor_killed). The fight's own tells go out as Events too: wave_started (the stage
## announces each wave through announce_wave), boss_engaged, attack_telegraphed, player_hit.
## Deterministic: ticks, and the `combat` RNG stream only for guard spread and spawn jitter.

## A round landed (after damage): the hit-feel hook (features/combat/hit_feel, lane gunplay).
signal struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName)
## A lethal hit on a non-Rivet fighter, from the chokepoint right after Events.actor_killed: the
## kill payload for brutality and human-reactions (weapon id or &"burn", hit direction, hit point
## in metres, the events.json death kind). Lane gunplay, night JOURNAL REQUEST 1.
signal kill_landed(victim: Fighter, weapon: StringName, dir: Vector2, at: Vector2, kind: StringName)

const SPAWN_SPREAD_M: float = 2.5

var tuning: CombatTuning
var rivet: Fighter
var hostiles: Array[Fighter] = []
var shots: Array[Shot] = []
var balls: Array[ArcBall] = []
var rifle_drops: Array[Vector2] = []
## Metal the arc ball bends to and chains through (crates, railings), metres.
var metal: PackedVector2Array = PackedVector2Array()
var boss: Fighter = null
var tazer: RoboTazer = null
var boss_anchor: Vector2 = Vector2.ZERO
var rifle_ammo: int = 0
var kills: int = 0
var kills_now: int = 0
var kill_weapon: StringName = &""
var tazer_hits: int = 0
var rifles_grabbed: int = 0
var tazer_hit_now: bool = false
## The last bursts' arc paths (VFX), newest last.
var burst_arcs: Array = []
var tick: int = 0
## Lane gunplay: Rivet's gun from weapons.json (GunHand); null keeps quest 1's own weapons.
var gun: GunHand = null
## Lane gunplay: readable contractor bursts (tell, lock, slowed rounds); null keeps GuardBrain.
var guard_tell: GuardTell = null
## Lane gunplay: the table's area behaviours (splash, chain, stun, burn, fire patches); made with
## the first GunHand shot, so quest 1 (no gun) never has one and its goldens do not move.
var areas: FightAreas = null
## The landing hit's direction and point, set before damage() (kill_landed reads them).
var hit_dir: Vector2 = Vector2.ZERO
var hit_at: Vector2 = Vector2.ZERO
var _events: EventBus
var _rng: RandomNumberGenerator
var _next_id: int = 1


func _init(p_tuning: CombatTuning, events: EventBus, rng: RandomNumberGenerator) -> void:
	tuning = p_tuning
	_events = events
	_rng = rng
	rivet = Fighter.make(Fighter.Kind.RIVET, 0, Vector2.ZERO, tuning.rivet["hp"])
	rivet.radius_m = tuning.rivet["radius_m"]


## A contractor near `at` (spread up to SPAWN_SPREAD_M, so a wave pours in, not a queue).
func spawn_guard(at: Vector2) -> Fighter:
	var spread: Vector2 = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	var g: Fighter = Fighter.make(
		Fighter.Kind.GUARD, _next_id, at + spread * SPAWN_SPREAD_M, tuning.human["hp"]
	)
	_next_id += 1
	g.radius_m = tuning.human["radius_m"]
	g.weapon = &"assault-rifle"
	g.cooldown = _rng.randi_range(0, tuning.weapon(g.weapon).cooldown_ticks)
	hostiles.append(g)
	return g


## The next wave of the encounter at `encounter` began (Events.wave_started, wave from 1).
func announce_wave(encounter: StringName, wave: int) -> void:
	_events.wave_started.emit(encounter, wave)


## The quartermaster: a human (1 hp) behind cover except in the Robo-tazer's vent window.
func spawn_boss(at: Vector2, boss_id: StringName = &"quartermaster-mertz") -> Fighter:
	boss = spawn_guard(at)
	boss.pos = at
	boss.kind = Fighter.Kind.BOSS
	boss.weapon = &"robo-tazer"
	boss_anchor = at
	tazer = RoboTazer.new(tuning)
	_events.boss_engaged.emit(boss_id)
	return boss


func hostiles_alive() -> int:
	var n: int = 0
	for h: Fighter in hostiles:
		n += 1 if h.alive() else 0
	return n


## Rivet pulls the trigger at `at`; false while the weapon cools or there is none.
func rivet_fire(at: Vector2) -> bool:
	if gun != null:
		if areas == null:
			areas = FightAreas.new()
			areas.hp_scale = gun.hp_scale()
		var w: WeaponSpec = gun.trigger.spec
		if w.kind == WeaponSpec.Kind.THROWN:
			at = FightReach.lob_target(self, rivet.pos, at, w.range_m)
		var fired: Array[Shot] = gun.pull(rivet, at) if rivet.alive() else []
		shots.append_array(fired)
		return not fired.is_empty()
	if rivet.weapon == &"" or rivet.cooldown > 0 or not rivet.alive():
		return false
	var w: CombatTuning.Weapon = tuning.weapon(rivet.weapon)
	rivet.facing = (at - rivet.pos).normalized()
	shots.append(Shot.fire(rivet, rivet.facing, w))
	rivet.cooldown = w.cooldown_ticks if w.burst <= 1 else w.burst_gap_ticks
	if rivet.weapon == &"assault-rifle":
		rifle_ammo -= 1
		if rifle_ammo <= 0:
			rivet.weapon = &"gloria"
	return true


## Picks up a dropped rifle within `reach` m: sprays until the magazine is dry, then Gloria.
func grab_rifle(reach: float) -> bool:
	for i: int in rifle_drops.size():
		if rifle_drops[i].distance_to(rivet.pos) <= reach:
			rifle_drops.remove_at(i)
			rivet.weapon = &"assault-rifle"
			rifle_ammo = tuning.weapon(&"assault-rifle").magazine
			rifles_grabbed += 1
			return true
	return false


func step(p_tick: int) -> void:
	tick = p_tick
	kills_now = 0
	tazer_hit_now = false
	rivet.cooldown = maxi(rivet.cooldown - 1, 0)
	for h: Fighter in hostiles:
		if h.alive() and rivet.alive():
			_step_hostile(h)
	if tazer != null and tazer.charge_began():
		_events.attack_telegraphed.emit(boss.weapon)
	_step_shots()
	_step_balls()
	_repair()
	if gun != null:
		gun.settle()
	if areas != null:
		areas.step(self)


## The one damage chokepoint (events.json: the kill payload is decided before the hit lands).
## `kind` is the events.json death kind: quest 1's rounds are `shot`; FightAreas passes `blown`
## and `burned`.
func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	if not victim.alive() or not victim.exposed:
		return
	var lethal: bool = victim.hp - amount <= 0.0
	if lethal and victim.kind != Fighter.Kind.RIVET:
		_events.actor_killed.emit(killer_id, victim.id, kind)
		kill_landed.emit(victim, weapon, hit_dir, hit_at, kind)
		kills += 1
		kills_now += 1
		kill_weapon = weapon
		_drop(victim)
	victim.hp = maxf(victim.hp - amount, 0.0)
	victim.hurt_tick = tick


func write_state(out: StreamPeerBuffer) -> void:
	rivet.write_state(out)
	out.put_32(hostiles.size())
	for h: Fighter in hostiles:
		h.write_state(out)
	out.put_32(shots.size())
	out.put_32(balls.size())
	out.put_32(kills)
	out.put_32(tazer_hits)
	if tazer != null:
		tazer.write_state(out)
	if areas != null:
		areas.write_state(out)


func _step_hostile(h: Fighter) -> void:
	if areas != null and areas.holds(self, h):
		return
	if h.kind == Fighter.Kind.BOSS:
		var ball: ArcBall = BossBrain.step(h, tazer, rivet.pos, boss_anchor, tuning)
		if ball != null:
			balls.append(ball)
		return
	var shot: Shot = (
		guard_tell.step(h, rivet.pos, tuning, _rng)
		if guard_tell != null
		else GuardBrain.step(h, rivet.pos, tuning, _rng)
	)
	if shot != null:
		shots.append(shot)


func _step_shots() -> void:
	for s: Shot in shots.duplicate():
		var lands: bool = s.spec != null and areas != null
		if lands and s.spec.homing_rad_per_tick > 0.0:
			FightReach.home(self, s)
		var from: Vector2 = s.advance()
		# A thrown bottle flies over bodies and lands at the aimed point.
		var over: bool = lands and s.spec.kind == WeaponSpec.Kind.THROWN
		var victim: Fighter = null if over else _struck(s, from)
		var ends: bool = victim != null or s.spent() or _blocked(s, from)
		if victim != null:
			hit_at = Geometry2D.get_closest_point_to_segment(victim.pos, from, s.pos)
		if lands and ends:
			areas.land(self, s, victim, hit_at if victim != null else s.pos)
		elif victim != null:
			hit_dir = s.vel.normalized()
			damage(victim, s.damage, s.shooter_id, s.weapon)
			struck.emit(victim, hit_dir, not victim.alive(), s.weapon)
		if ends:
			shots.erase(s)


func _struck(s: Shot, from: Vector2) -> Fighter:
	if not s.from_rivet:
		return rivet if rivet.alive() and s.crossed(from, rivet.pos, rivet.radius_m) else null
	for h: Fighter in hostiles:
		if h.alive() and h.exposed and s.crossed(from, h.pos, h.radius_m):
			return h
	return null


## A nail at the boss while he is in cover stops in the crates in front of him.
func _blocked(s: Shot, from: Vector2) -> bool:
	return (
		s.from_rivet
		and boss != null
		and boss.alive()
		and not boss.exposed
		and (s.crossed(from, boss.pos, boss.radius_m + 0.6))
	)


func _step_balls() -> void:
	for b: ArcBall in balls.duplicate():
		b.step(rivet.pos, rivet.radius_m, metal)
		if b.burst:
			balls.erase(b)
			if b.hit_rivet:
				tazer_hits += 1
				tazer_hit_now = true
				_events.player_hit.emit(&"robo-tazer")
				damage(rivet, tuning.tazer["damage"], boss.id if boss != null else 0, &"robo-tazer")
			burst_arcs.append(b.arcs)
	if burst_arcs.size() > 8:
		burst_arcs = burst_arcs.slice(burst_arcs.size() - 8)


## Dead guards drop their rifles; the quartermaster's Robo-tazer shorts out and is never dropped.
func _drop(victim: Fighter) -> void:
	if victim.kind == Fighter.Kind.BOSS:
		tazer.short_out()
		balls.clear()
	else:
		rifle_drops.append(victim.pos)


func _repair() -> void:
	var since: float = float(tick - rivet.hurt_tick) * SimClock.TICK_DT
	if rivet.alive() and since >= tuning.rivet["repair_delay_s"]:
		var step_hp: float = tuning.rivet["repair_per_s"] * SimClock.TICK_DT
		rivet.hp = minf(rivet.hp + step_hp, rivet.max_hp)
