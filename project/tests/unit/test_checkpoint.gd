extends GutTest

const PATH: String = "user://test_tmp/unit/checkpoint.json"


func _sample() -> Checkpoint:
	var c: Checkpoint = Checkpoint.new()
	c.quest = "collect-call"
	c.beat = "b4-dock"
	c.tick = 6042
	c.master_seed = 20261102
	c.state_hash = "a".repeat(64)
	c.input_ticks.assign([0, 10, 400])
	c.inputs.assign([TickInput.new().pack(), TickInput.new(1, 127, 0).pack(), 12345678901])
	return c


func test_save_and_load_round_trip() -> void:
	var c: Checkpoint = _sample()
	assert_eq(c.save(PATH), OK)
	var back: Checkpoint = Checkpoint.load_file(PATH)
	assert_not_null(back)
	assert_eq(JSON.stringify(back.to_dict()), JSON.stringify(c.to_dict()))
	assert_eq(back.inputs[2], 12345678901, "48-bit packed inputs survive JSON")
	Checkpoint.erase(PATH)
	assert_false(FileAccess.file_exists(PATH))


func test_wrong_schema_or_version_is_refused() -> void:
	var d: Dictionary = _sample().to_dict()
	d["version"] = 2
	assert_null(Checkpoint.from_json(JSON.stringify(d)))
	d["version"] = 1
	d["schema"] = "gtai.replay/1"
	assert_null(Checkpoint.from_json(JSON.stringify(d)))
	assert_null(Checkpoint.from_json("not json"))


func test_mismatched_tape_is_refused() -> void:
	var d: Dictionary = _sample().to_dict()
	d["inputs"] = [1]
	assert_null(Checkpoint.from_json(JSON.stringify(d)))


func test_tape_plays_history_then_records_live() -> void:
	var tape: InputTape = InputTape.new(InputSource.new())
	var ticks: Array[int] = [0, 5]
	var inputs: Array[int] = [TickInput.new(1).pack(), TickInput.new(2).pack()]
	tape.preload_history(ticks, inputs, 8)
	assert_eq(tape.sample(3).buttons, 1)
	assert_eq(tape.sample(7).buttons, 2)
	assert_eq(tape.sample(8).buttons, 0, "live (idle) from play_until on")
	var h: Array[Array] = tape.history_before(8)
	assert_eq(h[0], [0, 5])
	assert_eq(tape.change_ticks, [0, 5, 8] as Array[int])
