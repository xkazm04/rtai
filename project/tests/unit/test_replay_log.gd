extends GutTest
## SIM-05 log mechanics: sparse input, lookup, JSON round trip, refusal of a foreign schema.

const PATH: String = "user://test_tmp/replay_log/log.json"


func before_all() -> void:
	assert_eq(DirAccess.make_dir_recursive_absolute(PATH.get_base_dir()), OK)


func test_input_is_packed_losslessly() -> void:
	var input: TickInput = TickInput.new(0b1011, -127, 99)
	var back: TickInput = TickInput.unpack(input.pack())
	assert_eq([back.buttons, back.move_x, back.move_y], [0b1011, -127, 99])
	assert_true(back.is_pressed(3))
	assert_false(back.is_pressed(2))


func test_only_changes_are_stored_and_lookup_holds_between() -> void:
	var log: ReplayLog = ReplayLog.new(3)
	for tick: int in 10:
		log.record_input(tick, TickInput.new(1 if tick >= 4 else 0))
	assert_eq(log.input_changes(), 1)
	assert_eq(log.input_at(3).buttons, 0)
	assert_eq(log.input_at(4).buttons, 1)
	assert_eq(log.input_at(9).buttons, 1)


func test_json_round_trip() -> void:
	var log: ReplayLog = ReplayLog.new(0xDEADBEEF)
	log.record_input(2, TickInput.new(3, 10, -10))
	log.ticks = 120
	log.final_hash = "abc"
	log.checkpoints.assign(["h1", "h2"])
	log.timeline.assign(["5 wanted_changed [1]"])
	assert_eq(log.save(PATH), OK)
	var back: ReplayLog = ReplayLog.load_file(PATH)
	assert_not_null(back)
	assert_eq(log.first_divergence(back), "")
	assert_eq(back.input_at(2).move_y, -10)


func test_divergence_is_reported() -> void:
	var a: ReplayLog = ReplayLog.new(1)
	var b: ReplayLog = ReplayLog.new(1)
	a.checkpoints.assign(["x", "y"])
	b.checkpoints.assign(["x", "z"])
	assert_eq(a.first_divergence(b), "state hash differs at tick 120")
	b.build = "other"
	assert_string_starts_with(a.first_divergence(b), "build ")


func test_foreign_schema_is_refused() -> void:
	var file: FileAccess = FileAccess.open(PATH, FileAccess.WRITE)
	assert_true(file.store_string('{"schema": "gtai.other/1", "tick_rate": 60}'))
	file.close()
	assert_null(ReplayLog.load_file(PATH))
