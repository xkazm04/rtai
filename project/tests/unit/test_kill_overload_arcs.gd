extends GutTest
## n31 melee 04g: the baton overload's amber current (KillOverloadArcs) draws the row's arc count
## from the kill tick to its arc_ticks, past the drawn cells' start, and spans his body.


func _death(row_id: StringName) -> KillNewStyles.Death:
	var d: KillNewStyles.Death = KillNewStyles.Death.new()
	d.serial = 4
	d.extra = KillTrackRows.of(row_id)
	d.dir = Vector2.RIGHT
	d.feet_px = Vector2(0.0, 100.0)
	d.head_px = Vector2(0.0, 44.0)
	d.height = 64.0
	return d


func test_the_row_draws_four_arcs_until_just_after_his_fall() -> void:
	var extra: KillTrackRows.Extra = KillTrackRows.of(&"baton_overload")
	assert_eq(KillOverloadArcs.count(extra), 4)
	assert_eq(KillOverloadArcs.ticks(extra), 48)
	assert_false(KillOverloadArcs.live(extra, -1))
	assert_true(KillOverloadArcs.live(extra, 0), "live on the kill tick")
	assert_true(KillOverloadArcs.live(extra, roundi(extra.num("cells_at", 0.0))))
	assert_false(KillOverloadArcs.live(extra, 48))
	assert_eq(KillOverloadArcs.fade(extra, 20), 1.0)
	assert_lt(KillOverloadArcs.fade(extra, 47), 1.0, "the tail fades")


func test_every_victim_keeps_the_current_past_his_drawn_cells() -> void:
	for victim: String in ["contractor", "patrol_cop", "riot_cop", "rocket_trooper", "swat"]:
		var extra: KillTrackRows.Extra = KillTrackRows.of(StringName("baton_overload_" + victim))
		assert_eq(KillOverloadArcs.count(extra), 4, victim)
		var at: int = roundi(extra.num("cells_at", 0.0))
		assert_eq(KillOverloadArcs.ticks(extra), at + 3, victim)


func test_a_row_without_arc_n_draws_none() -> void:
	var extra: KillTrackRows.Extra = KillTrackRows.Extra.new()
	assert_eq(KillOverloadArcs.count(extra), 0)
	assert_false(KillOverloadArcs.live(extra, 0))
	extra.fx["arc_n"] = 9.0
	assert_eq(KillOverloadArcs.count(extra), KillOverloadArcs.MAX_ARCS, "clamped")


func test_the_arcs_span_most_of_his_height_from_the_contact() -> void:
	var d: KillNewStyles.Death = _death(&"baton_overload")
	var ends: Array[PackedVector2Array] = KillOverloadArcs.ends(d, 32.0)
	assert_eq(ends.size(), 4)
	var top: float = INF
	var low: float = -INF
	for pair: PackedVector2Array in ends:
		assert_eq(pair[0], KillOverloadArcs.contact(d, 32.0), "every arc starts at the contact")
		top = minf(top, pair[1].y)
		low = maxf(low, pair[1].y)
	var tall: float = d.feet_px.y - d.head_px.y
	assert_gt((low - top) / tall, 0.6, "head to ground: over 60 % of his figure")
	assert_lt(KillOverloadArcs.contact(d, 32.0).x, 0.0, "the contact sits back toward the baton")


func test_the_jag_is_a_replay_and_holds_under_reduced_motion() -> void:
	var pts: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(0.0, -1.5)])
	assert_eq(ElectricArc.shape(pts, 64, 7, false), ElectricArc.shape(pts, 64, 7, false))
	assert_eq(ElectricArc.shape(pts, 64, 0, true), ElectricArc.shape(pts, 64, 30, true))
	assert_ne(ElectricArc.shape(pts, 64, 0, false), ElectricArc.shape(pts, 64, 30, false))
