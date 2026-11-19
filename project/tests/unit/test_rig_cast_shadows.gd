extends GutTest


func test_shipped_top_casts_no_shadow() -> void:
	assert_eq(ViewMode.of("top").cast_k, 0.0)


func test_top_lift_casts_down_right() -> void:
	var v: ViewMode = ViewMode.of("top_lift")
	assert_gt(v.cast_k, 0.0)
	assert_gt(v.cast_dir().x, 0.0)
	assert_gt(v.cast_dir().y, 0.0)
	assert_almost_eq(v.cast_dir().length(), 1.0, 0.0001)


func test_figure_runs_along_the_sun_as_long_as_the_body() -> void:
	var dir: Vector2 = Vector2.RIGHT
	var fig: PackedVector2Array = RigCastShadows.figure(Vector2.ZERO, dir, 10.0)
	var far: float = 0.0
	for p: Vector2 in fig:
		far = maxf(far, p.x)
	assert_almost_eq(far, 10.0 * RigCastShadows.BODY_IN_HIPS, 0.001)
	assert_eq(fig.size(), 8)


func test_a_downed_body_casts_a_shorter_figure() -> void:
	var tall: PackedVector2Array = RigCastShadows.figure(Vector2.ZERO, Vector2.DOWN, 20.0)
	var low: PackedVector2Array = RigCastShadows.figure(Vector2.ZERO, Vector2.DOWN, 5.0)
	assert_gt(tall[4].y, low[4].y)


func test_sweep_of_a_box_is_its_footprint_and_top() -> void:
	var sq: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)]
	)
	var hull: PackedVector2Array = RigCastShadows.sweep_hull(sq, Vector2(5, 5))
	assert_eq(hull.size(), 6)  # a diagonal sweep drops the two hidden corners
	assert_true(hull.has(Vector2(15, 15)))
	assert_true(hull.has(Vector2(0, 0)))


## n11 (owner note "no long cast shadows"): the play views draw a contact shadow under the feet.
func test_the_play_views_cast_short_and_contact() -> void:
	for id: String in ["combo", "tilt70"]:
		assert_lt(ViewMode.of(id).cast_k, RigCastShadows.CONTACT_BELOW_K, id)


func test_a_contact_shadow_lies_flat_round_the_feet() -> void:
	var at: Vector2 = Vector2(10.0, 20.0)
	var e: PackedVector2Array = RigCastShadows.contact_ellipse(at, 10.0)
	assert_eq(e.size(), RigCastShadows.CONTACT_POINTS)
	var box: Rect2 = Rect2(e[0], Vector2.ZERO)
	for p: Vector2 in e:
		box = box.expand(p)
	assert_almost_eq(box.get_center().x, at.x, 0.01, "centred")
	assert_lt(box.size.y, box.size.x, "flattened on the ground")


func _wounded_card_cop(grid: String) -> CutRig:
	var rig: CutRig = autofree(CutRig.new())
	rig.plan = HumanPlan.cop()
	add_child_autofree(rig)
	var r: HumanReact = HumanReact.on(rig)
	r.kind = &"flinch"
	r.t = 0.05
	r.travel = 80.0
	r.off = Vector2(80.0, 0.0)
	rig.scale = Vector2(0.1, 0.1)
	var card: Sprite2D = Sprite2D.new()
	card.set_meta(StreetWalkerCards.ON, grid)
	rig.add_child(card)
	rig.head_card = card
	return rig


func test_a_pushed_hit_card_takes_its_shadow_along() -> void:
	var rig: CutRig = _wounded_card_cop("res://x/cop_patrol_hit.png")
	var shove: Vector3 = StreetWalkerHit.shove(rig)
	assert_ne(shove, Vector3.ZERO, "the wound pushes the card")
	assert_eq(RigCastShadows.card_push(rig), Vector2(shove.x, shove.y), "the shadow rides the push")


func test_only_a_hit_card_moves_the_shadow() -> void:
	var walk: CutRig = _wounded_card_cop("res://x/cop_patrol_armed_walk.png")
	assert_eq(RigCastShadows.card_push(walk), Vector2.ZERO, "a walk card is never pushed")
	var bare: CutRig = autofree(CutRig.new())
	assert_eq(RigCastShadows.card_push(bare), Vector2.ZERO, "no card: the feet")
	var hidden: CutRig = _wounded_card_cop("res://x/cop_patrol_hit.png")
	hidden.head_card.visible = false
	assert_eq(RigCastShadows.card_push(hidden), Vector2.ZERO, "a hidden card: the feet")


func test_a_dying_card_keeps_its_shadow_until_it_lies() -> void:
	# n17 (DEFECTS 23): the standard death's hit cell and fall rows stood on bare street.
	var hit: CutRig = _wounded_card_cop("res://x/cop_patrol_hit.png")
	hit.dead = true
	assert_true(RigCastShadows.stands_dying(hit), "the thrown-back hit cell stands")
	var fall: CutRig = _wounded_card_cop("res://x/cop_patrol_between_fall.png")
	fall.dead = true
	fall.head_card.texture = PlaceholderTexture2D.new()
	(fall.head_card.texture as PlaceholderTexture2D).size = Vector2(50.0, 50.0)
	fall.head_card.vframes = StreetFallBetween.FRAMES
	fall.head_card.frame_coords = Vector2i(0, 1)
	assert_true(RigCastShadows.stands_dying(fall), "the mid-fall row stands")
	fall.head_card.frame_coords = Vector2i(0, StreetFallBetween.FRAMES - 1)
	assert_false(RigCastShadows.stands_dying(fall), "the lying row: the body's own")
	var walk: CutRig = _wounded_card_cop("res://x/cop_patrol_armed_walk.png")
	assert_false(RigCastShadows.stands_dying(walk), "not a dying card")


class CityShadowProbe:
	extends RigCastShadows

	var rings: Array[PackedVector2Array] = []

	func _draw() -> void:
		rings.clear()
		_contact(Vector2(16961.630859375, 16930.5390625), 21.0392377138649)

	func _fill(points: PackedVector2Array, _ink: Color) -> void:
		rings.append(points)


func test_city_contact_draws_three_complete_rings_at_tick_634() -> void:
	var probe: CityShadowProbe = add_child_autofree(CityShadowProbe.new())
	await wait_process_frames(2)
	assert_eq(probe.rings.size(), 3)
	for ring: PackedVector2Array in probe.rings:
		assert_eq(Geometry2D.triangulate_polygon(ring).size(), 54, "18 triangles per ring")
