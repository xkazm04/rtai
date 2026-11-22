extends GutTest


func test_controls_mode_matches_the_runner_selection() -> void:
	var mode: String = OS.get_environment("GTAI_CONTROLS")
	assert_eq(ControlsMode.id(), StringName(mode) if mode != "" else &"wheel")
