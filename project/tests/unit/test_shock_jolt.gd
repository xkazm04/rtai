extends GutTest
## Owner note 2026-11-04 (electro gun): the stun reads as a hard convulsion. Each channel holds a
## pose and then jumps (no smooth shiver), and the channels jump on different frames (off-rhythm).

const FRAME: float = 1.0 / 60.0


func test_a_channel_holds_then_jumps() -> void:
	var holds: int = 0
	var jumps: int = 0
	for f: int in 120:
		var a: float = ShockJolt.step(f * FRAME, 0.7, 0)
		var b: float = ShockJolt.step((f + 1) * FRAME, 0.7, 0)
		if is_equal_approx(a, b):
			holds += 1
		elif absf(a - b) > 0.2:
			jumps += 1
	assert_gt(holds, 60, "most frames hold the pose")
	assert_gt(jumps, 20, "and it jumps hard many times in 2 s")


func test_the_channels_jump_off_each_others_rhythm() -> void:
	var together: int = 0
	var moves: int = 0
	for f: int in 240:
		var t0: float = f * FRAME
		var t1: float = (f + 1) * FRAME
		var body: bool = ShockJolt.step(t0, 0.7, 0) != ShockJolt.step(t1, 0.7, 0)
		var head: bool = ShockJolt.step(t0, 0.7, 5) != ShockJolt.step(t1, 0.7, 5)
		moves += 1 if body or head else 0
		together += 1 if body and head else 0
	assert_lt(together, moves / 3, "the body and the head rarely jump on the same frame")


func test_values_stay_in_range() -> void:
	for f: int in 200:
		for ch: int in ShockJolt.RATES.size():
			var v: float = ShockJolt.step(f * FRAME, 1.3, ch)
			assert_between(v, -1.0, 1.0)
