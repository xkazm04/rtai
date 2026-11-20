extends GutTest
## n15 hero: a drawn ghost's soul-teal outline copies follow the shown cell, under the figure.


func _spr() -> Sprite2D:
	var spr: Sprite2D = autofree(Sprite2D.new())
	spr.centered = false
	spr.texture = ImageTexture.create_from_image(Image.create(80, 100, false, Image.FORMAT_RGBA8))
	spr.hframes = 8
	spr.vframes = 5
	return spr


func after_each() -> void:
	GhostSoulLine.enabled = true


func test_attach_puts_eight_copies_round_and_under_the_figure() -> void:
	var spr: Sprite2D = _spr()
	GhostSoulLine.attach(spr)
	assert_eq(spr.get_child_count(), GhostSoulLine.COPIES)
	for n: Node in spr.get_children():
		var c: Sprite2D = n as Sprite2D
		assert_true(c.show_behind_parent, "under the figure")
		assert_almost_eq(c.position.length(), GhostSoulLine.WIDTH_PX, 0.001)


func test_the_copies_follow_the_cell_mirror_and_offset() -> void:
	var spr: Sprite2D = _spr()
	GhostSoulLine.attach(spr)
	spr.frame = 13
	spr.flip_h = true
	spr.offset = Vector2(-5.0, -18.0)
	GhostSoulLine.sync(spr)
	for n: Node in spr.get_children():
		var c: Sprite2D = n as Sprite2D
		assert_eq(c.texture, spr.texture)
		assert_eq(c.frame, 13)
		assert_true(c.flip_h)
		assert_eq(c.offset, spr.offset)


func test_switched_off_there_is_no_line() -> void:
	GhostSoulLine.enabled = false
	var spr: Sprite2D = _spr()
	GhostSoulLine.attach(spr)
	assert_eq(spr.get_child_count(), 0)


func test_all_eight_outline_copies_use_the_bodys_cut_at_the_same_canvas_point() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode.select("tilt70")
	var host: Node2D = add_child_autofree(Node2D.new())
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	var spr: Sprite2D = _spr()
	host.add_child(spr)
	GhostSoulLine.attach(spr)
	var fade: GhostBridgeFade = GhostBridgeFade.new(GhostSoulLine.NAME)
	for mirror: bool in [false, true]:
		spr.flip_h = mirror
		flight.step(Vector2.ONE, PI if mirror else 0.0, 1)
		GhostSoulLine.sync(spr)
		fade.sync(spr, flight)
		var cell: Vector2 = spr.texture.get_size() / Vector2(spr.hframes, spr.vframes)
		var body: ShaderMaterial = spr.material as ShaderMaterial
		var count: int = 0
		for child: Node in spr.get_children():
			if not child.has_meta(GhostSoulLine.NAME):
				continue
			var copy: Sprite2D = child as Sprite2D
			var line: ShaderMaterial = copy.material as ShaderMaterial
			assert_true(is_same(line.get_shader_parameter(&"outline"), true))
			for key: StringName in [&"flow", &"grid", &"fade_from"]:
				assert_true(is_same(line.get_shader_parameter(key), body.get_shader_parameter(key)))
			var shift: Vector2 = copy.get_instance_shader_parameter(&"cut_shift")
			var sign_x: float = -1.0 if spr.flip_h else 1.0
			assert_almost_eq(
				shift, copy.position * Vector2(sign_x, 1.0) / cell, Vector2.ONE * 0.00001
			)
			count += 1
		assert_eq(count, GhostSoulLine.COPIES)
	fade.clear(flight)
	ViewMode._shared = saved
