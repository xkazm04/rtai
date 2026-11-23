extends GutTest

const RIGHT: Vector2i = Vector2i(2, 0)
const TEXEL: Vector2 = Vector2(0.25, 0.3)


func test_distance_starts_both_drawings_on_one_support() -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	var step: float = StreetCopWalk.STEP_M * 32.0
	assert_eq(contact.place(Vector2.ZERO, RIGHT, TEXEL, 32), Vector2.ZERO)
	assert_eq(contact.place(Vector2.RIGHT * (step - 0.1), RIGHT, TEXEL, 32), Vector2.ZERO)
	var pass_at: Vector2 = StreetCopWalk.ADVANCE[2] * TEXEL
	assert_eq(contact.place(Vector2.RIGHT * (step + 0.1), RIGHT, TEXEL, 32), pass_at)
	assert_eq(contact.cell, 1)
	assert_eq(contact.place(Vector2.RIGHT * (step * 2 - 0.1), RIGHT, TEXEL, 32), pass_at)
	var next: Vector2 = contact.place(Vector2.RIGHT * (step * 2 + 0.3), RIGHT, TEXEL, 32)
	assert_almost_eq(next.x, 2.0 * step, 0.001)
	assert_eq(contact.cell, 2)


func test_down_right_and_mirrored_support_advance() -> void:
	var step: float = StreetCopWalk.STEP_M * 32.0
	for mirror: int in 2:
		var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
		var face: Vector2i = Vector2i(1, mirror)
		var travel: Vector2 = Vector2(-1 if mirror else 1, 1).normalized()
		assert_eq(contact.place(Vector2.ZERO, face, TEXEL, 32), Vector2.ZERO)
		var placed: Vector2 = contact.place(travel * (step + 0.25), face, TEXEL, 32)
		assert_almost_eq(placed.x, -2.5 if mirror else 2.5, 0.001)
		assert_almost_eq(placed.y, 2.7, 0.001)


func test_turn_teleport_and_reset_start_at_actor() -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	assert_eq(contact.place(Vector2.ZERO, RIGHT, TEXEL, 32), Vector2.ZERO)
	assert_eq(contact.place(Vector2.ONE, RIGHT, TEXEL, 32), Vector2.ZERO)
	assert_eq(contact.place(Vector2.ONE, Vector2i(1, 0), TEXEL, 32), Vector2.ONE)
	var far: Vector2 = Vector2(140, 30)
	assert_eq(contact.place(far, Vector2i(1, 0), TEXEL, 32), far)
	contact.reset()
	assert_eq(contact.place(far + Vector2.ONE, RIGHT, TEXEL, 32), far + Vector2.ONE)
	assert_eq(contact.cell, 0)


func test_idle_reused_rig_and_shared_uniform() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var card: Sprite2D = autofree(Sprite2D.new())
	StreetCopWalk.bind(card, StreetCopWalk.PLANTED)
	rig.speed_now = 64.0
	StreetCopWalk.plant(rig, card)
	rig.position = Vector2.RIGHT
	StreetCopWalk.plant(rig, card)
	assert_eq(card.position, Vector2.ZERO)
	rig.actor_id += 1
	StreetCopWalk.plant(rig, card)
	assert_eq(card.position, rig.position)
	rig.speed_now = 0
	StreetCopWalk.plant(rig, card)
	rig.speed_now = 40
	rig.position += Vector2.RIGHT
	StreetCopWalk.plant(rig, card)
	assert_eq(card.position, rig.position)
	rig.set_meta(StreetCopWalk.OTHER_ID, rig.actor_id)
	var path: String = "res://art/" + StreetCopWalk.ORIGINAL
	assert_eq(StreetCopWalk.patrol_path(rig, path), path)
	StreetCopWalk.bind(card, path)
	assert_false(card.has_meta(StreetCopWalk.CONTACT))


func test_far_patrol_changes_drawing_by_ground_distance_and_other_role_keeps_its_sheet() -> void:
	var previous: ViewMode = ViewMode.shared()
	ViewMode.select("combo")
	var feed: RigFeed = RigFeed.new()
	@warning_ignore("return_value_discarded")
	feed.put(0, 23, BodyPlan.Kind.COP, Vector2.ZERO, Vector2.RIGHT * 64)
	feed.looks[0] = ArenaSquadLooks.PATROL_LOOK
	var patrol: ArenaWaveCards.Card = autofree(ArenaWaveCards.Card.new())
	var other: ArenaWaveCards.Card = autofree(ArenaWaveCards.Card.new())
	patrol.patrol = StreetCopWalk.Contact.new()
	patrol.pose(feed, 0)
	other.pose(feed, 0)
	assert_eq(patrol.texture.resource_path.get_file(), StreetCopWalk.PLANTED)
	assert_eq(other.texture.resource_path.get_file(), StreetCopWalk.ORIGINAL)
	feed.pos[0] = Vector2.RIGHT * 2
	patrol.pose(feed, 0)
	other.pose(feed, 0)
	assert_eq(patrol.position, Vector2.ZERO)
	assert_eq(other.position, feed.pos[0])
	feed.pos[0] += Vector2.RIGHT * StreetCopWalk.STEP_M * SimConst.PX_PER_M
	patrol.pose(feed, 0)
	assert_eq(patrol.frame_coords.y, 1)
	ViewMode._shared = previous
