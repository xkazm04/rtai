extends GutTest
## The door carrier keeps its shipped four-drawing sheet, planted on a measured sole table.


func test_door_sheet_is_anchored_four_drawings_at_the_shipped_size() -> void:
	var path: String = "p70/" + CastDoorAnchors.SHEET
	assert_true(CastCards.anchored(path))
	assert_eq(StreetCopWalk.rows_of(path), 4)
	assert_eq(StreetCopWalk.fill_of(path), 1.0)
	assert_eq(CastCardKinds.cell_ratio(path, StreetCopWalk.CELL_RATIO), 1.0)
	assert_eq(CastCardKinds.cell_ratio("p70/" + CastRiotAnchors.EIGHT, 1.5), 1.5)


func test_door_marks_cover_five_facings_of_four_drawings() -> void:
	assert_eq(CastDoorAnchors.WALK70.size(), 20)
	assert_eq(CastDoorAnchors.WALK55.size(), 20)
	var pose: StreetPatrolPose = StreetPatrolPose.new()
	var step: float = pose.configure("p55/" + CastDoorAnchors.SHEET, 4, false)
	assert_eq(step, CastDoorAnchors.WALK_STEP_M)
	assert_between(1.6 / step, 5.0, 10.0)
	assert_eq(pose.marks.size(), 20)


func test_door_contact_cycles_its_four_drawings() -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure("p70/" + CastDoorAnchors.SHEET)
	assert_eq(contact.drawings, 4)
	assert_not_null(contact.registered)
	var seen: Dictionary[int, bool] = {}
	var at: Vector2 = Vector2.ZERO
	for tick: int in 200:
		at += Vector2.RIGHT * 1.6 * 32.0 * SimClock.TICK_DT
		@warning_ignore("return_value_discarded")
		contact.place(at, Vector2i(2, 0), Vector2(0.27, 0.25), 32.0)
		seen[posmod(contact.cell, 4)] = true
	assert_eq(seen.size(), 4)


## Worst screen-pixel jump of the torso mark between consecutive ticks over a heading change.
func _jump(path: String, second: Vector2, restart: bool) -> float:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(path)
	var at: Vector2 = Vector2.ZERO
	var previous: Vector2 = Vector2.INF
	var worst: float = 0.0
	var scale_px: Vector2 = Vector2(0.269, 0.253)
	for tick: int in 100:
		var heading: Vector2 = Vector2(1.0, 0.18) if tick < 40 else second
		at += heading.normalized() * 1.6 * 32.0 * SimClock.TICK_DT
		if tick == 40 and restart:
			contact.reset()
		var xf: Transform2D = contact.place(at, Vector2i(1, 0), scale_px, 32.0)
		var ink: Vector4 = contact.registered.marks[4 + posmod(contact.cell, 4)]
		var body: Vector2 = xf * Vector2(ink.z, ink.w)
		if previous.is_finite() and not (tick == 40 and restart):
			worst = maxf(worst, body.distance_to(previous))
		previous = body
	return worst


func test_door_turn_and_reversal_stay_within_twelve_screen_pixels() -> void:
	for pitch: String in ["p70", "p55"]:
		var path: String = pitch.path_join(CastDoorAnchors.SHEET)
		var turn: float = _jump(path, Vector2(0.2, 1.0), false)
		var reversal: float = _jump(path, Vector2(-0.8, 0.9), true)
		gut.p("%s door turn %.3f px, reversal %.3f px" % [pitch, turn, reversal])
		assert_lte(turn, 12.0, "%s turn %.3f px" % [pitch, turn])
		assert_lte(reversal, 12.0, "%s reversal %.3f px" % [pitch, reversal])
