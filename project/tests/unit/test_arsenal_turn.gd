extends GutTest

const Turn = preload("res://dev/rivet_arsenal/arsenal_turn.gd")
const Recorder = preload("res://dev/rivet_arsenal/arsenal_turn_rec.gd")


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


class DeferredTurn:
	extends Turn

	var starts: int = 0

	func _start() -> void:
		starts += 1
