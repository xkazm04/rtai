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
