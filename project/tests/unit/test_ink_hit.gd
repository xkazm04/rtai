extends GutTest
## n12 C1: a struck figure's card wears the heavier ink line for its class's flash window, eased
## back, and gets its own material back after; nothing at rest carries it.

var _rig: CutRig
var _card: Sprite2D


func before_each() -> void:
	InkHit.reset()
	_rig = CutRig.new()
	_card = Sprite2D.new()
	_card.hframes = 5
	_card.vframes = 8
	_rig.head_card = _card


func after_each() -> void:
	InkHit.reset()
	_card.free()
	_rig.free()


func test_every_class_has_a_line_and_a_window() -> void:
	for cls: StringName in [&"light", &"medium", &"heavy", &"blast", &"melee"]:
		var row: Vector2i = InkHit.row_of(cls)
		assert_gt(row.x, 0, "%s draws a heavier line" % cls)
		assert_gt(row.y, 0, "%s has a window" % cls)
	assert_gt(InkHit.row_of(&"blast").x, InkHit.row_of(&"light").x, "a blast presses harder")


func test_the_line_is_full_on_the_hit_tick_and_gone_by_the_window_end() -> void:
	assert_eq(InkHit.level_at(4, 0, 6), 4)
	assert_lt(InkHit.level_at(4, 3, 6), 4, "it eases back")
	assert_eq(InkHit.level_at(4, 6, 6), 0)
	assert_eq(InkHit.level_at(4, -1, 6), 0, "nothing before the hit")


func test_the_struck_card_wears_the_line_then_gets_its_own_back() -> void:
	var own: ShaderMaterial = ShaderMaterial.new()
	_card.material = own
	InkHit.hit(_rig, &"heavy", 100)
	InkHit.step(100)
	assert_ne(_card.material, own, "the line material while struck")
	var edge: float = (_card.material as ShaderMaterial).get_shader_parameter("hit_edge")
	assert_gt(edge, 0.0)
	var cells: Vector2 = (_card.material as ShaderMaterial).get_shader_parameter("cells")
	assert_eq(cells, Vector2(5, 8), "the ring stays inside the card's own frame")
	InkHit.step(100 + InkHit.row_of(&"heavy").y)
	assert_eq(_card.material, own, "its own material back")
	assert_eq(InkHit.live(), 0)


func test_a_raw_card_goes_back_to_no_material() -> void:
	_card.material = null
	InkHit.hit(_rig, &"light", 10)
	InkHit.step(10)
	assert_not_null(_card.material)
	InkHit.step(10 + InkHit.row_of(&"light").y)
	assert_null(_card.material)


func test_a_class_with_no_line_dresses_nothing() -> void:
	InkHit.hit(_rig, &"no_such_class", 10)
	InkHit.step(10)
	assert_null(_card.material)
	assert_eq(InkHit.live(), 0)


func test_one_shared_material_per_level_and_grid() -> void:
	assert_same(InkHit.material(3, Vector2i(5, 8)), InkHit.material(3, Vector2i(5, 8)))
	assert_ne(InkHit.material(3, Vector2i(5, 8)), InkHit.material(3, Vector2i(5, 1)))


func test_the_warm_draws_the_line_material_once_behind_the_load() -> void:
	var parent: Node2D = Node2D.new()
	add_child_autofree(parent)
	InkHit.warm(parent)
	assert_eq(parent.get_child_count(), 1)
	var s: Sprite2D = parent.get_child(0) as Sprite2D
	assert_same(
		s.material, InkHit.material(1), "the line's own material, so its shader compiles now"
	)
	assert_lt(s.modulate.a, 0.05, "and nobody sees it")


func test_levels_and_px_follow_the_table_exactly() -> void:
	assert_eq(
		InkHit.row_of(&"light"), Vector2i(2, 4), "1 px over 4 ticks: level 2 at 0.5 px a level"
	)
	assert_eq(InkHit.row_of(&"blast").x, 5, "2.5 px")
	assert_eq(InkHit.px_of(2), 1.0)
	assert_eq(InkHit.px_of(99), InkHit.px_of(InkHit.MAX_LEVEL), "capped")
	assert_eq(InkHit.px_of(-3), 0.0)


func test_a_restored_card_keeps_no_trace_and_reset_forgets_the_pulses() -> void:
	InkHit.hit(_rig, &"light", 10)
	InkHit.step(10)
	assert_true(_card.has_meta(InkHit.META))
	InkHit.step(14)
	assert_false(_card.has_meta(InkHit.META), "no leftover meta")
	InkHit.hit(_rig, &"light", 20)
	assert_eq(InkHit.live(), 1)
	InkHit.reset()
	assert_eq(InkHit.live(), 0)
	assert_eq(InkHit.row_of(&"light").x, 2, "the table re-reads after a reset")


func test_no_pulse_for_a_missing_rig() -> void:
	InkHit.hit(null, &"blast", 10)
	assert_eq(InkHit.live(), 0)


func test_the_warm_needs_a_parent_in_the_tree_and_cleans_up() -> void:
	InkHit.warm(null)
	var loose: Node2D = Node2D.new()
	InkHit.warm(loose)
	assert_eq(loose.get_child_count(), 0, "not in the tree: nothing")
	loose.free()
	var parent: Node2D = Node2D.new()
	add_child_autofree(parent)
	InkHit.warm(parent)
	assert_eq(parent.get_child_count(), 1)
	await wait_seconds(0.3)
	assert_eq(parent.get_child_count(), 0, "the warm sprite is gone after its tenth of a second")
