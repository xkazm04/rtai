extends GutTest
## n9-handheld it8: CamFollow eases BossCam's focus: the speed changes by at most `accel` a tick,
## it stops on a still target without overshoot, keeps pace with a steady pan, cuts a far jump.

const A: float = 0.05
const SNAP: float = 10.0


func test_first_step_cuts() -> void:
	var f: CamFollow = CamFollow.new()
	assert_eq(f.step(Vector2(3, 4), A, SNAP), Vector2(3, 4))
	assert_eq(f.vel, Vector2.ZERO)


func test_a_sudden_pan_ramps_up() -> void:
	# planted: the target starts moving at 0.5 m a tick from rest (the keep-in margin engaging)
	var f: CamFollow = CamFollow.new()
	@warning_ignore("return_value_discarded")
	f.step(Vector2.ZERO, A, SNAP)
	var last: float = 0.0
	for i: int in 60:
		@warning_ignore("return_value_discarded")
		f.step(Vector2(0.5 * (i + 1), 0), A, SNAP)
		assert_lte(absf(f.vel.x - last), A + 1e-5, "speed step at tick %d" % i)
		last = f.vel.x
	assert_almost_eq(f.vel.x, 0.5, 0.02, "it keeps pace with the pan")
	assert_almost_eq(f.pos.x, 30.0, 0.3, "no lag left once it caught up")


func test_stops_on_a_still_target_without_overshoot() -> void:
	var f: CamFollow = CamFollow.new()
	@warning_ignore("return_value_discarded")
	f.step(Vector2.ZERO, A, SNAP)
	var top: float = 0.0
	for i: int in 240:
		@warning_ignore("return_value_discarded")
		f.step(Vector2(4, 0), A, SNAP)
		top = maxf(top, f.pos.x)
	assert_almost_eq(f.pos.x, 4.0, 1e-3)
	assert_lte(top, 4.0 + A, "overshoot at most one tick's speed change")


func test_far_jump_cuts() -> void:
	var f: CamFollow = CamFollow.new()
	@warning_ignore("return_value_discarded")
	f.step(Vector2.ZERO, A, SNAP)
	assert_eq(f.step(Vector2(30, 0), A, SNAP), Vector2(30, 0), "a respawn cuts")
	assert_eq(f.vel, Vector2.ZERO)


func test_off_is_exact() -> void:
	var f: CamFollow = CamFollow.new()
	@warning_ignore("return_value_discarded")
	f.step(Vector2.ZERO, 0.0, SNAP)
	assert_eq(f.step(Vector2(2, 1), 0.0, SNAP), Vector2(2, 1), "accel 0 = the framing exactly")


func test_two_tick_frame_moves_as_two_ticks() -> void:
	# a 40 Hz frame (2 ticks) lands where two 60 Hz frames land
	var a: CamFollow = CamFollow.new()
	var b: CamFollow = CamFollow.new()
	for f: CamFollow in [a, b]:
		@warning_ignore("return_value_discarded")
		f.step(Vector2.ZERO, A, SNAP)
	for i: int in 30:
		@warning_ignore("return_value_discarded")
		a.advance(Vector2(0.2 * (2 * i + 2), 0), 2, A, SNAP)
		@warning_ignore("return_value_discarded")
		b.step(Vector2(0.2 * (2 * i + 1), 0), A, SNAP)
		@warning_ignore("return_value_discarded")
		b.step(Vector2(0.2 * (2 * i + 2), 0), A, SNAP)
	assert_almost_eq(a.pos.x, b.pos.x, 1e-4)
	assert_eq(a.advance(Vector2(99, 0), 0, A, SNAP), a.pos, "a hit-stop frame holds")
