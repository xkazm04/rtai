extends GutTest


class Lines:
	extends OhmView
	var points: Array[PackedVector2Array] = []
	var opacity: Array[float] = []
	var widths: Array[float] = []

	func stroke(pts: PackedVector2Array, alpha: float, k: float) -> void:
		points.append(pts)
		opacity.append(alpha)
		widths.append(k)


const LINE: PackedVector2Array = [Vector2(12, 9), Vector2(104, 59)]


func test_first_link_is_thin_and_both_forks_have_the_full_stroke() -> void:
	var ink: Lines = autofree(Lines.new())
	for i: int in 3:
		OhmBoltDraw.link(ink, LINE, i, 2 * i)
	assert_eq(ink.widths, [0.6, 1.0, 1.0])
	assert_eq(ink.opacity, [1.0, 1.0, 1.0])
	for line: PackedVector2Array in ink.points:
		assert_eq(line[0], LINE[0])
		assert_eq(line[-1], LINE[-1])


func test_links_arrive_two_ticks_apart_and_fade_from_their_own_start() -> void:
	var ink: Lines = autofree(Lines.new())
	for i: int in 3:
		var start: int = 2 * i
		for t: int in range(-1, start + 15):
			ink.opacity.clear()
			OhmBoltDraw.link(ink, LINE, i, t)
			var age: int = t - start
			if age < 0 or age >= 14:
				assert_true(ink.opacity.is_empty())
			else:
				assert_eq(ink.opacity.size(), 1)
				assert_almost_eq(ink.opacity[0], 1.0 - age / (60.0 * 0.22), 0.00001)


func test_reduced_motion_arrives_together_and_holds_the_same_jag() -> void:
	var ink: Lines = autofree(Lines.new())
	ink.reduced_motion = true
	for i: int in 3:
		OhmBoltDraw.link(ink, LINE, i, 0)
		OhmBoltDraw.link(ink, LINE, i, 6)
		assert_eq(ink.points[2 * i], ink.points[2 * i + 1])
		assert_eq(ink.opacity[2 * i], 1.0)


func test_paired_leaders_leave_the_actual_tips_and_meet_at_one_point() -> void:
	var ink: Lines = autofree(Lines.new())
	var tips: PackedVector2Array = [Vector2(6, 4), Vector2(2, 4), Vector2(4, 4)]
	var join: Vector2 = Vector2(4, -10)
	OhmBoltDraw.prongs(ink, tips, join, 0.75)
	assert_eq(ink.points.size(), 2)
	for i: int in 2:
		assert_eq(ink.points[i], PackedVector2Array([tips[i], join]))
		assert_lt(ink.widths[i], OhmBoltDraw.width(0))
		assert_eq(ink.opacity[i], 0.75)


func test_ring_and_all_spark_segments_clear_the_body_and_travel_outward() -> void:
	for body: float in [0.3, 0.45, 0.9]:
		var radius: float = (body + OhmVictimRims.CLEARANCE_M) * 32.0
		assert_gt(radius - 1.3, body * 32.0, "inside of the 2.6 px ink ring")
		for i: int in 4:
			var last: float = radius
			for age: int in OhmVictimRims.SPARK_TICKS:
				var ray: PackedVector2Array = OhmVictimRims.spark(radius, age, i, 7)
				assert_gt(ray[0].length(), last)
				assert_gt(ray[1].length(), ray[0].length())
				assert_almost_eq(ray[0].angle_to(ray[1]), 0.0, 0.00001)
				last = ray[0].length()


func test_the_cancel_sputter_is_amber_for_the_whole_vent() -> void:
	for vent: float in [1.0, 0.5, 0.01]:
		assert_eq(OhmFork.fork_ink(vent), Color("#ffb000"))
	assert_eq(OhmFork.fork_ink(0.0), OhmView.WHITE)


func test_fork_pixels_follow_the_drawn_sprite_including_its_left_mirror() -> void:
	var sprite: Sprite2D = add_child_autofree(Sprite2D.new())
	sprite.texture = load("res://features/souls/art/view/p70/ohm_spec_act.png")
	sprite.hframes = 4
	sprite.vframes = 5
	sprite.centered = false
	sprite.offset = Vector2(-159, -227)
	sprite.transform = Transform2D(0.3, Vector2(0.42, 0.51), 0.0, Vector2(40, 70))
	var fork: OhmFork = OhmFork.new()
	sprite.add_child(fork)
	var view: Node2D = add_child_autofree(Node2D.new())
	view.rotation = -0.23
	var row: Dictionary = {"fork_px": [200, 130], "prongs_px": [[198, 132], [202, 128]]}
	for flip: bool in [false, true]:
		sprite.flip_h = flip
		var cell: PackedVector2Array = OhmFork.unpack(row)
		fork.place(sprite, cell)
		var actual: PackedVector2Array = fork.points_on(view)
		for i: int in 3:
			var p: Vector2 = cell[i]
			if flip:
				p.x = 318.0 - p.x
			assert_true(
				view.to_global(actual[i]).is_equal_approx(sprite.to_global(sprite.offset + p))
			)


func test_only_the_marked_spectral_victim_yields_its_shared_stun_sparks() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	stage.setup(World.build_context(bus, data, 1))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	var rims: OhmVictimRims = OhmVictimRims.new()
	rims.stage = stage
	rims.ppm = 32.0
	add_child_autofree(rims)
	var target: Fighter = stage.arena.spawn_guard(Vector2.RIGHT)
	var other: Fighter = stage.arena.spawn_guard(Vector2.LEFT)
	var count: Vector2i = Vector2i(3, 4)
	stage.pilot.ohm.bolt_tick = stage.tick
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	stage.arena.struck.emit(target, Vector2.RIGHT, true, OhmStage.WEAPON)
	assert_eq(OhmVictimRims.arcs(target, count), Vector2i.ZERO)
	assert_eq(OhmVictimRims.sparks(target, 2), 0)
	assert_eq(OhmVictimRims.arcs(other, count), count)
	assert_eq(OhmVictimRims.sparks(other, 2), 2)
	GhostLook.override_for_test(GhostLook.LEGACY)
	assert_eq(OhmVictimRims.arcs(target, count), count)
	assert_eq(OhmVictimRims.sparks(target, 2), 2)
	GhostLook.override_for_test(GhostLook.SPECTRAL)
	stage.tick += 17
	rims._process(0.0)
	assert_true(OhmVictimRims.marked(target))
	stage.tick += 1
	rims._process(0.0)
	assert_false(OhmVictimRims.marked(target))
	GhostLook.reset_for_test()


func test_the_jag_changes_only_on_each_second_tick_in_full_motion() -> void:
	var ink: Lines = autofree(Lines.new())
	for tick: int in 4:
		OhmBoltDraw.link(ink, LINE, 0, tick)
	assert_eq(ink.points[0], ink.points[1])
	assert_ne(ink.points[1], ink.points[2])
	assert_eq(ink.points[2], ink.points[3])
