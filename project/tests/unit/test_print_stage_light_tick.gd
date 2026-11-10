extends GutTest
## n15 combat item 3 (the n14 owner call): the dev arena's PrintStage has no clock, so its lights
## stepped on tick 0 while ArenaCombatLights added them on the arena's tick: they never aged out.
## The lights now step on the host's tick source when there is no clock.


func test_no_clock_and_no_source_keeps_the_frame_tick() -> void:
	assert_eq(PrintStage.lights_tick(0, null, Callable()), 0)


func test_no_clock_takes_the_hosts_tick() -> void:
	var src: Callable = func() -> int: return 412
	assert_eq(PrintStage.lights_tick(0, null, src), 412)


func test_a_clock_wins_over_the_source() -> void:
	var clock: SimClock = SimClock.new()
	var src: Callable = func() -> int: return 412
	assert_eq(PrintStage.lights_tick(clock.tick(), clock, src), clock.tick())


func test_a_light_born_on_the_arena_tick_ages_out_on_it() -> void:
	var layer: LightLayer = LightLayer.new()
	add_child_autofree(layer)
	if not layer.kinds.has(&"muzzle_flash"):
		pending("no muzzle_flash light kind in this tree")
		return
	var life_f: float = layer.kinds[&"muzzle_flash"]["life_ticks"]
	var life: int = int(life_f)
	@warning_ignore("return_value_discarded")
	layer.add(&"muzzle_flash", Vector2.ZERO, 0.0, 400)
	layer.step(0, Vector2.ZERO)
	assert_eq(layer.active, 1, "stepped on tick 0 (the before) it never ages")
	var src: Callable = func() -> int: return 400 + life + 1
	layer.step(PrintStage.lights_tick(0, null, src), Vector2.ZERO)
	assert_eq(layer.active, 0, "aged out on the arena's tick")
