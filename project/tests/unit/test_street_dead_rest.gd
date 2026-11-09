extends GutTest
## n10: a corpse whose rig goes back to the pool keeps lying where it was drawn, until its row
## leaves the feed, gets up, or a rig draws it again.

var _rest: StreetDeadRest = null


func before_each() -> void:
	_rest = StreetDeadRest.new()
	add_child_autofree(_rest)


func _feed(rows: Dictionary[int, bool]) -> RigFeed:
	var feed: RigFeed = RigFeed.new(16)
	for actor: int in rows:
		var row: int = feed.count
		@warning_ignore("return_value_discarded")
		feed.put(row, actor, BodyPlan.Kind.PED, Vector2.ZERO, Vector2.ZERO)
		feed.flags[row] = RigFeed.Flag.DEAD if rows[actor] else 0
	return feed


func _lying_card() -> Sprite2D:
	var card: Sprite2D = Sprite2D.new()
	add_child_autofree(card)
	for part: String in StreetDeadRest.PARTS:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.name = part
		card.add_child(sprite)
		sprite.global_position = Vector2(40.0, 20.0)
	card.self_modulate.a = 0.0
	card.set_meta(StreetDeadPlan.FREE, 3.0)
	return card


func test_keep_moves_the_lying_sprites_where_they_lie_and_restores_the_card() -> void:
	var card: Sprite2D = _lying_card()
	var plan: Node2D = card.get_node(StreetDeadPlan.NODE)
	_rest.keep(7, card)
	assert_eq(plan.get_parent(), _rest, "the pose is this layer's now")
	assert_eq(plan.global_position, Vector2(40.0, 20.0), "where it lay")
	assert_eq(card.get_child_count(), 0, "the pooled card carries nothing away")
	assert_eq(card.self_modulate.a, 1.0, "the next person's card is opaque")
	assert_false(card.has_meta(StreetDeadPlan.FREE), "the next body measures its own wall")
	assert_eq(_rest.ids(), PackedInt32Array([7]))


func test_the_shadow_stays_under_the_pose() -> void:
	var card: Sprite2D = _lying_card()
	_rest.keep(7, card)
	var shadow: int = _rest.get_node(StreetDeadHeading.SHADOW_NODE).get_index()
	var plan: int = _rest.get_node(StreetDeadPlan.NODE).get_index()
	assert_lt(shadow, plan)


func test_past_the_cap_the_oldest_goes_back_to_the_atlas() -> void:
	for actor: int in StreetDeadRest.CAP + 1:
		_rest.keep(actor, _lying_card())
	assert_eq(_rest.ids().size(), StreetDeadRest.CAP)
	assert_false(_rest.ids().has(0), "the oldest went")
	assert_true(_rest.ids().has(StreetDeadRest.CAP), "the newest stayed")


func test_a_body_lets_go_when_its_row_leaves_or_gets_up() -> void:
	for actor: int in [1, 2, 3]:
		_rest.keep(actor, _lying_card())
	_rest.sync(_feed({1: true, 2: false}))  # 2 got up, 3 left the feed
	assert_eq(_rest.ids(), PackedInt32Array([1]))


func test_a_kept_body_is_not_chosen_for_a_rig_again() -> void:
	_rest.keep(2, _lying_card())
	var feed: RigFeed = _feed({1: true, 2: true, 3: false})
	assert_eq(_rest.free_of(PackedInt32Array([0, 1, 2]), feed), PackedInt32Array([0, 2]))


func test_a_rig_with_no_pose_lying_is_left_to_the_atlas() -> void:
	var rig: CutRig = autofree(CutRig.new())
	rig.head_card = Sprite2D.new()
	autofree(rig.head_card)
	rig.actor_id = 5
	_rest.adopt(rig, _feed({5: true}))
	assert_eq(_rest.ids().size(), 0, "still falling, no plan pose: nothing to keep")
