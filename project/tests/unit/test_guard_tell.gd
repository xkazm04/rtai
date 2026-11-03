extends GutTest
## GuardTell: a contractor's burst is announced (tell ticks with no round), the aim holds still
## in the lock window, rounds fly at enemy_fire.speed_scale, and a strafing Rivet beats the whole
## burst. The planted fault (track_through_lock) must be caught.

const START: Vector2 = Vector2(8.0, 0.0)


class Run:
	extends RefCounted
	var first: int = -1
	var lock_from: Vector2 = Vector2.ZERO
	var lock_to: Vector2 = Vector2.ZERO
	var hurt: bool = false
	var speed: float = 0.0


func _arena(fault: bool) -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(7)
	var arena: CombatArena = CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))
	arena.guard_tell = GuardTell.from_table(WeaponTable.shipped())
	arena.guard_tell.track_through_lock = fault
	var g: Fighter = arena.spawn_guard(START)
	g.pos = START
	g.cooldown = 0
	return arena


## Steps 120 ticks with Rivet strafing at `mps` along +y.
func _run(arena: CombatArena, mps: float) -> Run:
	var g: Fighter = arena.hostiles[0]
	var out: Run = Run.new()
	var hp0: float = arena.rivet.hp
	for i: int in 120:
		arena.rivet.pos += Vector2(0.0, mps * SimClock.TICK_DT)
		arena.step(i)
		if g.tell_left == arena.guard_tell.lock_ticks:
			out.lock_from = g.facing
		if g.tell_left == 1:
			out.lock_to = g.facing
		if out.first < 0 and not arena.shots.is_empty():
			out.first = i
			out.speed = arena.shots[0].vel.length()
	out.hurt = arena.rivet.hp < hp0
	return out


func test_the_burst_is_told_before_any_round() -> void:
	var arena: CombatArena = _arena(false)
	var out: Run = _run(arena, 0.0)
	assert_gte(out.first, arena.guard_tell.tell_ticks, "no round before the tell ran out")
	var tuned: float = CombatTuning.shipped().weapon(&"assault-rifle").speed_mps
	assert_almost_eq(out.speed, tuned * arena.guard_tell.speed_scale, 0.01, "slowed rounds")
	assert_true(out.hurt, "control: a Rivet standing still is hit by the burst")


func test_the_lock_holds_the_aim_and_a_strafe_beats_the_burst() -> void:
	var arena: CombatArena = _arena(false)
	var out: Run = _run(arena, 5.0)
	assert_eq(out.lock_from, out.lock_to, "the aim holds still through the lock")
	assert_false(out.hurt, "a 5 m/s strafe takes no round")
	assert_gt(arena.guard_tell.rounds, 0)


func test_planted_fault_tracking_through_the_lock_is_caught() -> void:
	var out: Run = _run(_arena(true), 5.0)
	assert_ne(out.lock_from, out.lock_to, "the fault keeps tracking: the lock window is gone")


func test_one_slot_never_lets_two_gunners_tell_at_once() -> void:
	var arena: CombatArena = _arena(false)
	arena.guard_tell.one_slot = true
	var other: Fighter = arena.spawn_guard(START + Vector2(0.0, 3.0))
	other.pos = START + Vector2(0.0, 3.0)
	other.cooldown = 0
	var g: Fighter = arena.hostiles[0]
	var overlap: int = 0
	var both_told: Array[bool] = [false, false]
	for i: int in 240:
		arena.step(i)
		var busy_a: bool = g.tell_left > 0 or g.burst_left > 0
		var busy_b: bool = other.tell_left > 0 or other.burst_left > 0
		overlap += 1 if busy_a and busy_b else 0
		both_told[0] = both_told[0] or g.tell_left > 0
		both_told[1] = both_told[1] or other.tell_left > 0
	assert_eq(overlap, 0, "one slot: never two tells or bursts at once")
	assert_eq(both_told, [true, true], "and both gunners still get their turn")
