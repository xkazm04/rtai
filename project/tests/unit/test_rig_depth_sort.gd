extends GutTest
## View lab: RigDepthSort.levels gives a nearer overlapping body a higher level than the one
## behind it, and leaves bodies that overlap nothing at level 0.

const BOX: Vector2 = Vector2(30.0, 60.0)


func _rig(at: Vector2) -> CutRig:
	var rig: CutRig = CutRig.new()
	rig.position = at
	add_child_autofree(rig)
	return rig


func test_lone_bodies_stay_at_level_zero() -> void:
	var a: CutRig = _rig(Vector2(0.0, 0.0))
	var b: CutRig = _rig(Vector2(200.0, 10.0))
	var lv: Dictionary[CutRig, int] = RigDepthSort.levels([a, b] as Array[CutRig], BOX)
	assert_eq(lv[a], 0)
	assert_eq(lv[b], 0)


func test_nearer_overlapping_body_draws_over() -> void:
	var near: CutRig = _rig(Vector2(5.0, 40.0))  # larger ground y: nearer the camera
	var far: CutRig = _rig(Vector2(0.0, 0.0))
	var lv: Dictionary[CutRig, int] = RigDepthSort.levels([near, far] as Array[CutRig], BOX)
	assert_eq(lv[far], 0)
	assert_eq(lv[near], 1)


func test_a_chain_climbs_one_level_per_body() -> void:
	var a: CutRig = _rig(Vector2(0.0, 0.0))
	var b: CutRig = _rig(Vector2(0.0, 30.0))
	var c: CutRig = _rig(Vector2(0.0, 55.0))
	var lv: Dictionary[CutRig, int] = RigDepthSort.levels([c, a, b] as Array[CutRig], BOX)
	assert_eq([lv[a], lv[b], lv[c]], [0, 1, 2])


func test_a_wide_ghost_card_overlaps_a_body_its_own_half_width_away() -> void:
	var card: Node2D = Node2D.new()
	var cop: Node2D = Node2D.new()
	add_child_autofree(card)
	add_child_autofree(cop)
	card.global_position = Vector2(0.0, 0.0)
	cop.global_position = Vector2(60.0, 10.0)  # south of the card, 60 px across
	var bodies: Array[Node2D] = [card, cop]
	var narrow: Array[int] = RigDepthSort.levels_w(bodies, [14.0, 14.0] as Array[float], 50.0)
	assert_eq(narrow, [0, 0] as Array[int], "two narrow bodies 60 px apart do not overlap")
	var wide: Array[int] = RigDepthSort.levels_w(bodies, [50.0, 14.0] as Array[float], 50.0)
	assert_eq(wide, [0, 1] as Array[int], "the wide card overlaps: the nearer cop climbs over it")


func test_the_layer_names_its_sorter_and_forgets_a_freed_one() -> void:
	var layer: Node2D = autofree(Node2D.new())
	assert_null(RigDepthSort.on(layer), "no sorter: the caller walks the layer itself")
	var s: RigDepthSort = RigDepthSort.new()
	layer.set_meta(&"rig_depth_sort", weakref(s))
	assert_eq(RigDepthSort.on(layer), s)
	s.free()
	assert_null(RigDepthSort.on(layer), "a freed sorter is never handed out")


func test_a_tall_near_body_overlaps_a_body_its_own_height_away() -> void:
	var near: Node2D = Node2D.new()
	var far: Node2D = Node2D.new()
	add_child_autofree(near)
	add_child_autofree(far)
	far.global_position = Vector2(0.0, 0.0)
	near.global_position = Vector2(4.0, 56.0)  # Rivet 1.75 m south of a cop (n15 city film t650)
	var bodies: Array[Node2D] = [near, far]
	var half: Array[float] = [14.0, 14.0]
	assert_eq(
		RigDepthSort.levels_w(bodies, half, 33.0), [0, 0] as Array[int], "one box: no overlap"
	)
	var tall: Array[float] = [62.0, 33.0]
	assert_eq(
		RigDepthSort.levels_w(bodies, half, 33.0, tall),
		[1, 0] as Array[int],
		"the near body's drawn head reaches over the far one's feet: it climbs over"
	)
	tall = [33.0, 62.0]
	assert_eq(
		RigDepthSort.levels_w(bodies, half, 33.0, tall),
		[0, 0] as Array[int],
		"a tall FAR body does not reach the near one"
	)


func test_card_tall_is_the_drawn_card_above_the_foot() -> void:
	var rig: CutRig = _rig(Vector2(100.0, 200.0))
	assert_eq(RigDepthBox.card_tall(rig), 0.0, "no card: 0")
	var card: Sprite2D = Sprite2D.new()
	var img: Image = Image.create(10, 40, false, Image.FORMAT_RGBA8)
	card.texture = ImageTexture.create_from_image(img)
	card.centered = false
	card.position = Vector2(-5.0, -40.0)  # bottom edge on the foot
	rig.add_child(card)
	rig.head_card = card
	assert_almost_eq(RigDepthBox.card_tall(rig), 40.0 * rig.scale.y, 0.01)
	card.visible = false
	assert_eq(RigDepthBox.card_tall(rig), 0.0, "a hidden card: 0")


func test_rivets_box_is_wider_and_a_card_below_the_foot_is_no_height() -> void:
	var rig: CutRig = _rig(Vector2(0.0, 100.0))
	assert_almost_eq(RigDepthBox.half(rig, 30.0), 15.0, 0.001, "no card: half the body box")
	var card: Sprite2D = Sprite2D.new()
	card.texture = ImageTexture.create_from_image(Image.create(10, 40, false, Image.FORMAT_RGBA8))
	card.centered = false
	card.position = Vector2(-5.0, 10.0)  # drawn wholly below the foot
	rig.add_child(card)
	rig.head_card = card
	assert_almost_eq(RigDepthBox.half(rig, 30.0), 15.0, 0.001, "a street card: the body box")
	assert_eq(RigDepthBox.card_tall(rig), 0.0, "nothing drawn above the foot")
	assert_eq(RigDepthBox.tall(rig, 33.0), 33.0, "never shorter than the body box")
	card.set_meta(RivetFrames.ON, true)
	assert_almost_eq(RigDepthBox.half(rig, 30.0), 15.0 * RigDepthBox.RIVET_W_K, 0.001, "Rivet x1.5")
