extends GutTest

const Turn = preload("res://dev/rivet_arsenal/arsenal_turn.gd")
const Recorder = preload("res://dev/rivet_arsenal/arsenal_turn_rec.gd")
const Sprint = preload("res://dev/rivet_arsenal/arsenal_sprint_rec.gd")


func test_revision_probe_configures_the_requested_view_and_cadence() -> void:
	var dest: String = TestTmp.dir("turn")
	var rec: Recorder = autofree(Recorder.new())
	for pitch: String in ["p55", "p70", "top"]:
		for ppm: String in ["32", "64"]:
			var args: ArenaArgs = ArenaArgs.parse(
				[
					"--out=" + dest,
					"--weapon=ray_gun",
					"--boss=servo",
					"--reload-turn=on",
					"--pitch=" + pitch,
					"--ppm=" + ppm
				]
			)
			assert_eq(Turn.configure(args, rec), "")
			assert_eq(rec.weapon, &"ray_gun")
			assert_eq(rec.boss, &"servo")
			assert_eq(rec.out_dir, dest)
			assert_eq(rec.view_id, str({"p55": "tilt", "p70": "tilt70", "top": "top"}[pitch]))
			assert_eq(rec.clip, ppm == "32")


func test_invalid_flags_do_not_configure_a_film() -> void:
	var dest: String = TestTmp.dir("turn")
	var rec: Recorder = autofree(Recorder.new())
	for bad: String in [
		"--reload-turn=bad",
		"--boss=absent",
		"--view=p55",
		"--pitch=p45",
		"--ppm=48",
		"--out=",
		"--weapon="
	]:
		var args: ArenaArgs = ArenaArgs.parse(["--out=" + dest, "--weapon=pistol", bad])
		assert_ne(Turn.configure(args, rec), "", bad)
		assert_eq(rec.weapon, &"")


func test_initialize_defers_the_driver_until_the_scene_tree_is_ready() -> void:
	var probe: DeferredTurn = autofree(DeferredTurn.new())
	probe._initialize()
	assert_eq(probe.starts, 0)
	await get_tree().process_frame
	assert_eq(probe.starts, 1)


func test_bad_recorder_is_freed_logged_and_exits_with_usage_status() -> void:
	var args: ArenaArgs = ArenaArgs.parse(["--out=" + TestTmp.dir("turn")])
	var rec: Recorder = Recorder.new()
	var status: Array[int] = []
	var warning: String = "[ERROR] turn: expected --weapon=<arsenal id>"
	var before: int = Log.recent().count(warning)
	Turn.start_recorder(args, rec, get_tree().root, func(code: int) -> void: status.append(code))
	assert_false(is_instance_valid(rec))
	assert_eq(status, [2])
	assert_eq(Log.recent().count(warning) - before, 1)


func test_valid_recorder_is_attached_without_exiting() -> void:
	var args: ArenaArgs = ArenaArgs.parse(["--out=" + TestTmp.dir("turn"), "--weapon=pistol"])
	var host: Node = autofree(Node.new())
	var rec: Recorder = Recorder.new()
	var status: Array[int] = []
	Turn.start_recorder(args, rec, host, func(code: int) -> void: status.append(code))
	assert_eq(rec.get_parent(), host)
	assert_true(status.is_empty())


func test_turn_pad_presses_the_weapon_slot_key_only_while_a_slot_is_set() -> void:
	var pad: Recorder.TurnPad = Recorder.TurnPad.new()
	pad.actions = PlayerActions.shipped(true)
	for slot: int in RivetCarry.SLOT_ACTIONS.size():
		var key: int = 1 << pad.actions.bit(RivetCarry.SLOT_ACTIONS[slot])
		pad.slot = slot
		assert_eq(pad.sample(0).buttons & key, key)
		pad.slot = -1
		assert_eq(pad.sample(0).buttons & key, 0)


func test_equip_presses_the_slot_key_on_the_first_step_only() -> void:
	assert_eq(Recorder.EQUIP_STEPS, 6)
	for slot: int in RivetCarry.SLOT_ACTIONS.size():
		assert_eq(Recorder.slot_on_step(0, slot), slot)
		for step: int in range(1, Recorder.EQUIP_STEPS):
			assert_eq(Recorder.slot_on_step(step, slot), -1)


func test_turn_pad_fire_bit_is_set_by_fire_and_never_by_a_slot() -> void:
	var pad: Recorder.TurnPad = Recorder.TurnPad.new()
	pad.actions = PlayerActions.shipped(true)
	var fire: int = 1 << pad.actions.bit(&"fire")
	pad.fire = true
	assert_eq(pad.sample(0).buttons & fire, fire)
	for slot: int in RivetCarry.SLOT_ACTIONS.size():
		var key: int = 1 << pad.actions.bit(RivetCarry.SLOT_ACTIONS[slot])
		assert_eq(pad.sample(0).buttons & key, 0, "fire sets no slot key")
	pad.fire = false
	assert_eq(pad.sample(0).buttons & fire, 0)
	for slot: int in RivetCarry.SLOT_ACTIONS.size():
		pad.slot = slot
		assert_eq(pad.sample(0).buttons & fire, 0, "a slot does not set fire")


func test_sprint_tour_pad_presses_sprint_and_each_octant_stick() -> void:
	var pad: Recorder.TurnPad = Recorder.TurnPad.new()
	pad.actions = PlayerActions.shipped(true)
	pad.aim = Vector2.ZERO
	pad.sprint = true
	var sprint: int = 1 << pad.actions.bit(&"sprint")
	var sticks: Array[Vector2i] = [
		Vector2i(127, 0),
		Vector2i(90, 90),
		Vector2i(0, 127),
		Vector2i(-90, 90),
		Vector2i(-127, 0),
		Vector2i(-90, -90),
		Vector2i(0, -127),
		Vector2i(90, -90)
	]
	for octant: int in 8:
		assert_eq(Sprint.tour_input(octant), sticks[octant], "octant %d" % octant)
		pad.move = Sprint.tour_input(octant)
		var input: TickInput = pad.sample(0)
		assert_eq(input.buttons & sprint, sprint, "sprint held at octant %d" % octant)
		assert_eq(Vector2i(input.move_x, input.move_y), sticks[octant])
	pad.sprint = false
	assert_eq(pad.sample(0).buttons & sprint, 0)


func test_sprint_tour_flag_is_known_and_checked() -> void:
	var dest: String = TestTmp.dir("turn")
	var rec: Recorder = autofree(Recorder.new())
	var on: ArenaArgs = ArenaArgs.parse(["--out=" + dest, "--weapon=hands", "--sprint-tour=on"])
	assert_eq(Turn.configure(on, rec), "")
	var bad: ArenaArgs = ArenaArgs.parse(["--out=" + dest, "--weapon=hands", "--sprint-tour=x"])
	assert_ne(Turn.configure(bad, rec), "")


class DeferredTurn:
	extends Turn

	var starts: int = 0

	func _start() -> void:
		starts += 1
