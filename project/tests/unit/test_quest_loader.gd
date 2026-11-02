extends GutTest
## The gtai.quest/1 boundary (DAT-05, DAT-07): the fixture loads into typed objects; every bad
## field is reported with its JSON path, and a package with any error is never built.


func test_fixture_loads_into_typed_package() -> void:
	var result: QuestLoader.Result = QuestLoader.load_package(
		QuestFixture.ID, QuestRules.shipped(), QuestFixture.places(), QuestFixture.ROOT
	)
	assert_eq(result.report.errors, [] as Array[String])
	var pkg: QuestPackage = result.package
	assert_eq(pkg.id, &"_selftest")
	assert_eq(pkg.beats.size(), 3)
	assert_eq(pkg.lines.size(), 9)
	assert_eq(pkg.barks().size(), 2)
	assert_eq(pkg.reward_cash, 500)
	assert_eq(pkg.unlocks, ["giver:the-valet"] as Array[String])
	assert_eq(pkg.heat_peak, 2)
	assert_eq(pkg.time_limit_ticks, QuestPackage.NO_TIME_LIMIT)
	assert_true(pkg.has_fail(&"rivet_wasted") and pkg.has_fail(&"car_destroyed"))
	assert_eq(pkg.story_writes, {"selftest_quest_done": true} as Dictionary[String, Variant])


func test_beats_resolve_their_handlers() -> void:
	var pkg: QuestPackage = QuestFixture.package()
	var handlers: Array[QuestRules.Handler] = []
	for beat: QuestBeat in pkg.beats:
		handlers.append(beat.handler)
	var want: Array[QuestRules.Handler] = [
		QuestRules.Handler.REACH, QuestRules.Handler.ENTER_VEHICLE, QuestRules.Handler.REACH
	]
	assert_eq(handlers, want)
	assert_eq(pkg.beats[1].target, "valet-sedan")
	assert_eq(pkg.beats[0].title_key, &"QUEST__SELFTEST__BEAT__THE_BAY")
	assert_eq(pkg.line("hauler-bark-1").key, &"QUEST__SELFTEST__LINE__HAULER_BARK_1")


func test_missing_file_is_an_error_not_a_crash() -> void:
	var result: QuestLoader.Result = QuestLoader.load_package(
		"no-such-quest", QuestRules.shipped(), QuestFixture.places(), QuestFixture.ROOT
	)
	assert_null(result.package)
	assert_string_contains(result.report.errors[0], "file not found")


func test_each_bad_field_is_reported_with_its_path() -> void:
	var cases: Dictionary[String, Callable] = {
		"schema:": func(p: Dictionary) -> void: p["schema"] = "gtai.quest/2",
		"id:": func(p: Dictionary) -> void: p["id"] = "other",
		"act:": func(p: Dictionary) -> void: p["act"] = "act9",
		"beats[0].objective.verb:":
		func(p: Dictionary) -> void: QuestFixture.objective(p, 0)["verb"] = "moonwalk",
		"beats[0].objective.location:":
		func(p: Dictionary) -> void: QuestFixture.objective(p, 0)["location"] = "the moon",
		"beats[1].objective.target:":
		func(p: Dictionary) -> void: QuestFixture.objective(p, 1)["target"] = "a-bike",
		"lines[0].speaker:":
		func(p: Dictionary) -> void: QuestFixture.line_row(p, 0)["speaker"] = "nobody",
		"lines[7].when:":
		func(p: Dictionary) -> void: QuestFixture.line_row(p, 7)["when"] = ["soul:toaster"],
		"lines[0].purpose:":
		func(p: Dictionary) -> void: QuestFixture.line_row(p, 0)["purpose"] = [],
		"difficulty.heatPeak:":
		func(p: Dictionary) -> void: QuestFixture.difficulty(p)["heatPeak"] = 7,
		"difficulty.failStates:":
		func(p: Dictionary) -> void: QuestFixture.difficulty(p)["failStates"] = [],
		"story:": func(p: Dictionary) -> void: assert_true(p.erase("story")),
	}
	for want: String in cases:
		var p: Dictionary = QuestFixture.raw()
		cases[want].call(p)
		var result: QuestLoader.Result = QuestFixture.load_raw(p)
		assert_null(result.package, "%s: an invalid package is never built" % want)
		var hit: bool = result.report.errors.any(
			func(e: String) -> bool: return e.begins_with(want)
		)
		assert_true(hit, "%s expected, got %s" % [want, result.report.errors])


func test_duplicate_and_dangling_line_ids_are_errors() -> void:
	var p: Dictionary = QuestFixture.raw()
	QuestFixture.line_row(p, 1)["id"] = "patch-ring-1"
	var errors: Array[String] = QuestFixture.load_raw(p).report.errors
	assert_true(errors.has("lines[1].id: duplicate 'patch-ring-1'"), str(errors))
	assert_true(errors.has("beats[0].lineIds: 'rivet-answer-1' is not in lines"), str(errors))


func test_unmapped_fail_state_and_unused_line_only_warn() -> void:
	var p: Dictionary = QuestFixture.raw()
	QuestFixture.difficulty(p)["failStates"] = ["Rivet wasted", "the Valet sulks"]
	var beats: Array = p["beats"]
	var last: Dictionary = beats[2]
	last["lineIds"] = ["patch-paid-1"]
	var result: QuestLoader.Result = QuestFixture.load_raw(p)
	assert_not_null(result.package)
	assert_eq(result.report.warnings.size(), 2, str(result.report.warnings))
	assert_false(result.package.has_fail(&"car_destroyed"))


func test_timer_length_prefers_duration_then_legacy_target() -> void:
	var p: Dictionary = QuestFixture.raw()
	QuestFixture.objective(p, 0)["verb"] = "survive"
	QuestFixture.objective(p, 0)["target"] = "12s"
	assert_eq(QuestFixture.load_raw(p).package.beats[0].length_ticks, 12 * SimClock.TICK_RATE)
	QuestFixture.objective(p, 0)["durationS"] = 5
	assert_eq(QuestFixture.load_raw(p).package.beats[0].length_ticks, 5 * SimClock.TICK_RATE)
	assert_true(QuestFixture.objective(p, 0).erase("durationS"))
	assert_true(QuestFixture.objective(p, 0).erase("target"))
	assert_eq(QuestFixture.load_raw(p).package.beats[0].length_ticks, 20 * SimClock.TICK_RATE)
	QuestFixture.objective(p, 0)["durationS"] = 0
	assert_null(QuestFixture.load_raw(p).package, "durationS 0 is rejected")


func test_a_time_limit_is_held_in_ticks() -> void:
	var p: Dictionary = QuestFixture.raw()
	QuestFixture.difficulty(p)["timeLimitS"] = 90
	assert_eq(QuestFixture.load_raw(p).package.time_limit_ticks, 90 * SimClock.TICK_RATE)
