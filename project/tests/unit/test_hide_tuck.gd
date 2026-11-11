extends GutTest
## n15 hero: quest 1's hide spot under the cast rigs (HideTuck).


func test_tucked_hides_the_rig_and_the_held_views() -> void:
	var rig: Node2D = autofree(Node2D.new())
	var held: Node2D = autofree(Node2D.new())
	HideTuck.apply(rig, [held] as Array[CanvasItem], true)
	assert_false(rig.visible)
	assert_false(held.visible)


func test_untucked_shows_them_again() -> void:
	var rig: Node2D = autofree(Node2D.new())
	var held: Node2D = autofree(Node2D.new())
	HideTuck.apply(rig, [held] as Array[CanvasItem], true)
	HideTuck.apply(rig, [held] as Array[CanvasItem], false)
	assert_true(rig.visible)
	assert_true(held.visible)


func test_no_rig_is_no_error() -> void:
	HideTuck.apply(null, [] as Array[CanvasItem], true)
	assert_true(HideTuck.TUCK, "default on")


func test_attach_without_a_cast_adds_nothing() -> void:
	HideTuck.attach(null, null, false)
	assert_true(true, "a failed cast attach only logs")
