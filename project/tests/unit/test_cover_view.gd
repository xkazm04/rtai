extends GutTest

var stage: ArenaStage
var cover: PlayerCover


func before_each() -> void:
	stage = VaultTrial.stage_for(false)
	cover = stage.pilot.motion.cover
	cover.enabled = true
	stage.arena.rivet.pos = Vector2(4, 11.65)


func _step(move: Vector2, action: StringName = &"", aim: Vector2 = Vector2.ZERO) -> void:
	var a: PlayerActions = stage.pilot.actions
	var bits: int = PlayerCommand.pack_aim(aim, a)
	if action != &"":
		bits |= 1 << a.bit(action)
	var axes: Vector2 = move * TickInput.AXIS_MAX
	stage.step(stage.tick + 1, TickInput.new(bits, roundi(axes.x), roundi(axes.y)))


func _scale(flat: bool = false) -> Vector2:
	return CoverView.scale_for(cover.crouch_scale_y, cover.crouch_weight(), flat)


func test_low_cover_tucks_at_the_feet_and_blends_on_snap_and_leave() -> void:
	assert_eq(_scale(), Vector2.ONE)
	var prev: float = 1.0
	for i: int in cover.snap_ticks:
		_step(Vector2.ZERO, &"cover" if i == 0 else &"")
		assert_lt(_scale().y, prev)
		prev = _scale().y
	assert_almost_eq(_scale(), Vector2(1.0, cover.crouch_scale_y), Vector2.ONE * 0.00001)
	assert_eq(_scale(true), Vector2.ONE * cover.crouch_scale_y)
	for i: int in cover.leave_ticks:
		_step(Vector2.UP)
		assert_gt(_scale().y, prev)
		prev = _scale().y
	assert_eq(_scale(), Vector2.ONE)


func test_peek_stands_upright_and_high_cover_keeps_the_standing_cell() -> void:
	_step(Vector2.ZERO, &"cover")
	for i: int in cover.snap_ticks:
		_step(Vector2.ZERO)
	for i: int in 32:
		_step(Vector2.RIGHT)
	for i: int in cover.peek_ticks:
		_step(Vector2.ZERO, &"", Vector2.RIGHT)
	assert_eq(cover.phase, PlayerCover.Phase.PEEK)
	assert_eq(_scale(), Vector2.ONE)
	_step(Vector2.ZERO, &"cover")
	stage.arena.rivet.pos = Vector2(10, 9.9)
	_step(Vector2.ZERO)
	_step(Vector2.ZERO, &"cover")
	for i: int in cover.snap_ticks:
		_step(Vector2.ZERO)
	assert_eq(cover.phase, PlayerCover.Phase.IN)
	assert_false(cover.spot.low)
	assert_eq(_scale(), Vector2.ONE)


func test_cover_takes_over_the_generic_wedge_even_when_silhouette_is_disabled() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var hit: PropOcclusion.Hit = PropOcclusion.Hit.new()
	hit.rig = rig
	var canvas: Node2D = autofree(Node2D.new())
	_step(Vector2.ZERO, &"cover")
	cover.silhouette_enabled = false
	CoverView.sync_ink(rig, cover, Vector2.ONE)
	assert_true(CoverUpperCard.draw_hidden(canvas, hit), "skip the generic ink and cream rim")
	cover.interrupt()
	CoverView.sync_ink(rig, cover, Vector2.ONE)
	assert_false(CoverUpperCard.draw_hidden(canvas, hit), "ordinary depth markers resume")


func test_hidden_contour_uses_only_the_selected_cells_alpha_and_flip() -> void:
	var card: Sprite2D = autofree(Sprite2D.new())
	var img: Image = Image.create_empty(20, 10, false, Image.FORMAT_RGBA8)
	img.fill_rect(Rect2i(0, 0, 10, 10), Color.WHITE)
	img.fill_rect(Rect2i(11, 2, 3, 6), Color.ORANGE)
	img.fill_rect(Rect2i(12, 3, 1, 2), Color.BLACK)
	card.texture = ImageTexture.create_from_image(img)
	card.centered = false
	card.hframes = 2
	card.frame = 1
	for mirrored: bool in [false, true]:
		card.flip_h = mirrored
		var shapes: Array[PackedVector2Array] = CoverUpperCard.outlines(card)
		assert_eq(shapes.size(), 1, "interior colours leave a single solid contour")
		if shapes.size() != 1:
			return
		var x: float = 7.5 if mirrored else 2.5
		assert_true(Geometry2D.is_point_in_polygon(Vector2(x, 4.5), shapes[0]))
		assert_false(Geometry2D.is_point_in_polygon(Vector2(10.0 - x, 4.5), shapes[0]))
