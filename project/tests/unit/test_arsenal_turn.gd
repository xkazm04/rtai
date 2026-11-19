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
