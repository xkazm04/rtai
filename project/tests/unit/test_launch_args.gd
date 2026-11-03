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
