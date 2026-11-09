extends GutTest
## n11 (the owner: blood reads poorly): a drop in the air is a rounded head on a tapering tail, not
## a square-ended bar. The draw is bucketed by width, so the shape is measured from the segments.


func test_a_drop_is_a_head_wider_than_its_tail() -> void:
	var at: Vector2 = Vector2(100.0, 100.0)
	var segs: Array[Vector3] = BloodBatch.drop_segments(at, Vector2(20.0, 0.0), 6.0)
	assert_gt(segs.size(), 3, "more than one bar: a head, a chord, a neck, a tail")
	var across: float = 0.0
	var thinnest: float = INF
	var head: float = 0.0
	for k: int in segs.size():
		across = maxf(across, absf(segs[k].y - at.y))
		thinnest = minf(thinnest, segs[k].z)
		if k < 4:
			head = maxf(head, segs[k].z)
	assert_almost_eq(across, 3.0, 0.001, "the head reaches half the drop's width to each side")
	assert_lt(thinnest, head * 0.5, "the tail thins to under half the head's bars")


func test_the_tail_trails_behind_the_head() -> void:
	var at: Vector2 = Vector2(100.0, 100.0)
	var segs: Array[Vector3] = BloodBatch.drop_segments(at, Vector2(20.0, 0.0), 6.0)
	var last: Vector3 = segs[segs.size() - 1]
	assert_lt(last.x, at.x, "the last, thinnest piece lies behind the drop along its travel")


func test_a_still_drop_is_still_a_round_blob() -> void:
	var segs: Array[Vector3] = BloodBatch.drop_segments(Vector2.ZERO, Vector2.ZERO, 4.0)
	assert_gt(segs.size(), 1, "no travel: the head and its chord still draw")
