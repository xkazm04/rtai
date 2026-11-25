extends GutTest
## n31 ground (CardContactShadow): a card foe's contact shadow stays on the ground point while the
## drawing bounces and steps, and is sized from the drawn cell width.

const GROUND: Vector2 = Vector2(320.0, 180.0)


func _card() -> Sprite2D:
	var host: Node2D = add_child_autofree(Node2D.new())
	host.position = Vector2(40.0, -25.0)
	var card: Sprite2D = Sprite2D.new()
	card.texture = ImageTexture.create_from_image(Image.create(400, 120, false, Image.FORMAT_RGBA8))
	card.hframes = 5
	card.scale = Vector2(1.5, 1.5)
	host.add_child(card)
	return card


func test_the_shadow_stays_on_the_ground_point_through_a_bounce() -> void:
	var card: Sprite2D = _card()
	var shadow: CardContactShadow = CardContactShadow.mount(card)
	var host: Node2D = card.get_parent() as Node2D
	for lift: float in [0.0, -9.0, -24.0, 6.0]:
		card.position = GROUND + Vector2(3.0, lift)  # the drawing's bounce and placement step
		shadow.follow(card, GROUND)
		var at: Vector2 = shadow.global_position
		assert_almost_eq(at.x, host.to_global(GROUND).x, 0.01, str(lift))
		assert_almost_eq(at.y, host.to_global(GROUND).y, 0.01, str(lift))


func test_the_shadow_is_upright_and_unscaled_whatever_the_card_transform() -> void:
	var card: Sprite2D = _card()
	var shadow: CardContactShadow = CardContactShadow.mount(card)
	card.transform = Transform2D(0.0, Vector2(0.42, 0.37), 0.0, GROUND + Vector2(0.0, -12.0))
	shadow.follow(card, GROUND)
	var host: Node2D = card.get_parent() as Node2D
	var t: Transform2D = host.global_transform.affine_inverse() * shadow.global_transform
	assert_almost_eq(t.get_scale().x, 1.0, 0.0001)
	assert_almost_eq(t.get_scale().y, 1.0, 0.0001)
	assert_almost_eq(t.get_rotation(), 0.0, 0.0001)


func test_the_radius_is_a_share_of_the_drawn_cell_width() -> void:
	var card: Sprite2D = _card()
	var shadow: CardContactShadow = CardContactShadow.mount(card)
	shadow.follow(card, GROUND)
	var want: float = 400.0 / 5.0 * 1.5 * CardContactShadow.WIDTH_SHARE
	assert_almost_eq(shadow.radius, want, 0.0001)
	assert_almost_eq(CardContactShadow.radius_of(card), want, 0.0001)
	card.scale = Vector2(-3.0, 3.0)  # a mirrored, larger drawing: the width only
	assert_almost_eq(CardContactShadow.radius_of(card), want * 2.0, 0.0001)


func test_a_narrow_drawing_keeps_the_floor_radius() -> void:
	var card: Sprite2D = _card()
	card.scale = Vector2(0.05, 0.05)
	var floor_r: float = (
		RigCastShadows.CONTACT_R_HIPS * CardContactShadow.FLOOR_HIP_M * SimConst.PX_PER_M
	)
	assert_almost_eq(CardContactShadow.radius_of(card), floor_r, 0.0001)


func test_it_draws_behind_its_card_only_when_the_view_casts() -> void:
	var previous: ViewMode = ViewMode.shared()
	var card: Sprite2D = _card()
	var shadow: CardContactShadow = CardContactShadow.mount(card)
	assert_true(shadow.show_behind_parent)
	ViewMode.select("combo")
	shadow.follow(card, GROUND)
	assert_eq(shadow.visible, ViewMode.shared().cast_k > 0.0)
	ViewMode.select("top")
	shadow.follow(card, GROUND)
	assert_false(shadow.visible)
	ViewMode._shared = previous
