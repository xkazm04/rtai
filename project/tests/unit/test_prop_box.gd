extends GutTest

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved


func test_the_front_face_spans_the_lift_above_the_south_edge() -> void:
	var r: Rect2 = Rect2(10, 20, 86, 67)
	var f: Rect2 = PropBox.front_rect(r, 16.0)
	assert_eq(f, Rect2(10, 71, 86, 16), "as wide as the footprint, ending on its south edge")


func test_a_crate_lifts_by_its_height_under_a_tilt_only() -> void:
	var h: float = PropBox.HEIGHT_M["tuckin_crate"]
	ViewMode._shared = ViewMode.of("top")
	assert_eq(ViewMode.shared().lift_px(h), Vector2.ZERO, "top: the flat draw, unchanged")
	ViewMode._shared = ViewMode.of("tilt70")
	assert_gt(-ViewMode.shared().lift_px(h).y, 0.0, "tilt70: the top stands above the ground")
	assert_false(PropBox.HEIGHT_M.has("payphone"), "a card or a flat sprite is not a box")
