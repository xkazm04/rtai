extends GutTest


func test_bits_31_and_32_survive_packing_axes_and_json() -> void:
	var log_file: ReplayLog = ReplayLog.new(17)
	var bits: int = (1 << 31) | (1 << 32) | 5
	var input: TickInput = TickInput.new(bits, -127, 126)
	var sample: TickInput = TickInput.unpack(input.pack())
	assert_eq(sample.buttons, bits)
	assert_eq(Vector2i(sample.move_x, sample.move_y), Vector2i(-127, 126))
	log_file.record_input(0, input)
	var path: String = TestTmp.dir("wide_input").path_join("input.json")
	assert_eq(log_file.save(path), OK)
	var copy: ReplayLog = ReplayLog.load_file(path)
	assert_eq(copy.input_at(0).pack(), input.pack())


func test_dash_and_sprint_have_their_shipped_wire_bits_and_bindings() -> void:
	var actions: PlayerActions = PlayerActions.shipped()
	assert_eq(actions.bit(&"dash"), 31)
	assert_eq(actions.bit(&"sprint"), 5)
	var dash: Dictionary = {}
	var sprint: Dictionary = {}
	for row: Dictionary in actions.rows:
		if row.id == "dash":
			dash = row
		if row.id == "sprint":
			sprint = row
	var logical: float = dash["bit"]
	var dash_keys: Array = dash["keys"]
	var sprint_keys: Array = sprint["keys"]
	var pad: Array = sprint["joy_buttons"]
	assert_eq(logical, 18.0)
	assert_eq(dash_keys, ["Shift"])
	assert_eq(sprint_keys, [])
	assert_eq(pad, [7.0])
