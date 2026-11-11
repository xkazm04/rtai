extends GutTest
## n16 kills-polish: KillFigure finds where a kill body's man is drawn, so the burn's embers and
## smoke and the ray gun's mask sit on the figure, not on the group origin (the walker card's feet).


func _body() -> Node2D:
	var body: Node2D = Node2D.new()
	var tex: PlaceholderTexture2D = PlaceholderTexture2D.new()
	tex.size = Vector2(40.0, 100.0)
	var card: Sprite2D = Sprite2D.new()
	card.texture = tex
	card.position = Vector2(0.0, -50.0)  # an upright card standing on the origin
	body.add_child(card)
	return autofree(body)


func test_the_box_is_the_drawn_card() -> void:
	var b: Rect2 = KillFigure.box(_body(), 8.0)
	assert_eq(b, Rect2(-20.0, -100.0, 40.0, 100.0))


func test_a_body_with_no_sprites_is_a_small_square_on_the_origin() -> void:
	var body: Node2D = autofree(Node2D.new())
	assert_eq(KillFigure.box(body, 8.0), Rect2(-8.0, -8.0, 16.0, 16.0))


func test_points_on_the_figure_follow_the_body_placement() -> void:
	var body: Node2D = _body()
	body.position = Vector2(300.0, 200.0)
	assert_eq(KillFigure.at(body, Vector2.ZERO), Vector2(300.0, 150.0), "the middle, not the feet")
	assert_eq(KillFigure.at(body, Vector2(0.0, -1.0)), Vector2(300.0, 100.0), "the head")
	body.scale = Vector2(0.5, 0.5)
	assert_eq(
		KillFigure.at(body, Vector2(1.0, 1.0)), Vector2(310.0, 200.0), "it sinks with the body"
	)


func test_the_box_is_kept_from_the_first_ask() -> void:
	var body: Node2D = _body()
	var first: Rect2 = KillFigure.cached(body, 8.0)
	(body.get_child(0) as Sprite2D).position = Vector2(500.0, 0.0)
	assert_eq(KillFigure.cached(body, 8.0), first)
