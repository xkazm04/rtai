extends GutTest

const POSE = KerfRoninDrawn.Pose
var _view: StringName


func before_each() -> void:
	_view = ViewMode.shared().id


func after_each() -> void:
	ViewMode.select(_view)


func test_only_the_next_spent_lamp_relights_in_the_final_four_ticks() -> void:
	for charges: int in range(4):
		for i: int in 3:
			var full: Color = Color.TRANSPARENT if i < charges else KerfChargeSlots.STEEL
			assert_eq(KerfChargeSlots.tint(i, charges, 0.0), full)
			assert_eq(KerfChargeSlots.tint(i, charges, 0.93), full)
			var end: Color = KerfChargeSlots.RELIGHT if i == charges else full
			assert_true(KerfChargeSlots.tint(i, charges, 1.0).is_equal_approx(end))
	var almost: Color = KerfChargeSlots.tint(1, 1, 59.0 / 60.0)
	assert_gt(almost.g, 0.85)


func test_every_mask_uses_its_printed_centre_and_follows_the_flipped_plate() -> void:
	var card: KerfRoninDrawn = add_child_autofree(KerfRoninDrawn.new())
	card.position = Vector2(83, 21)
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		for oct: int in 8:
			for pose_id: int in 8:
				card.show_pose(oct, pose_id as KerfRoninDrawn.Pose, 0.0, 0.17, false)
				var frame: int = card.frame
				var sheet: int = card.sheet_id
				var points: PackedVector2Array = KerfChargeSlots.cell(sheet, frame).slots
				for count: int in range(4):
					card.slots.paint(sheet, count, 0.0)
					for i: int in 3:
						var mask: Sprite2D = card.slots.masks[i]
						assert_eq(mask.visible, i >= count and i < points.size())
						if mask.visible:
							var xy: Vector2 = points[i].round()
							if card.flip_h:
								xy.x = card.get_rect().size.x - xy.x
							var at: Vector2 = card.to_global(card.offset + xy)
							assert_true(mask.global_position.is_equal_approx(at))
							assert_eq(mask.flip_h, card.flip_h)
							assert_eq(mask.frame_coords.x, pose_id % 4 * 3 + i)
							assert_eq(mask.frame_coords.y, sheet * 5 + card.frame_coords.y)


func test_occluded_profile_has_no_overlays_even_with_all_charges_spent() -> void:
	ViewMode.select("tilt70")
	var card: KerfRoninDrawn = add_child_autofree(KerfRoninDrawn.new())
	card.show_pose(2, POSE.HOVER, 0, 0, false)
	card.slots.paint(card.sheet_id, 0, 0)
	assert_true(card.slots.masks[2].visible)
	card.show_pose(0, POSE.CUT, 0, 0, false)
	card.slots.paint(card.sheet_id, 0, 0)
	for mask: Sprite2D in card.slots.masks:
		assert_false(mask.visible)


func test_top_lamps_ride_the_torso_and_spend_from_its_right_edge() -> void:
	var top: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	for count: int in range(4):
		top.slots.paint(KerfChargeSlots.TOP, count, 0)
		for i: int in 3:
			var mask: Sprite2D = top.slots.masks[i]
			assert_eq(mask.visible, i >= count)
			if mask.visible:
				assert_same(mask.get_parent(), top.get_node("torso"))
				assert_eq(mask.frame_coords, Vector2i(i, 20))
				if i > count:
					assert_gt(mask.position.x, top.slots.masks[i - 1].position.x)
