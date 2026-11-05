extends GutTest
## n7-melee: Tonnage's plates stop an enemy round at their edge and print one spark on the first
## contact (PlateSparks, ghost_attacks.json tonnage plate_*); Rivet's own rounds, the form off and
## plate_spark_ticks 0 leave none; at most plate_sparks_per_tick new sparks a tick.


func _plates(on: bool) -> PlateSparks:
	var h: HaulerStage = HaulerStage.shipped()
	h.form.on = on
	for i: int in 120:  # grown in (morph_k 1)
		h.form.step(Vector2.ZERO)
	var p: PlateSparks = PlateSparks.make(h)
	p.enabled = true  # the run's --feel flag is not under test
	return p


## An enemy round heading +x along y = `y`, its head at x = `x`.
func _round(x: float, y: float = 0.0, rivet: bool = false) -> Shot:
	var s: Shot = Shot.new()
	s.pos = Vector2(x, y)
	s.vel = Vector2(40.0, 0.0)
	s.from_rivet = rivet
	return s


func test_the_shipped_row_loads() -> void:
	var p: PlateSparks = PlateSparks.make(HaulerStage.shipped())
	assert_gt(p.r_m, 0.0)
	assert_gt(p.spark_ticks, 0)
	assert_gt(p.per_tick, 0)


func test_a_round_short_of_the_plates_draws_as_before() -> void:
	var p: PlateSparks = _plates(true)
	assert_eq(p.edge(_round(-5.0), Vector2.ZERO, 1.2, 10), Vector2.INF)
	assert_eq(p.marks.size(), 0)


func test_a_round_at_the_plates_stops_at_the_edge_with_one_spark() -> void:
	var p: PlateSparks = _plates(true)
	var s: Shot = _round(-0.5)
	var at: Vector2 = p.edge(s, Vector2.ZERO, 1.2, 10)
	assert_almost_eq(at.x, -p.r_m, 0.001)
	assert_eq(p.marks.size(), 1)
	assert_almost_eq(Vector2.from_angle(p.marks[0].z).x, -1.0, 0.001, "bounces back off the face")
	s.pos.x += 0.6
	@warning_ignore("return_value_discarded")
	p.edge(s, Vector2.ZERO, 1.2, 11)
	assert_eq(p.marks.size(), 1, "one spark per round")


func test_a_stopped_round_past_the_plates_stays_hidden() -> void:
	var p: PlateSparks = _plates(true)
	var s: Shot = _round(-0.5, 0.9)
	@warning_ignore("return_value_discarded")
	p.edge(s, Vector2.ZERO, 1.2, 10)
	s.pos.x = 4.0
	var at: Vector2 = p.edge(s, Vector2.ZERO, 1.2, 12)
	assert_almost_eq(at.x, s.pos.x - 1.2, 0.001, "the tracer collapses to its tail")


func test_planted_rivet_round_and_form_off_leave_no_spark() -> void:
	var p: PlateSparks = _plates(true)
	assert_eq(p.edge(_round(-0.5, 0.0, true), Vector2.ZERO, 1.2, 10), Vector2.INF)
	var off: PlateSparks = _plates(false)
	assert_eq(off.edge(_round(-0.5), Vector2.ZERO, 1.2, 10), Vector2.INF)
	assert_eq(p.marks.size() + off.marks.size(), 0)


func test_the_per_tick_cap_holds_a_burst() -> void:
	var p: PlateSparks = _plates(true)
	for i: int in 6:
		var at: Vector2 = p.edge(_round(-0.5, 0.1 * i), Vector2.ZERO, 1.2, 20)
		assert_ne(at, Vector2.INF, "every round still stops")
	assert_eq(p.marks.size(), p.per_tick)
	@warning_ignore("return_value_discarded")
	p.edge(_round(-0.5, -0.3), Vector2.ZERO, 1.2, 21)
	assert_eq(p.marks.size(), p.per_tick + 1, "the next tick sparks again")


func test_planted_morphing_in_draws_through() -> void:
	var h: HaulerStage = HaulerStage.shipped()
	h.form.on = true
	h.form.step(Vector2.ZERO)  # one tick into the grow: no press drawn yet
	var p: PlateSparks = PlateSparks.make(h)
	p.enabled = true
	assert_lt(h.form.morph_k(), PlateSparks.MORPH_MIN)
	assert_eq(p.edge(_round(-0.5), Vector2.ZERO, 1.2, 10), Vector2.INF)
	assert_eq(p.marks.size(), 0)
