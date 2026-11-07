extends GutTest
## F-09b: LOD and pooling. Full rigs for the nearest 16 within 14 m only, pools prewarmed so play
## never builds a rig, looks re-skin by texture, the crowd atlas layout matches the city's clip
## table, and the rigs draw no RNG stream (render-side, never in the replay hash).

const PX: float = 32.0

var _ctx: WorldContext = null
var _rigs: CharacterRigs = null


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	_ctx = World.build_context(bus, data, 7)
	_rigs = CharacterRigs.new()
	add_child_autofree(_rigs)
	_rigs.setup(_ctx)


func test_prewarm_builds_the_pools_once() -> void:
	var per_kind: int = CharacterRigs.MAX_FULL + RigSelect.CORPSE_PINS
	assert_eq(_rigs.rig_count(), 1 + 2 * per_kind)
	assert_eq(_rigs.pool().free_count(BodyPlan.Kind.COP), per_kind)


func test_only_the_nearest_16_within_14_m_get_rigs() -> void:
	_crowd(200, Vector2.ZERO)
	_rigs.step_ticks(1)
	assert_eq(_rigs.full_count(), CharacterRigs.MAX_FULL)
	for i: int in _rigs.feed.count:
		if _rigs.full_row(i):
			assert_lt(_rigs.feed.pos[i].length(), CharacterRigs.RADIUS_M * PX + 0.1)
	assert_true(_rigs.full_row(0), "Rivet always has his rig")
	assert_eq(_rigs.pool().grown, 0)


func test_moving_focus_recycles_rigs_without_building() -> void:
	_crowd(200, Vector2.ZERO)
	for k: int in 40:
		_rigs.focus = Vector2(k * 0.25 * PX, 0.0)
		_rigs.feed.pos[0] = _rigs.focus
		_rigs.step_ticks(1)
	assert_eq(_rigs.pool().grown, 0, "no rig built in play")
	assert_eq(_rigs.rig_count(), 1 + 2 * (CharacterRigs.MAX_FULL + RigSelect.CORPSE_PINS))
	assert_eq(_rigs.full_count(), CharacterRigs.MAX_FULL)


func test_selection_runs_every_few_ticks_and_rows_follow_between() -> void:
	_crowd(60, Vector2.ZERO)
	_rigs.step_ticks(1)
	var before: int = _rigs.full_count()
	# a newcomer right on the focus: the atlas draws it until the next selection
	@warning_ignore("return_value_discarded")
	_rigs.feed.put(_rigs.feed.count, 999, BodyPlan.Kind.PED, Vector2.ONE, Vector2.ZERO)
	_rigs.step_ticks(1)
	assert_null(_rigs.rig_for(999), "no reselect between selections")
	assert_eq(_rigs.full_count(), before)
	assert_true(_rigs.full_row(0), "kept rigs find their rows again")
	for k: int in CharacterRigs.SELECT_EVERY:
		_rigs.step_ticks(1)
	assert_not_null(_rigs.rig_for(999), "picked up within SELECT_EVERY ticks")


func test_a_kept_actor_leaving_the_feed_reselects_at_once() -> void:
	_crowd(60, Vector2.ZERO)
	_rigs.step_ticks(1)
	assert_not_null(_rigs.rig_for(101))
	_rigs.feed.ids[1] = 5000
	_rigs.step_ticks(1)
	assert_null(_rigs.rig_for(101), "the gone actor's rig went back to the pool")
	assert_eq(_rigs.full_count(), CharacterRigs.MAX_FULL)


func test_a_look_reskins_by_texture() -> void:
	var cop: CutRig = _rigs.pool().acquire(
		BodyPlan.Kind.COP, RigVariant.crowd(6), Vector2.ZERO, 0.0
	)
	assert_true(cop.sides[BodyPlan.L].shield.visible, "riot shield")
	var cap: Texture2D = PartLibrary.texture("cop", "head_cap")
	cop.apply_variant(RigVariant.crowd(5))
	assert_same(cop.head_spr.texture, cap)
	assert_false(cop.sides[BodyPlan.L].shield.visible, "patrol: no shield")


func test_rigs_draw_no_rng_stream() -> void:
	_crowd(60, Vector2.ZERO)
	_rigs.step_ticks(30)
	assert_eq(_ctx.rng.names().size(), 0, "render-side rigs must not move a hashed stream")


func test_crowd_atlas_matches_the_city_clip_table() -> void:
	var table: PackedInt32Array = CrowdAtlas.clip_table()
	assert_eq(table.size(), 8 * 6 * 3, "CLIP_VARIANTS x CLIPS x (first, count, fps)")
	assert_eq(table[(1 * 6 + CrowdAtlas.Clip.WALK) * 3], 25 + 1)
	assert_eq(CrowdAtlas.cell_for(0, CrowdAtlas.Clip.WALK, 1.0), 1 + 12 % 8, "walk loops")
	assert_eq(CrowdAtlas.cell_for(0, CrowdAtlas.Clip.DEATH, 9.0), 19 + 3, "death holds")
	var last: int = CrowdAtlas.cell_for(7, CrowdAtlas.Clip.SHOOT, 0.2)
	assert_lt(last, CrowdAtlas.cols() * CrowdAtlas.rows())


func test_a_fresh_corpse_keeps_its_rig_for_the_hold_then_drops() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	_rigs.corpse_hold_ticks = RigSelect.CORPSE_HOLD_TICKS  # the city host: its atlas takes over
	_corpse_under_a_crowd()
	assert_not_null(_rigs.rig_for(115), "the fresh corpse keeps its drawn fall")
	assert_eq(_rigs.full_count(), CharacterRigs.MAX_FULL + 1, "in a slot past the living 16")
	var living: int = 0
	for i: int in _rigs.feed.count:
		if _rigs.full_row(i) and not _rigs.feed.has_flag(i, RigFeed.Flag.DEAD):
			living += 1
	assert_eq(living, CharacterRigs.MAX_FULL, "no living person loses a rig for it")
	assert_eq(_rigs.pool().grown, 0, "the corpse slots are prewarmed")
	for k: int in RigSelect.CORPSE_HOLD_TICKS + CharacterRigs.SELECT_EVERY:
		_rigs.step_ticks(1)
	ViewMode._shared = saved
	assert_null(_rigs.rig_for(115), "after the hold the corpse goes back to the atlas")


func test_without_an_atlas_the_corpse_keeps_its_rig_until_it_leaves_the_feed() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("tilt70")
	_corpse_under_a_crowd()
	for k: int in RigSelect.CORPSE_HOLD_TICKS * 3:
		_rigs.step_ticks(1)
	assert_not_null(_rigs.rig_for(115), "the arena has no atlas to draw it")
	_rigs.feed.ids[15] = 7000  # the body decayed (CorpseFade): its row is another actor now
	for k: int in CharacterRigs.SELECT_EVERY + 1:
		_rigs.step_ticks(1)
	ViewMode._shared = saved
	assert_null(_rigs.rig_for(115))


func test_top_drops_the_corpse_as_before() -> void:
	var saved: ViewMode = ViewMode._shared
	ViewMode._shared = ViewMode.of("top")
	_corpse_under_a_crowd()
	ViewMode._shared = saved
	assert_null(_rigs.rig_for(115), "flat views keep the plain nearest-16 selection")


func _corpse_under_a_crowd() -> void:
	_crowd(40, Vector2.ZERO)
	_rigs.step_ticks(1)
	assert_not_null(_rigs.rig_for(115), "row 15 is among the 16 nearest")
	_rigs.feed.flags[15] = RigFeed.Flag.DEAD
	for k: int in 20:  # twenty living people closer to the focus than the corpse
		@warning_ignore("return_value_discarded")
		_rigs.feed.put(_rigs.feed.count, 900 + k, BodyPlan.Kind.PED, Vector2(k, 1.0), Vector2.ZERO)
	for k: int in CharacterRigs.SELECT_EVERY + 1:
		_rigs.step_ticks(1)


func test_corpse_pins_are_capped_latest_deaths_first() -> void:
	_crowd(40, Vector2.ZERO)
	_rigs.step_ticks(1)
	var died_at: Dictionary[int, int] = {}
	for r: int in range(1, 7):
		_rigs.feed.flags[r] = RigFeed.Flag.DEAD
		died_at[100 + r] = 5000 + r  # late in a run: the hold counts from the death tick
	var pins: Dictionary[int, int] = RigSelect.fresh_dead(
		_rigs.feed, _rigs._by_actor, died_at, 5010
	)
	assert_eq(pins.size(), RigSelect.CORPSE_PINS)
	assert_false(pins.has(101), "the oldest death is not pinned")
	assert_true(pins.has(106))
	assert_eq(died_at.size(), 6, "every rigged corpse keeps its death tick")


func _crowd(n: int, centre: Vector2) -> void:
	var f: RigFeed = _rigs.feed
	f.count = 0
	@warning_ignore("return_value_discarded")
	f.put(0, 1, BodyPlan.Kind.RIVET, centre, Vector2.ZERO)
	for i: int in range(1, n):
		var kind: BodyPlan.Kind = BodyPlan.Kind.COP if i % 4 == 0 else BodyPlan.Kind.PED
		var at: Vector2 = centre + Vector2.from_angle(i * 0.7) * (i * 0.25) * PX
		@warning_ignore("return_value_discarded")
		f.put(i, 100 + i, kind, at, Vector2.from_angle(i * 1.3) * 60.0)
