extends GutTest
## d8 chars: a ghost rig's facing card (GhostCard, Tonnage's press) draws only under a view with
## cards and art whose strip exists, hides the top-down body parts while it draws, and leaves the
## rig untouched straight down.

var _saved: ViewMode = null


func before_each() -> void:
	_saved = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved


func _rig(view: String) -> TonnageRig:
	ViewMode._shared = ViewMode.of(view)
	var rig: TonnageRig = TonnageRig.new()
	add_child_autofree(rig)
	rig.pose()
	return rig


func test_straight_down_no_card_and_every_part_shows() -> void:
	var rig: TonnageRig = _rig("top")
	assert_false(rig._card.is_drawn())
	assert_null(rig.get_node_or_null(^"ghost_card"))
	for p: Sprite2D in [rig._crown, rig._head, rig._hoses]:
		assert_true(p.visible)


func test_under_tilt_the_card_draws_when_its_strip_exists() -> void:
	var rig: TonnageRig = _rig("tilt")
	var want: bool = ResourceLoader.exists(GhostCard.path_of(ViewMode.of("tilt").art, "tonnage"))
	assert_eq(rig._card.is_drawn(), want, "a card iff the view's strip exists")
	assert_eq(rig._crown.visible, not want, "the crown hides under the card")
	assert_eq(rig._hoses.visible, not want)


func test_a_view_without_the_strip_draws_no_card() -> void:
	var v: ViewMode = ViewMode.of("tilt")
	v.art = "no_such_art"
	ViewMode._shared = v
	var rig: TonnageRig = TonnageRig.new()
	add_child_autofree(rig)
	rig.pose()
	assert_false(rig._card.is_drawn())
	assert_true(rig._crown.visible)


func test_the_drawn_card_stands_upright_and_undoes_the_ground_squash() -> void:
	var rig: TonnageRig = _rig("tilt")
	if not rig._card.is_drawn():
		pending("no tonnage card strip under the tilt art")
		return
	rig.rotation = 1.0
	rig.pose()
	var card: Sprite2D = rig.get_node(^"ghost_card") as Sprite2D
	assert_almost_eq(card.global_rotation, 0.0, 0.0001, "upright whatever the facing")
	assert_gt(card.global_scale.y, card.global_scale.x, "taller than wide by the squash")
	assert_lt(card.position.y, 0.0, "it stands at the lifted crown point")


func test_a_halo_draws_behind_the_card_in_its_facing() -> void:
	var rig: OhmRig = OhmRig.new()
	ViewMode._shared = ViewMode.of("tilt")
	add_child_autofree(rig)
	rig.rotation = PI
	rig.pose()
	if not rig._card.is_drawn():
		pending("no ohm card strip under the tilt art")
		return
	var card: Sprite2D = rig.get_node(^"ghost_card") as Sprite2D
	var halo: Sprite2D = card.get_node(^"halo") as Sprite2D
	assert_true(halo.show_behind_parent, "behind the card")
	assert_eq(halo.frame, card.frame, "the same facing")
	assert_eq(halo.flip_h, card.flip_h)
	assert_gt(halo.scale.x, 1.0, "a rim around the card")
