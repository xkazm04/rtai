class_name BossFight
extends RefCounted
## The boss state machine on the 60 Hz tick (lane n7-king framework, shared with servo):
## IDLE (walk, gap) -> WINDUP (the tell: aim tracks, then locks `lock` ticks before) -> ACTIVE
## (the zone or the charge lands, at most once per attack) -> RECOVER (the first `punish` ticks
## take punish_k) -> IDLE. Phases are entered by hp fraction, one at a time: damage past the next
## threshold is held there until that phase begins (no skipped phase). A phase change cuts a
## tell, never an active attack or its recovery, then plays TRANSITION (invulnerable). Hits never
## cancel an attack. Attack picks come from the boss's named RNG stream (replay-safe).

signal phase_changed(index: int, id: StringName)
signal attack_windup(attack: StringName)
signal attack_active(attack: StringName)
signal attack_recovered(attack: StringName)
signal adds_wanted(archetype: StringName, count: int)
signal defeated

enum State { IDLE, WINDUP, ACTIVE, RECOVER, TRANSITION, DEFEATED }

## A stun dazes a boss this many ticks at most (0.6 s: a read, never a lock-down).
const DAZE_MAX: int = 36

var spec: BossSpec
var body: Fighter
var moves: BossMoves
var state: State = State.IDLE
var phase: int = 0
## Ticks spent in the current state.
var t: int = 0
var attack: BossAttack = null
## The aim (unit) and origin; frozen at the lock.
var aim: Vector2 = Vector2.RIGHT
var origin: Vector2 = Vector2.ZERO
var locked: bool = false
## Fault plant for the tests: the aim never locks (it tracks through the whole tell).
var plant_no_lock: bool = false
## Ticks of daze left (a stun: the boss stands, no walk, no new attack).
var dazed: int = 0
var hits: int = 0
var landed: bool = false
## The boss script's late hits in this step's return (BossMoves.tick: parcels, coins), so the
## hook credits them to the boss, not to the attack whose active window they fell in.
var late_hit: float = 0.0
var _rng: RandomNumberGenerator
var _ready_at: Dictionary[StringName, int] = {}
var _pending: int = -1
var _tick: int = 0
var _adds_t: int = 0
var _adds_asked: int = 0


func _init(p_spec: BossSpec, rng: RandomNumberGenerator, at: Vector2) -> void:
	spec = p_spec
	_rng = rng
	body = Fighter.make(Fighter.Kind.BOSS, 900, at, spec.hp)
	body.radius_m = spec.radius_m
	body.body_class = spec.body_class
	moves = BossMoves.make(spec.script_path)
	if spec.keep_m >= 0.0:
		moves.keep_m = spec.keep_m


## Starts the fight in phase `index` (0-based; --phase=N is N-1) at that phase's hp.
func start(index: int = 0) -> void:
	phase = clampi(index, 0, spec.phases.size() - 1)
	body.hp = spec.hp * spec.phases[phase].hp_below
	_enter(State.IDLE)
	_begin_phase()


func step(tick: int, target: Vector2, target_r: float) -> float:
	_tick = tick
	if state == State.DEFEATED:
		return 0.0
	t += 1
	_step_adds()
	var extra: float = moves.tick(self, target, target_r)  # late hits (parcels, falling coins)
	late_hit = extra
	if dazed > 0:
		dazed -= 1
		return extra
	match state:
		State.IDLE:
			moves.idle_step(self, target)
			if t >= spec.phases[phase].gap:
				_try_attack(target)
		State.WINDUP:
			_step_windup(target)
		State.ACTIVE:
			return _step_active(target, target_r) + extra
		State.RECOVER:
			if t >= attack.recovery:
				attack_recovered.emit(attack.id)
				_after_attack()
		State.TRANSITION:
			if t >= spec.phases[_pending].transition:
				phase = _pending
				_pending = -1
				_enter(State.IDLE)
				_begin_phase()
	return extra


## A stun (Ohm's bolt, the electro gun): cancels a tell (never an active attack, its recovery or
## a transition) and dazes the boss for at most DAZE_MAX ticks. Returns whether it took.
func daze(ticks: int) -> bool:
	if state != State.IDLE and state != State.WINDUP:
		return false
	if state == State.WINDUP:
		_enter(State.IDLE)
	dazed = maxi(dazed, mini(ticks, DAZE_MAX))
	return true


## A hit on the boss; returns the hp it took (0 in a transition or once defeated).
func hurt(amount: float) -> float:
	if state == State.TRANSITION or state == State.DEFEATED or amount <= 0.0:
		return 0.0
	if state == State.RECOVER and t <= attack.punish:
		amount *= attack.punish_k
	var floor_hp: float = _floor_hp()
	var before: float = body.hp
	body.hp = maxf(body.hp - amount, floor_hp)
	body.hurt_tick = _tick
	if body.hp <= 0.0:
		_enter(State.DEFEATED)
		defeated.emit()
	elif body.hp <= floor_hp and _pending < 0 and phase + 1 < spec.phases.size():
		_pending = phase + 1
		if state == State.IDLE or state == State.WINDUP:
			_enter(State.TRANSITION)
	return before - body.hp


## What a hit landed this tick is credited to: the active attack, else the boss itself (a late
## hit from BossMoves.tick, outside any active window).
func hit_id() -> StringName:
	return attack.id if attack != null and state == State.ACTIVE else spec.id


## The sim tick of the last step (views pose rigs on it, never on the frame delta).
func now() -> int:
	return _tick


func hp_frac() -> float:
	return body.hp / spec.hp


## Ticks left in the tell (0 outside WINDUP): views grow the telegraph with it.
func tell_left() -> int:
	return attack.windup - t if state == State.WINDUP else 0


func write_state(out: StreamPeerBuffer) -> void:
	out.put_32(state)
	out.put_32(phase)
	out.put_32(t)
	out.put_float(body.pos.x)
	out.put_float(body.pos.y)
	out.put_float(body.hp)
	out.put_32(hits)
	out.put_32(_adds_asked)
	moves.write_state(out)


func _floor_hp() -> float:
	var next: int = _pending if _pending >= 0 else phase + 1
	return spec.hp * spec.phases[next].hp_below if next < spec.phases.size() else 0.0


func _try_attack(target: Vector2) -> void:
	var dist: float = body.pos.distance_to(target)
	var total: float = 0.0
	var pool: Array[BossAttack] = []
	for a_id: StringName in spec.phases[phase].attacks:
		var a: BossAttack = spec.attacks.get(a_id)
		if a != null and a.fits(dist) and _tick >= _ready_at.get(a_id, 0):
			pool.append(a)
			total += a.weight
	if pool.is_empty():
		return
	var roll: float = _rng.randf() * total
	for a: BossAttack in pool:
		roll -= a.weight
		if roll <= 0.0 or a == pool.back():
			attack = a
			break
	locked = false
	landed = false
	_ready_at[attack.id] = _tick + attack.length() + attack.cooldown
	_enter(State.WINDUP)
	_track(target)
	attack_windup.emit(attack.id)


func _step_windup(target: Vector2) -> void:
	if not locked:
		_track(target)
		locked = t >= attack.windup - attack.lock and not plant_no_lock
	elif attack.leap_m > 0.0:  # the hop onto the locked ring, landing as the windup ends
		body.pos += (origin - body.pos) / float(maxi(attack.windup - t, 1))
	if t >= attack.windup:
		if plant_no_lock:
			_track(target)
		_enter(State.ACTIVE)
		if attack.adds_count > 0:
			adds_wanted.emit(attack.adds_archetype, attack.adds_count)
		attack_active.emit(attack.id)


func _step_active(target: Vector2, target_r: float) -> float:
	var struck: bool = moves.active_step(self, target, target_r)
	var dealt: float = 0.0
	if struck and not landed and attack.damage > 0.0:
		landed = true
		hits += 1
		dealt = attack.damage
	if t >= attack.active:
		_enter(State.RECOVER)
	return dealt


func _track(target: Vector2) -> void:
	var d: Vector2 = target - body.pos
	if d.length() > 0.01:
		aim = d.normalized()
		body.facing = aim
	origin = body.pos
	if attack != null and attack.leap_m > 0.0:
		origin += aim * minf(d.length(), attack.leap_m)


func _after_attack() -> void:
	_enter(State.TRANSITION if _pending >= 0 else State.IDLE)


func _begin_phase() -> void:
	_adds_t = 0
	_adds_asked = 0
	moves.phase_entered(self, phase)
	phase_changed.emit(phase, spec.phases[phase].id)
	_ask_adds()


func _step_adds() -> void:
	var p: BossSpec.Phase = spec.phases[phase]
	if p.adds_every <= 0 or p.adds_count <= 0 or state == State.TRANSITION:
		return
	_adds_t += 1
	if _adds_t >= p.adds_every:
		_adds_t = 0
		_ask_adds()


## The phase's adds, never past its max_total (a phase is a pressure, not a wall of adds).
func _ask_adds() -> void:
	var p: BossSpec.Phase = spec.phases[phase]
	var n: int = p.adds_count
	if p.adds_max > 0:
		n = mini(n, p.adds_max - _adds_asked)
	if n > 0:
		_adds_asked += n
		adds_wanted.emit(p.adds_archetype, n)


func _enter(s: State) -> void:
	state = s
	t = 0
