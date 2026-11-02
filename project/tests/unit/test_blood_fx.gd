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
