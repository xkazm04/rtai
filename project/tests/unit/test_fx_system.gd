extends GutTest
## The data-driven FX (core/render/fx_system.gd): every kind loads in palette inks, particles
## live on the sim tick, and both budgets (per frame, per pool) drop and count.


func test_every_kind_loads_on_the_fx_band_in_a_palette_ink() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	for k: StringName in [
		&"muzzle", &"tracer", &"impact", &"explosion", &"smoke", &"debris", &"ink_splat", &"crackle"
	]:
		assert_true(fx.kinds.has(k), String(k))
		var c: Color = fx.kinds[k]["color"]
		assert_ne(c, Color.MAGENTA, "%s token" % k)
		assert_ne(PaletteTokens.shared().classify(c), 2, "%s is not teal (the dead only)" % k)
	assert_eq(fx.z_index, RenderLayers.z(&"fx"))


func test_particles_expire_on_the_tick() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	assert_true(fx.spawn(&"impact", Vector2.ZERO, 0.0, 10))
	var count: int = fx.kinds[&"impact"]["count"]
	var life: int = fx.kinds[&"impact"]["life_ticks"]
	fx.step(10)
	assert_eq(fx.alive(), count)
	fx.step(10 + life)
	assert_eq(fx.alive(), 0)


func test_the_frame_budget_drops_and_counts() -> void:
	var fx: FxSystem = autofree(FxSystem.new())
	for i: int in fx.max_spawns_per_frame:
		assert_true(fx.spawn(&"muzzle", Vector2(i, 0), 0.0, 0))
	assert_false(fx.spawn(&"muzzle", Vector2.ZERO, 0.0, 0))
	assert_eq(fx.dropped, 1)
	fx.step(1)
	assert_true(fx.spawn(&"muzzle", Vector2.ZERO, 0.0, 1), "the budget resets each frame")


func test_spawns_are_the_same_every_run() -> void:
	var a: FxSystem = autofree(FxSystem.new())
	var b: FxSystem = autofree(FxSystem.new())
	for fx: FxSystem in [a, b]:
		@warning_ignore("return_value_discarded")
		fx.spawn(&"debris", Vector2(5, 5), 1.0, 0)
		fx.step(0)
		fx.step(3)
	assert_eq(a._pool.pos, b._pool.pos)
