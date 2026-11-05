extends GutTest
## Servo on the shared framework (ServoMoves): the shipped row loads with its moves script, the
## scanner's lock stamps the mark and the wave drops on it, a standing target is hit and one that
## steps off the mark after the lock is not, phase 3 breaks a wing, and the fight is deterministic.

const SPOT: Vector2 = Vector2(-8.0, 0.0)
## A real dodge: Rivet walks 6.75 m/s, so 6 m is under a second of the drones' flight.
const DODGE_M: float = 6.0


func _servo(seed_v: int) -> BossFight:
	var spec: BossSpec = BossSpec.shipped(&"servo")
	var reg: RngRegistry = RngRegistry.new(seed_v)
	var f: BossFight = BossFight.new(spec, reg.stream(spec.rng), spec.arena.boss_at)
	f.moves.bind(f, reg)
	return f


## Steps the fight (which steps Servo's tick); the target sidesteps DODGE_M when the tell
## locks if `dodge`.
## Returns the damage the target took.
func _run(f: BossFight, ticks: int, dodge: bool) -> float:
	var at: Vector2 = SPOT
	var taken: float = 0.0
	var was_locked: bool = false
	var seen: Array[StringName] = []
	@warning_ignore("return_value_discarded")
	f.attack_windup.connect(func(a: StringName) -> void: seen.append(a))
	for i: int in ticks:
		if dodge and f.locked and not was_locked:
			at = SPOT + Vector2(0.0, DODGE_M) if at.y < 1.0 else SPOT
		was_locked = f.locked
		taken += f.step(i, at, 0.6)
	gut.p("attacks: %s" % [seen])
	return taken


func test_shipped_servo_loads_with_his_moves() -> void:
	var spec: BossSpec = BossSpec.shipped(&"servo")
	assert_eq(spec.phases.size(), 3)
	assert_true(spec.attacks.has(&"scan_drop"))
	var f: BossFight = _servo(7)
	assert_true(f.moves is ServoMoves)


func test_standing_is_hit_and_dodging_is_not() -> void:
	var stand: BossFight = _servo(7)
	stand.start(0)
	var stand_dmg: float = _run(stand, 1800, false)
	var dodge: BossFight = _servo(7)
	dodge.start(0)
	var dodge_dmg: float = _run(dodge, 1800, true)
	var m: ServoMoves = stand.moves as ServoMoves
	var line: String = "30 s phase 1: standing took %.0f, dodging %.0f (marks %d)"
	gut.p(line % [stand_dmg, dodge_dmg, m.marks_made])
	assert_gt(m.marks_made, 0, "the scanner marked the target")
	assert_gt(stand_dmg, 0.0, "a standing target eats the drops")
	assert_lt(dodge_dmg, stand_dmg * 0.5, "stepping off after the lock dodges")


func test_phase_three_breaks_a_wing() -> void:
	var f: BossFight = _servo(7)
	f.start(2)
	var m: ServoMoves = f.moves as ServoMoves
	assert_eq(m.swarm.rack.count(ServoRack.Cell.BROKEN), 6)
	assert_eq(m.swarm.phase, 3)


func test_same_seed_same_fight() -> void:
	assert_eq(_hash(5), _hash(5))


func _hash(seed_v: int) -> PackedByteArray:
	var f: BossFight = _servo(seed_v)
	f.start(1)
	var taken: float = _run(f, 900, false)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	f.write_state(out)
	out.put_float(taken)
	return out.data_array
