extends GutTest

const RIGHT: Vector2i = Vector2i(2, 0)
const TEXEL: Vector2 = Vector2(0.25, 0.3)


func test_registered_soles_hold_through_drawings_and_wrap_in_both_pitches() -> void:
	for art: String in ["p70", "p55"]:
		for strip: String in [StreetCopWalk.EIGHT, StreetCopWalk.RUN, StreetMulroneyAnchors.EIGHT]:
			for col: int in 5:
				for flip: int in 2:
					_check_contacts(art.path_join(strip), Vector2i(col, flip))


func _check_contacts(path: String, face: Vector2i) -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(path)
	contact.registered.glide_no_step = false  # n31-13: the foot lock; non-side walks glide
	var direction: Vector2 = Vector2(-1 if face.y else 1, 1).normalized()
	contact.travel = direction  # as StreetCopWalk.plant seeds it from the rig's velocity
	var anchor: Vector2
	var previous: Vector2
	var step: float = contact.step_m * 32.0
	for sample: int in 65:
		var dist: float = (sample * 0.25 + 0.001) * step if sample else 0.0
		var xf: Transform2D = contact.place(direction * dist, face, TEXEL, 32)
		var row: int = posmod(contact.cell, contact.drawings)
		assert_eq(row, floori(sample * 0.25) % 8)
		var ink: Vector4 = contact.registered.marks[face.x * 8 + row]
		var local: Vector2 = Vector2(-ink.x if face.y else ink.x, ink.y)
		var sole: Vector2 = xf * local
		if sample % 16 == 0:
			anchor = sole
			if sample > 0:
				assert_gt(sole.distance_to(previous), 1.0)
			previous = anchor
		if path.ends_with(StreetCopWalk.RUN) and row % 4 == 3:
			continue
		# n31-10 HOLD_TOE_OFF: a side-view walk toe-off heel is drawn at its lift above the foot line.
		var first: Vector4 = contact.registered.marks[face.x * 8 + row - row % 4]
		var lift: float = _lift(contact.registered, ink.y) - _lift(contact.registered, first.y)
		assert_almost_eq(sole.x, anchor.x, 0.001)
		assert_almost_eq(sole.y, anchor.y + lift * TEXEL.y, 0.001)


func _lift(pose: StreetPatrolPose, sole_y: float) -> float:
	return sole_y - pose.foot_y(sole_y)


func test_four_drawing_fallback_and_contact_reset() -> void:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(StreetCopWalk.FOUR)
	assert_eq(contact.drawings, 4)
	assert_eq(contact.step_m, 0.135)
	var step: float = contact.step_m * 32
	assert_eq(contact.place(Vector2.ZERO, RIGHT, TEXEL, 32).origin, Vector2.ZERO)
	var next: Transform2D = contact.place(Vector2.RIGHT * (step + 0.1), RIGHT, TEXEL, 32)
	assert_eq(next.origin, StreetCopWalk.ADVANCE[2] * TEXEL)
	next = contact.place(Vector2.RIGHT * (2 * step + 0.1), RIGHT, TEXEL, 32)
	assert_almost_eq(next.origin.x, 2 * step, 0.001)
	for at: Vector2 in [Vector2(140, 30), Vector2(6, 8)]:
		assert_eq(contact.place(at, RIGHT, TEXEL, 32).origin, at)
		assert_eq(contact.cell, 0)
	var turn: Vector2 = Vector2(7, 8)
	assert_eq(contact.place(turn, Vector2i(1, 1), TEXEL, 32).origin, turn)
	contact.reset()
	assert_eq(contact.place(turn + Vector2.ONE, RIGHT, TEXEL, 32).origin, turn + Vector2.ONE)


func test_gait_boundary_and_eight_drawing_reset() -> void:
	assert_eq(StreetCopWalk.strip_for(4.0), StreetCopWalk.PLANTED)
	var fast: String = (
		StreetCopWalk.RUN if StreetCopWalk.PLANTED == StreetCopWalk.EIGHT else StreetCopWalk.FOUR
	)
	assert_eq(StreetCopWalk.strip_for(4.001), fast)
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(StreetCopWalk.EIGHT)
	assert_eq(contact.drawings, 8)
	assert_eq(contact.step_m, StreetPatrolAnchors.WALK_M)
	contact.configure(StreetCopWalk.RUN)
	assert_eq(contact.step_m, StreetPatrolAnchors.RUN_M)
	assert_eq(contact.place(Vector2.ONE, RIGHT, TEXEL, 32).origin, Vector2.ONE)


func test_idle_reused_rig_and_shared_uniform() -> void:
	var rig: CutRig = autofree(CutRig.new())
	var card: Sprite2D = autofree(Sprite2D.new())
	StreetCopWalk.bind(card, StreetCopWalk.PLANTED)
	var held: StreetCopWalk.RigContact = card.get_meta(StreetCopWalk.CONTACT)
	assert_true(RenderingServer.frame_pre_draw.is_connected(held.pin))
	rig.speed_now = 64.0
	StreetCopWalk.plant(rig, card)
	rig.position = Vector2.RIGHT
	StreetCopWalk.plant(rig, card)
	assert_eq(card.frame_coords.y, 0)
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
	assert_false(RenderingServer.frame_pre_draw.is_connected(held.pin))
	assert_false(card.tree_exiting.is_connected(held.release))


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
	assert_eq(patrol.frame_coords.y, 0)
	assert_eq(other.position, feed.pos[0])
	feed.pos[0] += Vector2.RIGHT * StreetCopWalk.STEP_M * SimConst.PX_PER_M
	patrol.pose(feed, 0)
	assert_eq(patrol.frame_coords.y, 1)
	feed.vel[0] = Vector2.RIGHT * 6.65 * SimConst.PX_PER_M
	patrol.pose(feed, 0)
	var fast: String = StreetCopWalk.strip_for(6.65)
	assert_eq(patrol.texture.resource_path.get_file(), fast)
	assert_eq(patrol.vframes, StreetCopWalk.rows_of(fast))
	assert_eq(patrol.frame_coords.y, 1 if fast == StreetCopWalk.PLANTED else 0)
	ViewMode._shared = previous


## n31-09: at mid-stance the planted sole of every anchored walk sits on the sim ground point
## (where the contact disc draws), give or take the drawing's own sole registration, in every
## direction (the old placement trailed it by half a stance, 11 px at 32 px/m). n31-10: walking up
## the settle stance shift compounded 3.4 px a stance to 14 px; now it holds over 10 stances.
func test_mid_stance_sole_sits_on_the_ground_point_down_and_sideways() -> void:
	var path: String = "p70".path_join(StreetCopWalk.EIGHT)
	for direction: Vector2 in [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
		var misses: Array[Vector2] = _mid_stance_misses(path, direction, 10)
		assert_eq(misses.size(), 9, "stances 2..10 %s" % direction)
		for miss: Vector2 in misses:
			assert_almost_eq(miss.x, 0.0, 3.0, "x %s %s" % [direction, misses])
			assert_almost_eq(miss.y, 0.0, 3.0, "y %s %s" % [direction, misses])
		assert_lte(misses[-1].distance_to(misses[0]), 1.0, "grows %s %s" % [direction, misses])


## Planted sole minus ground point minus the drawing's own first-sole offset, at mid-stance of
## stances 2..n, walking 3.2 m/s at 32 px/m.
func _mid_stance_misses(path: String, direction: Vector2, stances: int) -> Array[Vector2]:
	var contact: StreetCopWalk.Contact = StreetCopWalk.Contact.new()
	contact.configure(path)
	contact.travel = direction
	var face: Vector2i = RigHeadCard.frame_of(direction.angle())
	var stance: float = contact.step_m * 32.0 * (contact.drawings >> 1)
	var speed: float = 3.2 * 32.0 * SimClock.TICK_DT
	var misses: Array[Vector2] = []
	var at: Vector2 = Vector2.ZERO
	while at.length() < stance * stances:
		var xf: Transform2D = contact.place(at, face, TEXEL, 32)
		var into: float = fmod(at.length(), stance)
		if absf(into - stance * 0.5) <= speed * 0.5 and at.length() > stance:
			var row: int = posmod(contact.cell, contact.drawings)
			var ink: Vector4 = contact.registered.marks[face.x * 8 + row]
			var first: Vector4 = contact.registered.marks[face.x * 8 + row - row % 4]
			var flip: float = -1.0 if face.y else 1.0
			var own: Vector2 = Vector2(first.x * flip, first.y) * TEXEL
			var sole: Vector2 = Vector2(ink.x * flip, ink.y)
			if contact.registered.glides(face.x):  # n31-13: registered on the foot line
				own.y = 0.0
				sole.y = 0.0
			misses.append(xf * sole - at - own)
		at += direction * speed
	return misses
