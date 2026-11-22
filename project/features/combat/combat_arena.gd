class_name CombatArena
extends RefCounted
## One fight as data: Rivet, the hostiles, shots in flight, arc balls, dropped rifles. Every hit
## goes through damage() (the chokepoint: humans have 1 hp, so any hit kills; kills emit
## Events.actor_killed). The fight's own tells go out as Events too: wave_started (the stage
## announces each wave through announce_wave), boss_engaged, attack_telegraphed, player_hit.
## Deterministic: ticks, and the `combat` RNG stream only for guard spread and spawn jitter.

## A round landed (after damage): the hit-feel hook (features/combat/hit_feel, lane gunplay).
signal struck(victim: Fighter, dir: Vector2, lethal: bool, weapon: StringName)
## Lethal non-Rivet hit, after Events.actor_killed. Includes weapon (or burn), direction, impact
## in metres and the events.json death kind for brutality and human reactions.
signal kill_landed(victim: Fighter, weapon: StringName, dir: Vector2, at: Vector2, kind: StringName)
## A non-lethal hit on a non-Rivet fighter, from the chokepoint (view only: MeleeWound, n7-melee).
signal wounded(victim: Fighter, weapon: StringName)
## A hostile round batted back by the plasma sword at `at`, now flying along `back` (view only).
signal deflected(at: Vector2, back: Vector2)

const SPAWN_SPREAD_M: float = 2.5

var tuning: CombatTuning
var guard_map: GuardRouteMap
var squad_ai: ArenaSquad = null
var move_tally: MoveTally = MoveTally.new()
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
var guard: PlayerGuard = null
var walls: ArenaWalls = null
## Area effects start with the first GunHand shot, so quest 1 (no gun) keeps its goldens.
var areas: FightAreas = null
## The landing hit's direction and point, set before damage() (kill_landed reads them).
var hit_dir: Vector2 = Vector2.ZERO
var hit_at: Vector2 = Vector2.ZERO
## Lane gunplay: the round being landed is a charge gun's full charge (HitLink lands it heavy).
var struck_charged: bool = false
var _events: EventBus
var _rng: RandomNumberGenerator
var _next_id: int = 1


func _init(p_tuning: CombatTuning, events: EventBus, rng: RandomNumberGenerator) -> void:
	tuning = p_tuning
	_events = events
	_rng = rng
	rivet = Fighter.make(Fighter.Kind.RIVET, 0, Vector2.ZERO, tuning.rivet["hp"])
	rivet.radius_m = tuning.rivet["radius_m"]


## Station spawns keep the guard tell or GuardBrain. ArenaSquad.spawn_member equips wave members.
func spawn_guard(at: Vector2) -> Fighter:
	var spread: Vector2 = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	var pos: Vector2 = at + spread * SPAWN_SPREAD_M
	var g: Fighter = Fighter.make(Fighter.Kind.GUARD, _next_id, pos, tuning.human["hp"])
	_next_id += 1
	g.radius_m = tuning.human["radius_m"]
	g.weapon = &"assault-rifle"
	if guard_map != null:
		g.pursuit = GuardPursuit.new(guard_map)
	g.cooldown = _rng.randi_range(0, tuning.weapon(g.weapon).cooldown_ticks)
	hostiles.append(g)
	return g


## Lane n7-king: an act boss (features/bosses) stepped in, or began a tell (`attack` is its
## bosses.json attack id). The fight's beats go out as Events from here, their declared emitter.
func announce_boss(boss_id: StringName) -> void:
	_events.boss_engaged.emit(boss_id)


func announce_tell(attack: StringName) -> void:
	_events.attack_telegraphed.emit(attack)


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
			at = FightReach.lob_target(self, rivet.pos, at, w)
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
	var ordered: Array[Fighter] = squad_ai.assign(self) if squad_ai and rivet.alive() else hostiles
	rivet.cooldown = maxi(rivet.cooldown - 1, 0)
	for h: Fighter in ordered:
		if h.alive() and rivet.alive():
			_step_hostile(h)
	if tazer != null and tazer.charge_began():
		_events.attack_telegraphed.emit(boss.weapon)
	_step_shots()
	ArenaProjectiles.step_balls(self, _events)
	_repair()
	if gun != null:
		gun.settle()
	if areas != null:
		areas.step(self)


## The one damage chokepoint (events.json: the kill payload is decided before the hit lands).
## `kind` is the death kind: quest 1's rounds are `shot`; FightAreas passes `blown`, `burned`.
func damage(
	victim: Fighter, amount: float, killer_id: int, weapon: StringName, kind: StringName = &"shot"
) -> void:
	if not victim.alive() or not victim.exposed:
		return
	if guard != null and guard.blocks_melee(self, victim, killer_id, weapon, kind):
		return
	amount *= FoeArmor.impact(self, victim, kind, killer_id, weapon)
	amount *= victim.damage_k
	if victim.hp - amount <= 0.0 and victim.kind != Fighter.Kind.RIVET:
		_events.actor_killed.emit(killer_id, victim.id, kind)
		kill_landed.emit(victim, weapon, hit_dir, hit_at, kind)
		kills += 1
		kills_now += 1
		kill_weapon = weapon
		_drop(victim)
	elif victim.kind != Fighter.Kind.RIVET:
		wounded.emit(victim, weapon)
	victim.take(amount, tick, hit_dir)


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
	if h.brain_owned or (areas != null and h.archetype != &"war_machine" and areas.holds(self, h)):
		return
	if h.kind == Fighter.Kind.BOSS:
		var ball: ArcBall = BossBrain.step(h, tazer, rivet.pos, boss_anchor, tuning)
		if ball != null:
			balls.append(ball)
		return
	var shot: Shot
	if squad_ai != null and squad_ai.owns(h):
		shot = squad_ai.step(h, self, _rng)
	else:
		if guard_tell != null:
			shot = guard_tell.step(h, rivet.pos, tuning, _rng)
		else:
			shot = GuardBrain.step(h, rivet.pos, tuning, _rng)
		if h.station_spacing_m > 0.0:
			GuardBrain.space_partner(h, hostiles)
	if shot != null:
		shots.append(shot)


func _step_shots() -> void:
	ArenaProjectiles.step_shots(self)


## Dead guards drop their rifles; the quartermaster's Robo-tazer shorts out and is never dropped.
func _drop(victim: Fighter) -> void:
	if victim.kind == Fighter.Kind.BOSS:
		if tazer != null:  # an act boss (features/bosses) has no tazer and drops nothing
			tazer.short_out()
		balls.clear()
	elif squad_ai == null or not squad_ai.owns(victim) or victim.weapon == &"assault-rifle":
		rifle_drops.append(victim.pos)


func _repair() -> void:
	var since: float = float(tick - rivet.hurt_tick) * SimClock.TICK_DT
	if rivet.alive() and since >= tuning.rivet["repair_delay_s"]:
		var step_hp: float = tuning.rivet["repair_per_s"] * SimClock.TICK_DT
		rivet.hp = minf(rivet.hp + step_hp, rivet.max_hp)
