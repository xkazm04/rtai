extends GutTest
## n31 ghost 21: Kerf's drop-mode deploy (one press locks the target, a 0.2 s wind-up, then the
## blink behind it and the cut on the charge's last tick; no target = refused, no cooldown).

var stage: CollectCallStage
var arena: CombatArena
var squad: ArenaSquad
var pilot: StagePilot
var ghost: GhostDeploy
var row: GhostAttacks.DeployRow
var key: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	arena = stage.arena
	arena.rivet.pos = Vector2.ZERO
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	squad = ArenaSquad.new(arena.guard_map)
	arena.squad_ai = squad
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	row = ghost.strike.attacks.deploy[&"kerf"]
	pilot.ghosts.forms.selected = &"kerf"
	key = 1 << pilot.actions.bit(&"ghost_deploy")


func _spawn(at: Vector2) -> Fighter:
	var foe: Fighter = squad.spawn_member(arena, at, &"contractor")
	foe.pos = at
	foe.facing = Vector2.UP
	foe.max_hp = 1000.0
	foe.hp = 1000.0
	return foe


func _drive(bits: int = 0, reach: float = 6.0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, reach)
	pilot.drive(stage, TickInput.new(aim | bits))


## Press, then idle up to (not including) the cut tick.
func _press_and_wind_up() -> void:
	_drive(key)
	var pressed: int = stage.tick
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive()


func _cut() -> float:
	return ghost.strike.attacks.num(&"kerf", &"human_damage")


func test_shipped_row_is_a_quick_drop_that_refuses_without_a_target() -> void:
	var shipped: GhostAttacks.DeployRow = GhostAttacks.shipped().deploy[&"kerf"]
	assert_eq(shipped.press_mode, &"drop", "n31: one press, a wind-up, the cut")
	assert_eq(shipped.charge_ticks, 12, "0.2 s: Kerf is the quick one")
	assert_eq(shipped.no_target, &"refuse")


func test_the_locked_target_is_cut_on_the_last_tick_and_not_before() -> void:
	var foe: Fighter = _spawn(Vector2(6, 0))
	_drive(key)
	var pressed: int = stage.tick
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE, "no aiming phase")
	assert_eq(ghost.dump.kerf.target, foe, "locked on the press")
	var side: Vector2 = Vector2.RIGHT.orthogonal() * arena.rivet.radius_m
	assert_eq(ghost.origin, side, "Kerf arrives at Rivet's side")
	assert_almost_eq(ghost.facing, side.direction_to(foe.pos), Vector2.ONE * 0.0001)
	assert_eq(ghost.cooldowns[&"kerf"], row.cooldown_ticks)
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive()
		assert_eq(foe.hp, foe.max_hp, "nothing is cut during the wind-up")
	_drive()
	assert_eq(stage.tick, pressed + row.charge_ticks)
	assert_eq(foe.max_hp - foe.hp, _cut(), "cut on the charge's last tick")
	var behind: float = ghost.strike.attacks.num(&"kerf", &"behind_m") + foe.radius_m
	assert_eq(ghost.spot, foe.pos - foe.facing * behind, "blinked behind it")
	assert_eq(ghost.origin, side, "the press origin is kept for the view")
	assert_eq(arena.rivet.pos, Vector2.ZERO, "Rivet does not move")


func test_the_lock_follows_a_target_that_walks_during_the_wind_up() -> void:
	var foe: Fighter = _spawn(Vector2(6, 0))
	_drive(key)
	var decoy: Fighter = _spawn(Vector2(6, 0))
	var pressed: int = stage.tick
	while stage.tick < pressed + row.charge_ticks:
		foe.pos += Vector2(-0.1, 0.25)
		_drive()
	assert_eq(foe.max_hp - foe.hp, _cut(), "the walked target is cut")
	assert_eq(decoy.hp, decoy.max_hp, "the spot it left is not")


func test_a_press_with_no_target_is_refused_without_cooldown() -> void:
	var out_of_range: Fighter = _spawn(Vector2(row.range_m + 1.0, 0))
	_drive(key)
	assert_eq(ghost.last_refusal, &"no_target")
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	assert_false(ghost.cooldowns.has(&"kerf"), "no cooldown spent")
	assert_false(ghost.dump.pending())
	for _i: int in row.charge_ticks + 2:
		_drive()
	assert_eq(out_of_range.hp, out_of_range.max_hp)


func test_a_target_that_dies_in_the_wind_up_is_a_whiff_with_cooldown_spent() -> void:
	var foe: Fighter = _spawn(Vector2(6, 0))
	var bystander: Fighter = _spawn(Vector2(6, 1.5))
	_press_and_wind_up()
	foe.hp = 0.0
	_drive()
	assert_eq(bystander.hp, bystander.max_hp, "no fresh pick")
	assert_eq(ghost.cooldowns[&"kerf"], row.cooldown_ticks - row.charge_ticks)
	var dash: float = ghost.strike.attacks.num(&"kerf", &"dash_m")
	assert_almost_eq(ghost.spot, ghost.origin + ghost.facing * dash, Vector2.ONE * 0.0001)


func test_a_target_past_range_and_slack_breaks_the_lock() -> void:
	var foe: Fighter = _spawn(Vector2(6, 0))
	_press_and_wind_up()
	foe.pos = Vector2(row.range_m + KerfDrop.SLACK_M + 0.1, 0)
	_drive()
	assert_eq(foe.hp, foe.max_hp, "beyond range_m + 2 m: no cut")


func test_whiff_mode_deploys_without_a_target_and_spends_the_cooldown() -> void:
	row.no_target = &"whiff"
	_drive(key)
	assert_eq(ghost.last_refusal, &"")
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_eq(ghost.cooldowns[&"kerf"], row.cooldown_ticks)
	assert_null(ghost.dump.kerf.target)
