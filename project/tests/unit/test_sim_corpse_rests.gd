extends GutTest
## The owner's note (2026-11-09): "Bodies often lag and move across the screen even if they should
## be static". The city sim's dead (the far crowd draws them at the sim point): once the throw has
## run out, a body's row does not change on any tick, while Rivet walks across the heap.

const COUNT: int = 12
const THROW: Vector2 = Vector2(3.0, 1.0)
const SLIDE_TICKS: int = 90
const WATCH_TICKS: int = 240
const WALK: Vector2 = Vector2(3.0, 0.0)


func test_the_cities_dead_stay_exactly_where_they_stopped() -> void:
	var st: BodiesStage = BodiesStage.new()
	assert_eq(st.setup(20.0), "")
	var slots: Array[int] = []
	for i: int in COUNT:
		var slot: int = st.stand(st.band + Vector2(3.0 + float(i) * 0.8, 0.0))
		assert_gte(slot, 0, "spawned")
		slots.append(slot)
	st.tick(Vector2.ZERO)  # a person has its tier from the first step on
	for slot: int in slots:
		st.sim.strike(slot, THROW.x, THROW.y, true)
	for _t: int in SLIDE_TICKS:
		st.tick(Vector2.ZERO)
	var rest: Dictionary[int, Vector2] = {}
	for slot: int in slots:
		var p: PackedFloat64Array = st.person(slot)
		assert_false(p.is_empty(), "slot %d still has a row" % slot)
		if p.is_empty():
			continue
		assert_eq(int(p[1]), SimConst.M_DEAD, "slot %d is dead" % slot)
		rest[slot] = Vector2(p[2], p[3])
	var worst: float = 0.0
	for _t: int in WATCH_TICKS:
		st.tick(WALK)
		for slot: int in slots:
			var p: PackedFloat64Array = st.person(slot)
			if p.is_empty():
				continue
			worst = maxf(worst, Vector2(p[2], p[3]).distance_to(rest[slot]))
	assert_eq(worst, 0.0, "a settled body's row moved")
	assert_gt(st.body.pos.x - st.band.x, 3.0 + float(COUNT) * 0.8 - 3.0, "Rivet crossed the heap")
