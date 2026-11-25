extends GutTest
## The door carrier's selected walk (CastDoorAnchors.WALK: the four or the n29 eight), planted on a
## measured sole table.


## Drawings per facing of the selected walk.
func _rows() -> int:
	return 8 if CastDoorAnchors.WALK == CastDoorAnchors.EIGHT else 4


func test_door_sheet_is_anchored_at_the_shipped_size() -> void:
	var path: String = "p70/" + CastDoorAnchors.SHEET
	assert_true(CastCards.anchored(path))
	assert_eq(StreetCopWalk.rows_of(path), _rows())
	assert_eq(StreetCopWalk.fill_of(path), 1.0)
	assert_eq(CastCardKinds.cell_ratio(path, StreetCopWalk.CELL_RATIO), 1.0)
	assert_eq(CastCardKinds.cell_ratio("p70/" + CastRiotAnchors.EIGHT, 1.5), 1.5)


func test_door_marks_cover_five_facings_of_the_selected_walk() -> void:
	assert_eq(CastDoorAnchors.WALK70.size(), 5 * _rows())
	assert_eq(CastDoorAnchors.WALK55.size(), 5 * _rows())
	var pose: StreetPatrolPose = StreetPatrolPose.new()
	var step: float = pose.configure("p55/" + CastDoorAnchors.SHEET, _rows(), false)
	assert_eq(step, CastDoorAnchors.WALK_STEP_M)
	assert_between(1.6 / step, 5.0, 10.0)
	assert_eq(pose.marks.size(), 5 * _rows())


func test_door_contact_cycles_its_drawings() -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure("p70/" + CastDoorAnchors.SHEET)
	assert_eq(contact.drawings, _rows())
	assert_not_null(contact.registered)
	var seen: Dictionary[int, bool] = {}
	var at: Vector2 = Vector2.ZERO
	for tick: int in 200:
		at += Vector2.RIGHT * 1.6 * 32.0 * SimClock.TICK_DT
		@warning_ignore("return_value_discarded")
		contact.place(at, Vector2i(2, 0), Vector2(0.27, 0.25), 32.0)
		seen[posmod(contact.cell, _rows())] = true
	assert_eq(seen.size(), _rows())


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
		var ink: Vector4 = contact.registered.marks[_rows() + posmod(contact.cell, _rows())]
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


func test_every_derived_door_table_follows_the_one_walk_value() -> void:
	var eight: bool = CastDoorAnchors.WALK == CastDoorAnchors.EIGHT
	assert_true(eight or CastDoorAnchors.WALK == CastDoorAnchors.FOUR)
	assert_eq(CastDoorAnchors.SHEET, CastDoorAnchors.WALK)
	assert_eq(CastDoorAnchors.WALK70, CastDoorAnchors.EIGHT70 if eight else CastDoorAnchors.FOUR70)
	assert_eq(CastDoorAnchors.WALK55, CastDoorAnchors.EIGHT55 if eight else CastDoorAnchors.FOUR55)
	var step: float = CastDoorAnchors.EIGHT_STEP_M if eight else CastDoorAnchors.FOUR_STEP_M
	assert_eq(CastDoorAnchors.WALK_STEP_M, step)
	assert_eq(CastCardKinds.foe_marks(CastDoorAnchors.SHEET, false), CastDoorAnchors.WALK70)
	assert_eq(CastCardKinds.foe_marks(CastDoorAnchors.SHEET, true), CastDoorAnchors.WALK55)
	assert_eq(CastCardKinds.foe_step(CastDoorAnchors.SHEET), CastDoorAnchors.WALK_STEP_M)


## The door's drawn height (n29 size scene: 111 px at 64 px/m with the table's body_scale 1.03):
## 2 m over the 160-texel body, 0.4 px per texel at 32 px/m (0.8 at 64), linear in body_scale.
func test_door_height_is_two_metres_over_its_160_texel_body() -> void:
	var card: FoeShieldCardView = autofree(FoeShieldCardView.new())
	for case: Vector2 in [Vector2(1.0, 0.4), Vector2(1.03, 0.412), Vector2(2.5, 1.0)]:
		card.pose.sheets = CastCards.Sheets.new()
		card.pose.sheets.body_scale = case.x
		card._rescale(false)
		assert_almost_eq(card.scale, Vector2(case.y, case.y), Vector2(1e-5, 1e-5))
