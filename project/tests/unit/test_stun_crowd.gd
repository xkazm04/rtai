extends GutTest
## n7-melee: the stun_crowd cap (StunCrowd.light_ids): past the newest `full` stunned bodies
## the rest draw the lighter crawl; no cap at full 0.


func test_shipped_cap_two_full_then_no_arc_one_spit_one_spark() -> void:
	assert_eq(ReactTable.stun_crowd(), Vector4i(2, 0, 1, 1))
	assert_eq(StunCrowd.cap(), Vector4i(2, 0, 1, 1))


func test_newest_two_keep_the_full_crawl() -> void:
	var s: Array[Vector2i] = [Vector2i(5, 40), Vector2i(6, 72), Vector2i(7, 72), Vector2i(8, 10)]
	var light: Dictionary[int, bool] = StunCrowd.light_ids(s, 2)
	assert_eq(light.keys().size(), 2)
	assert_true(light.has(5))
	assert_true(light.has(8))
	assert_false(light.has(6))
	assert_false(light.has(7))


func test_ties_go_to_the_lower_id() -> void:
	var s: Array[Vector2i] = [Vector2i(9, 72), Vector2i(3, 72), Vector2i(4, 72)]
	var light: Dictionary[int, bool] = StunCrowd.light_ids(s, 2)
	assert_eq(light.keys(), [9])


func test_planted_no_cap_at_full_zero_or_few_bodies() -> void:
	var s: Array[Vector2i] = [Vector2i(1, 72), Vector2i(2, 72), Vector2i(3, 72)]
	assert_true(StunCrowd.light_ids(s, 0).is_empty())
	assert_true(StunCrowd.light_ids(s, 3).is_empty())
	assert_true(StunCrowd.light_ids([] as Array[Vector2i], 2).is_empty())
