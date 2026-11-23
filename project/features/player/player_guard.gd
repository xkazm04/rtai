class_name PlayerGuard
extends RefCounted
## Rivet's held guard on the simulation tick. A break lowers it immediately, including
## for subsequent hits in the same tick. Refill counts uninterrupted lowered ticks.

var tuning: GuardTuning
var deflects: int = 0
var breaks: int = 0
var melee_blocks: int = 0
## Changing the capacity preserves the fraction of charge already earned.
var meter_k: float = 1.0:
	set(value):
		var fraction: float = meter()
		_touched = _touched or meter_k != maxf(value, 0.0)
		meter_k = maxf(value, 0.0)
		_charge = fraction * _capacity()
		if _charge == 0.0:
			lower()

var _touched: bool = false
var _charge: float
var _up: bool = false
var _stagger: int = 0
var _delay: int = 0


func _init(config: GuardTuning = GuardTuning.load_table()) -> void:
	tuning = config
	_charge = _capacity()


func step(held: bool, can_guard: bool) -> void:
	if broken():
		_stagger -= 1
		return
	_up = held and can_guard and _charge > 0.0
	if _up:
		_touched = true
		_delay = CombatTuning.ticks(tuning.refill_delay_s)
	elif _delay > 0:
		_delay -= 1
	else:
		_charge = minf(_capacity(), _charge + tuning.refill_per_s * SimClock.TICK_DT)


func lower() -> void:
	_up = false


func meter() -> float:
	return _charge / _capacity() if _capacity() > 0.0 else 0.0


func broken() -> bool:
	return _stagger > 0


func up() -> bool:
	return _up


func blocks_attack() -> bool:
	return up() or broken()


func deflect(arena: CombatArena, s: Shot, from: Vector2) -> bool:
	if not up() or s.from_rivet or s.size != Shot.SMALL or EnemyRounds.is_blast(s):
		return false
	if not _in_arc(arena.rivet.facing, -s.vel):
		return false
	var r: Fighter = arena.rivet
	var contact: float = Geometry2D.segment_intersects_circle(from, s.pos, r.pos, r.radius_m)
	var at: Vector2 = from.lerp(s.pos, maxf(contact, 0.0))
	if not PlayerDeflect.send_back(arena, s, r.facing, at):
		_drain(tuning.drain_per_round * 0.5)
		return false
	deflects += 1
	_drain(tuning.drain_per_round)
	return true


func blocks_melee(
	arena: CombatArena, victim: Fighter, killer_id: int, weapon: StringName, kind: StringName
) -> bool:
	if not up() or victim != arena.rivet or kind not in [&"shot", &"melee"]:
		return false
	if not EnemyRounds.is_melee(weapon):
		return false
	for h: Fighter in arena.hostiles:
		if h.id == killer_id and _in_arc(victim.facing, h.pos - victim.pos):
			melee_blocks += 1
			_drain(tuning.melee_drain)
			return true
	return false


func write_state(out: StreamPeerBuffer) -> void:
	if not _touched:
		return
	out.put_double(meter_k)
	out.put_double(_charge)
	out.put_u8(int(up()))
	out.put_32(_stagger)
	out.put_32(_delay)
	out.put_32(deflects)
	out.put_32(breaks)
	out.put_32(melee_blocks)


func _capacity() -> float:
	return tuning.meter_max * meter_k


func _in_arc(facing: Vector2, incoming: Vector2) -> bool:
	if incoming.is_zero_approx() or facing.is_zero_approx():
		return false
	var angle: float = absf(facing.angle_to(incoming))
	var limit: float = deg_to_rad(tuning.arc_deg * 0.5)
	return angle < limit or is_equal_approx(angle, limit)


func _drain(amount: float) -> void:
	_charge = maxf(0.0, _charge - amount)
	_delay = CombatTuning.ticks(tuning.refill_delay_s)
	if _charge == 0.0:
		lower()
		breaks += 1
		_stagger = CombatTuning.ticks(tuning.stagger_s)
