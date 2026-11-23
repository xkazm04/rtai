extends GutTest


func _host(art: String) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	rig.head = Node2D.new()
	rig.add_child(rig.head)
	rig.head_card = Sprite2D.new()
	rig.head.add_child(rig.head_card)
	rig.head_card.centered = false
	rig.head_card.hframes = 5
	var pose: CastCardPose = CastCardPose.new()
	pose.actor_id = rig.actor_id
	pose.sheets = CastCards.Sheets.new()
	pose.sheets.hit = StreetWalkerCards.DIR.path_join(art).path_join(StreetMulroneyHit.HIT)
	pose.sheets.body_scale = 1.11
	rig.head_card.texture = load(pose.sheets.hit)
	rig.head_card.set_meta(StreetWalkerCards.ON, pose.sheets.hit)
	assert_true(pose.bind(rig))
	rig.position = Vector2(97, 51)
	rig.react = HumanReact.new()
	rig.react.kind = &"flinch"
	rig.react.off = Vector2(5, 3)
	rig.react.travel = 8.0
	return rig


func test_reacting_socket_rotates_around_visible_sole_for_all_octants() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode.select("combo")
	for art: String in ["p70", "p55"]:
		ViewMode.shared().art = art
		var rig: CutRig = _host(art)
		var c: Sprite2D = rig.head_card
		for octant: int in 8:
			rig.react.dir = Vector2.RIGHT.rotated(octant * PI / 4.0)
			rig.head.transform = Transform2D(0.6, Vector2(1.1, 0.84), 0.13, Vector2(12, -20))
			StreetView.post(rig)
			var face: Vector2i = RigHeadCard.frame_of((-rig.react.dir).angle())
			assert_eq(c.frame_coords, Vector2i(face.x, 0))
			assert_eq(c.flip_h, face.y != 0)
			var sole: Vector2 = _boot(c, face)
			assert_almost_eq(
				c.global_transform * (c.offset + sole), rig.position, Vector2.ONE * 0.001
			)
			assert_gt(absf(c.global_rotation), 0.01)
			assert_eq(RigCastShadows.card_push(rig), Vector2.ZERO)
	ViewMode._shared = saved


## Read the actual bottom band of the flat shoe from alpha, independently of the game table.
func _boot(card: Sprite2D, face: Vector2i) -> Vector2:
	var im: Image = card.texture.get_image()
	var width: int = floori(float(im.get_width()) / 5)
	var mask: Image = im.get_region(Rect2i(face.x * width, 0, width, im.get_height()))
	var box: Rect2i = mask.get_used_rect()
	var stop: int = width
	if face.x == 4 and card.texture.resource_path.contains("/p70/"):
		stop = 109  # The right boot's facing sole is lifted towards the camera.
	var bottom: int = -1
	var top: int = mask.get_height()
	for y: int in range(box.position.y, box.end.y):
		for x: int in range(stop):
			if mask.get_pixel(x, y).a8 > 128:
				bottom = y
				top = mini(top, y)
				break
	var left: int = width
	var right: int = 0
	for y: int in range(bottom - roundi((bottom - top) * 0.05), bottom + 1):
		for x: int in range(stop):
			if mask.get_pixel(x, y).a8 > 128:
				left = mini(left, x)
				right = maxi(right, x)
	var x_mid: float = (left + right + 1) * 0.5
	return Vector2(width - x_mid if face.y else x_mid, bottom + 0.5)


func test_anchor_only_applies_to_the_living_sergeant() -> void:
	var rig: CutRig = _host("p70")
	assert_true(StreetMulroneyHit.living(rig))
	rig.react.dying = true
	assert_false(StreetMulroneyHit.living(rig))
	rig.react.dying = false
	rig.dead = true
	assert_false(StreetMulroneyHit.living(rig))
	rig.dead = false
	var pose: CastCardPose = CastCardPose.of(rig)
	pose.sheets.hit = "other_hit.png"
	assert_false(StreetMulroneyHit.living(rig))
	assert_ne(RigCastShadows.card_push(rig), Vector2.ZERO)
	rig.react = null
	assert_false(StreetMulroneyHit.living(rig))
