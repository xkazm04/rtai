extends GutTest
## n31 ghost 26: a refused ghost press is counted once per press edge (GhostDeploy.refusals and
## refused_form, view-only) so the HUD chip can answer it.

var stage: CollectCallStage
var pilot: StagePilot
var ghost: GhostDeploy
var key: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = CollectCallStage.new(StageLayout.shipped(false))
	stage.setup(World.build_context(bus, data, 24))
	stage.arena.rivet.pos = Vector2.ZERO
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	ghost = pilot.ghosts.deploy
	key = 1 << pilot.actions.bit(&"ghost_deploy")


func _drive(bits: int = 0) -> void:
	stage.tick += 1
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	pilot.drive(stage, TickInput.new(aim | bits))


func test_a_cooldown_press_is_counted_once_and_names_the_form() -> void:
	pilot.ghosts.forms.selected = &"tonnage"
	_drive(key)
	assert_eq(ghost.refusals, 0, "an accepted press is no refusal")
	assert_true(ghost.cooldowns.has(&"tonnage"))
	_drive()
	while ghost.phase != GhostDeploy.Phase.IDLE:
		_drive()
	assert_true(ghost.cooldowns.has(&"tonnage"), "still cooling")
	_drive(key)
	assert_eq(ghost.last_refusal, &"cooldown")
	assert_eq(ghost.refusals, 1)
	assert_eq(ghost.refused_form, &"tonnage")
	for tick: int in 10:
		_drive(key)
	assert_eq(ghost.refusals, 1, "holding the key is one press")
	_drive()
	_drive(key)
	assert_eq(ghost.refusals, 2, "a second press edge counts again")


func test_a_kerf_press_with_no_target_is_counted_and_spends_no_cooldown() -> void:
	pilot.ghosts.forms.selected = &"kerf"
	_drive(key)
	assert_eq(ghost.last_refusal, &"no_target")
	assert_eq(ghost.refusals, 1)
	assert_eq(ghost.refused_form, &"kerf")
	assert_false(ghost.cooldowns.has(&"kerf"))
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)


func test_the_counter_never_enters_the_replay_state() -> void:
	pilot.ghosts.forms.selected = &"kerf"
	var before: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(before)
	_drive(key)
	_drive()
	var after: StreamPeerBuffer = StreamPeerBuffer.new()
	ghost.write_state(after)
	assert_eq(ghost.refusals, 1)
	assert_eq(after.data_array, before.data_array)


func test_the_cue_shakes_its_chip_and_fades_out_after_18_frames() -> void:
	var cue: GhostRefusalCue = GhostRefusalCue.new()
	cue.notice(0, &"", false)
	assert_false(cue.active(&"tonnage"), "no refusal, no cue")
	cue.notice(1, &"tonnage", true)
	cue.notice(1, &"tonnage", true)
	assert_ne(cue.offset(&"tonnage"), Vector2.ZERO, "mid-cue the chip is off its spot")
	assert_eq(cue.offset(&"kerf"), Vector2.ZERO, "only the refused chip shakes")
	assert_gt(cue.rim(&"tonnage").a, 0.9)
	assert_ne(cue.arc(&"tonnage", Color.BLACK), Color.BLACK, "a cooldown cue flashes the arc")
	for f: int in GhostRefusalCue.FRAMES:
		cue.notice(1, &"tonnage", true)
	assert_false(cue.active(&"tonnage"))
	assert_eq(cue.offset(&"tonnage"), Vector2.ZERO)
	assert_eq(cue.rim(&"tonnage").a, 0.0)


func test_a_new_refusal_restarts_the_cue_on_its_form() -> void:
	var cue: GhostRefusalCue = GhostRefusalCue.new()
	cue.notice(1, &"tonnage", true)
	for f: int in 10:
		cue.notice(1, &"tonnage", true)
	assert_eq(cue.frame, 10)
	cue.notice(2, &"kerf", false)
	assert_eq(cue.frame, 0)
	assert_true(cue.active(&"kerf"))
	assert_false(cue.active(&"tonnage"))
	cue.notice(2, &"kerf", false)
	assert_eq(cue.arc(&"kerf", Color.BLACK), Color.BLACK, "no flash off a cooldown refusal")


## n31 ghost 26 step 1b: a Kerf drop whose lock dies in the wind-up and finds nobody to relock.
func _kerf_whiff(whiff_ticks: int, kill: bool) -> GhostAttacks.DeployRow:
	stage.arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	var squad: ArenaSquad = ArenaSquad.new(stage.arena.guard_map)
	stage.arena.squad_ai = squad
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[&"kerf"]
	row.whiff_cooldown_ticks = whiff_ticks
	pilot.ghosts.forms.selected = &"kerf"
	var foe: Fighter = squad.spawn_member(stage.arena, Vector2(6, 0), &"contractor")
	foe.pos = Vector2(6, 0)
	foe.max_hp = 1000.0
	foe.hp = 1000.0
	_drive(key)
	var pressed: int = stage.tick
	while stage.tick < pressed + row.charge_ticks - 1:
		_drive()
	if kill:
		foe.hp = 0.0
	_drive()
	return row


func test_a_kerf_whiff_leaves_the_short_cooldown_and_cues_the_chip() -> void:
	var row: GhostAttacks.DeployRow = _kerf_whiff(30, true)
	assert_lt(30, row.cooldown_ticks)
	assert_eq(ghost.dump.kerf.broke, &"dead")
	assert_eq(ghost.cooldowns[&"kerf"], 30, "a whiff costs 0.5 s, not the full cooldown")
	assert_eq(ghost.refusals, 1)
	assert_eq(ghost.refused_form, &"kerf")


func test_a_landed_cut_spends_the_full_cooldown_and_no_cue() -> void:
	var row: GhostAttacks.DeployRow = _kerf_whiff(30, false)
	assert_eq(ghost.cooldowns[&"kerf"], row.cooldown_ticks - row.charge_ticks)
	assert_eq(ghost.refusals, 0)


func test_whiff_cooldown_equal_to_the_full_cooldown_restores_before() -> void:
	var full: int = ghost.strike.attacks.deploy[&"kerf"].cooldown_ticks
	var row: GhostAttacks.DeployRow = _kerf_whiff(full, true)
	assert_eq(ghost.refusals, 1, "the chip still answers")
	assert_eq(ghost.cooldowns[&"kerf"], row.cooldown_ticks - row.charge_ticks)


func test_the_shipped_kerf_row_reads_whiff_cooldown_ticks() -> void:
	var row: GhostAttacks.DeployRow = GhostAttacks.shipped().deploy[&"kerf"]
	assert_between(row.whiff_cooldown_ticks, 1, row.cooldown_ticks)
