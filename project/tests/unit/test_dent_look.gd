extends GutTest


func after_each() -> void:
	LaunchArgs.parse()


func test_shipped_strap() -> void:
	LaunchArgs.parse([])
	var look: DentLook = DentLook.shipped()
	assert_same(look, DentLook.shipped())
	assert_eq(look.tether_look, "strap")
	assert_eq(look.requested(), "strap")
	assert_eq(look.resolved(), "strap")
	assert_eq(look.disc_m, 1.1)


func test_launch_flag_overrides_row_and_strings_use_strap() -> void:
	LaunchArgs.parse(["--dent-tether=strings"])
	assert_true(LaunchArgs.unknown().is_empty())
	var look: DentLook = DentLook.shipped()
	assert_eq(look.requested(), "strings")
	assert_eq(look.resolved(), "strap")
	LaunchArgs.parse(["--dent-tether=strap"])
	assert_eq(look.requested(), "strap")
