extends GutTest
## n12 E1: the fight's new rounds and blasts start a light each, within the photosensitivity
## budget and the radius, never twice for the same round; off when the table or the motion says so.

var _lights: LightLayer


func before_each() -> void:
	_lights = LightLayer.new()
	add_child_autofree(_lights)


func _arena() -> CombatArena:
	var bus: EventBus = autofree(EventBus.new())
	var reg: RngRegistry = RngRegistry.new(5)
	return CombatArena.new(CombatTuning.shipped(), bus, reg.stream(&"combat"))


func _cl(arena: CombatArena) -> ArenaCombatLights:
	var cl: ArenaCombatLights = ArenaCombatLights.make(arena, _lights)
	cl.on = true
	cl.radius_px = 20.0 * SimConst.PX_PER_M
	return cl


func _shot(arena: CombatArena, at: Vector2) -> Shot:
	var s: Shot = Shot.new()
	s.pos = at
	s.vel = Vector2.RIGHT * 30.0
	arena.shots.append(s)
	return s


func test_the_table_ships_it_with_a_radius() -> void:
	var cl: ArenaCombatLights = ArenaCombatLights.make(_arena(), _lights)
	assert_true(cl.on)
	assert_gt(cl.radius_px, 0.0)


func test_a_new_round_lights_once_and_the_budget_holds_a_volley() -> void:
	var arena: CombatArena = _arena()
	var cl: ArenaCombatLights = _cl(arena)
	cl.focus_px = arena.rivet.pos * SimConst.PX_PER_M
	@warning_ignore("return_value_discarded")
	_shot(arena, arena.rivet.pos)
	cl.step(10)
	assert_eq(cl.started, 1)
	cl.step(11)
	assert_eq(cl.started, 1, "the same round does not light again")
	for k: int in 5:
		@warning_ignore("return_value_discarded")
		_shot(arena, arena.rivet.pos)
	cl.step(12)
	assert_eq(cl.started, 1, "a volley inside the window: the budget keeps room for a kill beat")
	assert_gt(cl.refused, 0)


func test_a_far_round_and_the_off_switches_light_nothing() -> void:
	var arena: CombatArena = _arena()
	var cl: ArenaCombatLights = _cl(arena)
	cl.focus_px = Vector2.ZERO
	@warning_ignore("return_value_discarded")
	_shot(arena, Vector2(500.0, 0.0))
	cl.step(1)
	assert_eq(cl.started, 0, "outside the radius")
	var quiet: ArenaCombatLights = _cl(arena)
	quiet.reduced_motion = true
	quiet.focus_px = Vector2(500.0, 0.0) * SimConst.PX_PER_M
	quiet.step(1)
	assert_eq(quiet.started, 0, "reduced motion")
	var off: ArenaCombatLights = _cl(arena)
	off.on = false
	off.focus_px = quiet.focus_px
	off.step(1)
	assert_eq(off.started, 0, "the before")


## On its own frame: it follows Rivet, and the budget refills with the arena's ticks (a volley a
## second later lights again).
func test_each_new_tick_follows_rivet_and_refills_the_budget() -> void:
	var arena: CombatArena = _arena()
	var cl: ArenaCombatLights = _cl(arena)
	arena.rivet.pos = Vector2(3.0, 4.0)
	@warning_ignore("return_value_discarded")
	_shot(arena, arena.rivet.pos)
	arena.tick = 5
	cl._process(0.0)
	assert_eq(cl.focus_px, Vector2(3.0, 4.0) * SimConst.PX_PER_M)
	assert_eq(cl.started, 1)
	cl._process(0.0)
	assert_eq(cl.started, 1, "the same tick twice steps once")
	for k: int in 2:
		arena.shots.clear()
		@warning_ignore("return_value_discarded")
		_shot(arena, arena.rivet.pos)
		arena.tick += FlashBudget.WINDOW + 1
		cl._process(0.0)
	assert_eq(cl.started, 3, "each a window later: room again")


func test_a_round_on_the_radius_edge_lights_and_the_row_switches_hold() -> void:
	var arena: CombatArena = _arena()
	var cl: ArenaCombatLights = _cl(arena)
	cl.focus_px = Vector2.ZERO
	@warning_ignore("return_value_discarded")
	_shot(arena, Vector2(20.0, 0.0))
	cl.step(1)
	assert_eq(cl.started, 1, "exactly radius_m away still lights")
	var path: String = TestTmp.dir("n12_lights").path_join("lights.json")
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	@warning_ignore("return_value_discarded")
	f.store_string(
		'{"combat_lights": {"on": true, "muzzle": false, "blast": false, "radius_m": 5}}'
	)
	f.close()
	var row: ArenaCombatLights = ArenaCombatLights.make(arena, _lights)
	row.read(path)
	assert_false(row.muzzle)
	assert_false(row.blast)
	assert_eq(row.radius_px, 5.0 * SimConst.PX_PER_M)
