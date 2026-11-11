extends GutTest
## n16 kills-polish (ray gun dissolve, KILLS ranking): the clip mask was a 0.62 m disc on the body
## group's origin (about the hips), so an upright 1.7 m walker card kept only its legs from the
## first eaten tick. The mask is now an ellipse fitted to the drawn figure's sprites.


func _body(tall_px: float, up_px: float) -> Node2D:
	var body: Node2D = Node2D.new()
	body.name = "body"
	var tex: PlaceholderTexture2D = PlaceholderTexture2D.new()
	tex.size = Vector2(tall_px * 0.4, tall_px)
	var card: Sprite2D = Sprite2D.new()
	card.texture = tex
	card.position = Vector2(0.0, -up_px)
	body.add_child(card)
	return body


func test_the_ellipse_sits_on_the_figure_and_holds_it() -> void:
	var root: Node2D = KillDissolveMask.wrap(_body(110.0, 40.0), 64.0)
	var ell: Rect2 = KillDissolveMask.ell_of(root, 0.0)
	assert_almost_eq(ell.position.y, -40.0, 0.01, "centred on the drawn figure, not the hips")
	assert_gte(ell.size.y, 55.0, "holds the head and the feet")
	assert_gte(ell.size.x, 22.0, "holds the shoulders")
	assert_lt(ell.size.x, ell.size.y, "an upright figure: taller than wide")
	root.free()


func test_a_body_with_no_sprites_keeps_the_old_disc() -> void:
	var bare: Node2D = Node2D.new()
	bare.name = "body"
	var root: Node2D = KillDissolveMask.wrap(bare, 32.0)
	var ell: Rect2 = KillDissolveMask.ell_of(root, 0.0)
	assert_eq(ell.position, Vector2.ZERO)
	assert_almost_eq(ell.size.x, KillDissolveFx.BODY_R_M * 32.0, 0.01)
	root.free()


func test_a_root_with_no_fit_is_the_disc() -> void:
	var root: Node2D = Node2D.new()
	assert_eq(KillDissolveMask.ell_of(root, 9.0), Rect2(Vector2.ZERO, Vector2.ONE * 9.0))
	root.free()
