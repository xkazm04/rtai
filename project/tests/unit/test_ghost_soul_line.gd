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
