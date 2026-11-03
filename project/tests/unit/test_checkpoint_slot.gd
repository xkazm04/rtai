extends GutTest
## A slot whose hash is right can still ask for the impossible: the reader bounds what a load costs.


func _body(tick: int, ticks: Array[int]) -> Dictionary:
	var c: Checkpoint = Checkpoint.new()
	c.quest = "collect-call"
	c.beat = "b4-dock"
	c.tick = tick
	c.master_seed = 77
	c.state_hash = "cd".repeat(32)
	c.input_ticks = ticks
	for t: int in ticks:
		c.inputs.append(0x7F7F + t)
	return c.to_dict()


func test_an_ordinary_checkpoint_reads() -> void:
	assert_not_null(CheckpointSlot.read(_body(5669, [0, 40, 900] as Array[int])))


func test_the_longest_allowed_replay_reads_and_one_more_tick_is_refused() -> void:
	assert_not_null(CheckpointSlot.read(_body(CheckpointSlot.MAX_TICK, [0] as Array[int])))
	assert_null(CheckpointSlot.read(_body(CheckpointSlot.MAX_TICK + 1, [0] as Array[int])))


func test_a_billion_tick_replay_is_refused_before_anything_simulates() -> void:
	assert_null(CheckpointSlot.read(_body(1_000_000_000, [0] as Array[int])))


func test_a_tape_out_of_order_or_past_the_tick_is_refused() -> void:
	assert_null(CheckpointSlot.read(_body(100, [5, 3] as Array[int])), "descending")
	assert_null(CheckpointSlot.read(_body(100, [5, 5] as Array[int])), "repeated tick")
	assert_null(CheckpointSlot.read(_body(100, [5, 100] as Array[int])), "change at the tick")
	assert_null(CheckpointSlot.read(_body(100, [-1, 5] as Array[int])), "before tick 0")


func test_the_pathological_every_tick_tape_still_reads() -> void:
	var every: Array[int] = []
	for t: int in 72000:
		every.append(t)
	assert_not_null(CheckpointSlot.read(_body(72000, every)))
