extends GutTest


func test_kill_spurts_within_budget_and_leaves_a_pool() -> void:
	var b: BloodFx = BloodFx.new()
	b.splash(Vector2(100, 100), Vector2.RIGHT, "kill")
	assert_gt(b.drops, 0)
	var budget: Dictionary = b.p["budget"]
	var max_drops: int = budget["max_drops"]
	assert_lte(b.drops, max_drops)
	b.step_ticks(120)
	assert_eq(b.drops, 0, "every droplet lands within its life")
	assert_gt(b.live_decals(), 1)
	b.free()


func test_droplets_never_evict_a_pool() -> void:
	var b: BloodFx = BloodFx.new()
	b.splash(Vector2.ZERO, Vector2.RIGHT, "kill")
	for i: int in 30:
		b.splash(Vector2(i * 10, 0), Vector2.UP, "player_hit")
		b.step_ticks(30)
	var budget: Dictionary = b.p["budget"]
	var max_decals: int = budget["max_decals"]
	assert_lte(b.live_decals(), max_decals)
	assert_true(b.has_pool_at(Vector2.ZERO, 8.0), "the kill's pool survives the splats")
	b.free()


func test_same_hits_same_blood() -> void:
	var a: BloodFx = BloodFx.new()
	var c: BloodFx = BloodFx.new()
	for fx: BloodFx in [a, c]:
		fx.splash(Vector2(5, 5), Vector2.LEFT, "kill")
		fx.step_ticks(40)
	assert_eq(a.live_decals(), c.live_decals())
	a.free()
	c.free()


func test_impact_beat_is_one_to_three_frames() -> void:
	var f: ImpactFrame = ImpactFrame.new()
	assert_between(f.sequence.size(), 1, 3, "the flash is 1-3 frames")
	assert_between(f.panel_ticks, 0, 12, "then the held panel, at most 0.2 s")
	f.fire(Vector2(0.5, 0.5))
	var frames: int = 0
	while f.active() and frames < 30:
		frames += 1
		f.step_ticks(1)
	assert_eq(frames, f.sequence.size() + f.panel_ticks)
	f.free()


func test_pool_edge_wobbles_but_stays_star_shaped_and_runs_along_the_hit() -> void:
	var at: Vector2 = Vector2(40, 12)
	var s: float = BloodMarks.seed_of(at)
	var still: PackedVector2Array = BloodMarks.ring(at, 20.0, Vector2.ZERO, s)
	var run: PackedVector2Array = BloodMarks.ring(at, 20.0, Vector2.RIGHT * 0.6, s)
	assert_eq(still.size(), BloodMarks.POOL_PTS)
	var lo: float = INF
	var hi: float = 0.0
	for k: int in still.size():
		var d: float = still[k].distance_to(at)
		lo = minf(lo, d)
		hi = maxf(hi, d)
	assert_gt(lo, 20.0 * 0.6, "never pinched to the centre (a simple polygon)")
	assert_gt(hi - lo, 2.0, "the wet edge wobbles, it is not a disc")
	assert_gt(run[0].x - still[0].x, 5.0, "the pool runs out along the hit direction")
	assert_almost_eq(run[BloodMarks.POOL_PTS / 2].x, still[BloodMarks.POOL_PTS / 2].x, 0.01)


func test_a_hit_fighter_leaves_a_drip_trail_that_stops() -> void:
	var fx: NoirCombatFx = NoirCombatFx.new()
	var blood: BloodFx = BloodFx.new()
	fx.blood = blood
	var pos: Array[Vector2] = [Vector2(2, 2)]
	fx.locate = func(_id: int) -> Vector2: return pos[0]
	fx._on_player_hit(&"pistol")
	var after_hit: int = blood.live_decals()
	assert_eq(fx.bleeding(), 1)
	for t: int in 60:
		pos[0] += Vector2(0.1, 0.0)
		fx.step_ticks(1)
	var walked: int = blood.live_decals() - after_hit
	assert_between(walked, 15, 25, "about one drip per every_px of the 6 m walked")
	var bleed: int = blood.p["drip"]["bleed_ticks"]
	fx.step_ticks(bleed)
	assert_eq(fx.bleeding(), 0, "the wound stops bleeding")
	blood.free()
	fx.free()
