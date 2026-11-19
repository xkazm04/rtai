extends GutTest
## The shipped landing check consumes the press on the approach side of the crate.


func _press(offset: Vector2, alive: bool, down: bool = false) -> ArenaStage:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	var guard: Fighter = VaultTrial.place_landing_guard(stage)
	guard.pos += offset
	guard.hp = guard.max_hp if alive else 0.0
	if down:
		var fx: FighterFx = FighterFx.new()
		fx.down_ticks = 10
		stage.arena.areas = FightAreas.new()
		stage.arena.areas.fx[guard.id] = fx
	stage.step(0, VaultTrial.sample(stage, Vector2.DOWN, true))
	return stage


func test_an_occupied_landing_consumes_the_press_with_shipped_data() -> void:
	var stage: ArenaStage = _press(Vector2.ZERO, true)
	var motion: PlayerMotion = stage.pilot.motion
	assert_eq(motion.vault.hit.reason, &"landing_blocked")
	assert_eq(stage.arena.rivet.pos, Vector2(4, 11.75))
	assert_eq(motion.velocity(), Vector2.ZERO)
	assert_eq(motion.phase, PlayerMotion.Phase.FREE)
	assert_eq(motion.rolls, 0)


func test_a_clear_landing_or_a_dead_guard_still_allows_the_vault() -> void:
	assert_eq(_press(Vector2.RIGHT * 2.0, true).pilot.motion.phase, PlayerMotion.Phase.VAULT)
	assert_eq(_press(Vector2.ZERO, false).pilot.motion.phase, PlayerMotion.Phase.VAULT)


func test_disabling_the_body_check_allows_an_occupied_landing() -> void:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	@warning_ignore("return_value_discarded")
	VaultTrial.place_landing_guard(stage)
	var t: DataTable = DataTable.open(PlayerMotion.TABLE, PlayerMotion.SCHEMA)
	t.raw["vault"]["bodies_block_landing"] = false
	stage.pilot.motion.vault = PlayerVault.new()
	assert_true(stage.pilot.motion.vault.configure(t).is_empty())
	stage.step(0, VaultTrial.sample(stage, Vector2.DOWN, true))
	assert_eq(stage.pilot.motion.phase, PlayerMotion.Phase.VAULT)


func test_a_downed_guard_does_not_block_the_landing() -> void:
	assert_eq(_press(Vector2.ZERO, true, true).pilot.motion.phase, PlayerMotion.Phase.VAULT)


func test_a_guard_exactly_tangent_to_the_landing_leaves_it_clear() -> void:
	var stage: ArenaStage = VaultTrial.stage_for(false)
	var guard: Fighter = VaultTrial.place_landing_guard(stage)
	guard.pos = Vector2(0.75, 0)
	# Exactly representable radii make the equality case observable in Vector2 metres.
	var saved: BodyTable = ArenaBodies._table
	var table: BodyTable = BodyTable.new()
	table._radius[RivetBody.CLASS] = 0.5
	table._radius[RivetBody.PERSON] = 0.25
	ArenaBodies._table = table
	var tangent: bool = VaultProbe.landing_occupied(stage.arena, Vector2.ZERO)
	var overlapping: bool = VaultProbe.landing_occupied(stage.arena, Vector2(0.125, 0))
	ArenaBodies._table = saved
	assert_false(tangent)
	assert_true(overlapping)
