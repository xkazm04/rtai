extends GutTest
## The LaunchArgs autoload re-parsed with fixed args; restored from the real command line after.


func after_each() -> void:
	LaunchArgs.parse(OS.get_cmdline_user_args())


func test_reduced_motion_is_a_known_flag() -> void:
	LaunchArgs.parse(PackedStringArray(["--reduced-motion", "--look=d4"]))
	assert_true(LaunchArgs.has("--reduced-motion"))
	assert_eq(LaunchArgs.value("--look"), "d4")
	assert_eq(LaunchArgs.unknown().size(), 0)


func test_a_misspelt_flag_is_kept_as_unknown() -> void:
	LaunchArgs.parse(PackedStringArray(["--reduce-motion"]))
	assert_false(LaunchArgs.has("--reduced-motion"))
	assert_eq(LaunchArgs.unknown(), PackedStringArray(["--reduce-motion"]))


func test_the_old_default_flags_reach_the_game() -> void:
	# d7-calls: quest1_game reads --ghosts-free via LaunchArgs.has(), which knows only KNOWN_FLAGS
	LaunchArgs.parse(PackedStringArray(["--ghosts-free", "--rivet-tan=1", "--gun-grey"]))
	assert_true(LaunchArgs.has("--ghosts-free"), "ghost-powers-5's old default must not be dropped")
	assert_eq(LaunchArgs.value("--rivet-tan"), "1")
	assert_eq(LaunchArgs.unknown().size(), 0)


func test_the_hold_ab_flags_are_known() -> void:
	# d7-held: the befores of the hold A/Bs must not be warned about as misspelt at boot
	LaunchArgs.parse(PackedStringArray(["--torch-off-arm", "--gun-off-claw"]))
	assert_true(LaunchArgs.has("--torch-off-arm"), "the off-claw A/B's before is a known flag")
	assert_true(LaunchArgs.has("--gun-off-claw"), "the claw-follow A/B's before is a known flag")
	assert_eq(LaunchArgs.unknown().size(), 0)
