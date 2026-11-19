extends GutTest
## The shipped pit's 2.4 x 0.8 m cover at (4, 13), with combatants placed by each test.

var stage: ArenaStage
var motion: PlayerMotion
var vault: PlayerVault
var body: Fighter


func before_each() -> void:
	var stations: ArenaStations = ArenaStations.new()
	stations.add_file(ArenaStations.DIR + "/arena.json")
	for station: ArenaStation in stations.stations:
		station.spawns.clear()
	stage = ArenaStage.new(ArenaPlan.shipped(), stations)
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage.setup(World.build_context(bus, data, 19))
	stage.pilot = StagePilot.new(PlayerActions.shipped())
	motion = stage.pilot.motion
	vault = motion.vault
	vault.enabled = true
	body = stage.arena.rivet
	body.pos = Vector2(4.0, 11.75)
	motion.mover.velocity = Vector2.DOWN * 8.0


func _tick(k: int) -> void:
	var bits: int = 1 << stage.pilot.actions.bit(&"roll") if k == 0 else 0
	stage.step(k, TickInput.new(bits, 0, TickInput.AXIS_MAX))


func test_continuous_cover_crossing_and_tackle() -> void:
	var person: Fighter = Fighter.make(Fighter.Kind.GUARD, 190, Vector2(4.0, 14.2), 1.0)
	person.brain_owned = true
	stage.arena.hostiles.append(person)
	var steps: PackedFloat64Array = []
	var air: Array[int] = []
	var tackle_speed: float = 0.0
	var push: float = 0.0
	for k: int in vault.ticks:
		var before: Vector2 = body.pos
		var target: Vector2 = person.pos
		_tick(k)
		var moved: float = body.pos.distance_to(before)
		@warning_ignore("return_value_discarded")
		steps.append(snappedf(moved, 0.0001))
		assert_gt(moved, 0.0)
		assert_lte(moved, 2.0 * vault.start.distance_to(vault.hit.landing) / vault.ticks)
		if vault.airborne():
			air.append(k)
		if person.pos.distance_to(target) > 1.0:
			tackle_speed = moved / SimClock.TICK_DT
			push = person.pos.distance_to(target)
	assert_gt(tackle_speed, ArenaBodies.table().run_mps(RivetBody.CLASS))
	assert_eq(body.pos, vault.hit.landing)
	assert_gt(air.size(), 0)
	Log.info(
		"vault",
		(
			"cover_low steps_m %s; airborne %s; contact %.3f m/s, shove %.3f m"
			% [steps, air, tackle_speed, push]
		)
	)


func test_lethal_round_on_an_airborne_tick_lands_before_the_death_beat() -> void:
	for k: int in 13:
		_tick(k)
	assert_true(vault.airborne())
	var shot: Shot = Shot.new()
	shot.from_rivet = false
	shot.pos = vault.hit.landing
	shot.vel = Vector2.UP * 3.0
	shot.damage = body.max_hp
	stage.arena.shots.append(shot)
	_tick(13)  # still over the far edge, just past the i-frame window
	assert_false(body.alive())
	_assert_interrupted()


func test_stop_in_midair_lands_immediately_and_is_idempotent() -> void:
	for k: int in 8:
		_tick(k)
	assert_true(vault.airborne())
	stage.pilot.stop()
	_assert_interrupted()
	stage.pilot.stop()
	_assert_interrupted()


func test_hide_stop_uses_the_same_landing() -> void:
	for k: int in 8:
		_tick(k)
	assert_true(vault.airborne())
	stage.hidden_in = "test_hide"
	stage.step(8, TickInput.new())
	_assert_interrupted()


func test_body_displacement_into_other_cover_cannot_take_the_airborne_exemption() -> void:
	var wall: ArenaStation.Prop = ArenaStation.Prop.new()
	wall.kind = "wall_high"
	wall.at = Vector2(4.8, 12.8)
	wall.size = Vector2(0.2, 0.4)
	stage.stations.stations[0].props.append(wall)
	stage.walls = ArenaWalls.from_stations(stage.stations, stage.plan.base)
	for k: int in 8:
		_tick(k)
	assert_true(vault.airborne())
	# A body displaced Rivet sideways after the pilot wrote the path for this tick.
	body.pos += Vector2.RIGHT * 0.2
	assert_true(vault.airborne(), "his circle still overlaps the vault target")
	assert_false(vault.airborne_after_contacts(motion))
	_assert_interrupted()


func _assert_interrupted() -> void:
	assert_eq(body.pos, vault.hit.landing)
	assert_eq(motion.phase, PlayerMotion.Phase.RECOVER)
	assert_true(vault.probe.clear_at(body.pos, body.radius_m))
	assert_true(body.exposed)
	assert_false(vault.airborne())
	assert_eq(vault.lift(), 0.0)


func test_vault_uses_the_configured_default() -> void:
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var default_enabled: bool = table.object(table.raw, "vault")["enabled"]
	assert_eq(PlayerMotion.shipped().vault.enabled, default_enabled)
	for enabled: bool in [false, true]:
		table.raw["vault"]["enabled"] = enabled
		assert_eq(PlayerMotion.from_table(table).vault.enabled, enabled)


func test_intercept_requires_a_fresh_prepare() -> void:
	assert_false(vault.intercept(motion, Vector2.DOWN))
	vault.prepare(stage)
	assert_true(vault.intercept(motion, Vector2.DOWN))
	assert_false(vault.intercept(motion, Vector2.DOWN))


func test_prepare_expires_at_the_end_of_a_tick_without_a_press() -> void:
	vault.prepare(stage)
	stage.step(0, TickInput.new())
	assert_false(vault.intercept(motion, Vector2.DOWN))


func test_interrupt_discards_a_prepared_press() -> void:
	vault.prepare(stage)
	vault.interrupt()
	assert_false(vault.intercept(motion, Vector2.DOWN))


func test_binding_an_ordinary_stage_forgets_arena_walls() -> void:
	vault.prepare(stage)
	assert_false(vault.probe.boxes.is_empty())
	var street: CollectCallStage = CollectCallStage.new(stage.layout)
	street.arena = stage.arena
	vault.prepare(street)
	assert_true(vault.probe.boxes.is_empty())
	assert_true(vault.probe.clear_at(Vector2(4.0, 13.0), body.radius_m))


func test_missing_switches_default_to_off_and_keep_the_gun_down() -> void:
	var table: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	var row: Dictionary = table.object(table.raw, "vault")
	assert_true(row.erase("enabled"))
	assert_true(row.erase("no_fire"))
	var configured: PlayerVault = PlayerMotion.from_table(table).vault
	assert_false(configured.enabled)
	assert_true(configured.no_fire)


func test_first_tick_can_be_protected_and_can_be_interrupted() -> void:
	vault.iframe_from = 0
	motion.sprinting = true
	_tick(0)
	assert_false(motion.sprinting)
	assert_false(body.exposed)
	body.hp = 0.0
	assert_false(vault.airborne_after_contacts(motion))
	_assert_interrupted()


func test_contact_can_shift_an_airborne_body_without_a_second_solid() -> void:
	for k: int in 8:
		_tick(k)
	body.pos += Vector2.RIGHT * 0.1
	assert_true(vault.airborne_after_contacts(motion))
	assert_eq(motion.phase, PlayerMotion.Phase.VAULT)
