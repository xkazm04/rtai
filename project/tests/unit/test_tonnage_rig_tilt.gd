extends GutTest
## d8 chars: Tonnage stands on its legs under a tilted view (crown, head and hoses lifted by their
## heights, feet planted) and is exactly the flat rig straight down.

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared
	GhostLook.override_for_test(GhostLook.LEGACY)


func after_each() -> void:
	GhostLook.reset_for_test()
	ViewMode._shared = _saved


func _rig(view: String) -> TonnageRig:
	ViewMode._shared = ViewMode.of(view)
	var rig: TonnageRig = TonnageRig.new()
	add_child_autofree(rig)
	rig.pose()
	return rig


func test_straight_down_the_parts_sit_where_they_always_did() -> void:
	var rig: TonnageRig = _rig("top")
	assert_eq(rig._crown.position, Vector2.ZERO)
	assert_eq(rig._head.position, Vector2(1.12, 0.0) * TonnageRig.PX_PER_M)
	assert_eq(rig._hoses.position, Vector2(-0.55, 0.0) * TonnageRig.PX_PER_M)


func test_under_tilt_the_body_rises_and_the_feet_stay_planted() -> void:
	var flat: TonnageRig = _rig("top")
	var feet: Array[Vector2] = []
	for f: Sprite2D in flat._feet:
		feet.append(f.position)
	var rig: TonnageRig = _rig("tilt")
	assert_lt(rig._crown.position.y, -10.0, "the crown rides up the screen")
	assert_lt(rig._hoses.position.y, rig._crown.position.y, "the hoses ride above the crown")
	for i: int in 4:
		assert_eq(rig._feet[i].position, feet[i], "a standing foot stays on its ground point")


func test_spectral_tilts_show_one_custom_rest_cell() -> void:
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	for view: String in ["tilt70", "tilt"]:
		var rig: TonnageRig = _rig(view)
		rig.drawn.feed(0, -1, 72)
		var sheets: Array[String] = []
		for spr: Sprite2D in rig.find_children("ghost_drawn*", "Sprite2D", true, false):
			if spr.is_visible_in_tree():
				sheets.append(spr.texture.resource_path)
		var path: String = GhostDrawn.path_of(ViewMode.shared().art, "tonnage", "spectral_pose")
		assert_eq(sheets, [path], view)
