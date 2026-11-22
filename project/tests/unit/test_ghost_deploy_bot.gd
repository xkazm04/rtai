extends GutTest

var stage: ArenaStage
var actions: PlayerActions
var view: BotViewArena
var bot: GhostDeployBot
var ghost: GhostDeploy
var q: int


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.new())
	stage.setup(World.build_context(bus, data, 24))
	actions = PlayerActions.shipped(true)
	stage.pilot = StagePilot.new(actions)
	stage.pilot.ghosts.transform_unlocked = false
	stage.pilot.ghosts.forms.selected = &"ohm"
	stage.arena.rivet.pos = Vector2.ZERO
	view = BotViewArena.new(stage, actions, true)
	bot = GhostDeployBot.new(view, actions, RngRegistry.new(24))
	ghost = stage.pilot.ghosts.deploy
	q = 1 << actions.bit(&"ghost_deploy")


func _spawn(id: StringName, at: Vector2) -> Fighter:
	var foe: Fighter = stage.arena.squad_ai.spawn_member(stage.arena, at, id)
	foe.pos = at
	return foe


func _word(brain: GhostDeployBot, chance: float, buttons: int = 0) -> TickInput:
	view.refresh()
	var intent: GauntletBot.Intent = GauntletBot.Intent.new()
	intent.aim = Vector2.LEFT
	intent.reach = 12.0
	var bits: int = brain.steer(intent, buttons, chance)
	return TickInput.new(bits | PlayerCommand.pack_aim(intent.aim, actions, intent.reach))


func _drive(word: TickInput) -> void:
	stage.tick += 1
	stage.pilot.drive(stage, word)


func test_hold_aims_at_sentry_then_releases_there_even_while_g_wants_to_cycle() -> void:
	var sentry: Fighter = _spawn(&"sentry_turret", Vector2(6, 1))
	var fire: int = 1 << actions.bit(&"fire")
	var held: TickInput = _word(bot, 1.0, fire)
	assert_eq(held.buttons & (q | fire), q | fire)
	_drive(held)
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	assert_lte(ghost.spot.distance_to(sentry.pos), ghost.strike.attacks.deploy[&"ohm"].radius_m)
	var spot: Vector2 = ghost.spot
	var cycle: int = 1 << actions.bit(&"power_gearbox")
	var release: TickInput = _word(bot, 1.0, fire | cycle)
	assert_eq(release.buttons & (q | cycle | fire), fire)
	_drive(release)
	assert_eq(ghost.phase, GhostDeploy.Phase.ACTIVE)
	assert_eq(ghost.form, &"ohm")
	assert_eq(ghost.spot, spot)
	assert_lt(sentry.hp, sentry.max_hp)


func test_cycle_loads_the_new_ghost_before_aiming_its_strike() -> void:
	var forms: GhostForms = stage.pilot.ghosts.forms
	forms.selected = &"kerf"
	var first: Fighter = _spawn(&"shield_robot", Vector2(5, 0))
	var second: Fighter = _spawn(&"shield_robot", Vector2(6, 0))
	var cycle: int = 1 << actions.bit(&"power_gearbox")
	var select: TickInput = _word(bot, 1.0, cycle)
	assert_eq(select.buttons & (q | cycle), cycle)
	_drive(select)
	assert_eq(forms.selected, &"ohm")
	assert_eq(ghost.phase, GhostDeploy.Phase.IDLE)
	_drive(_word(bot, 1.0))
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	_drive(_word(bot, 1.0))
	assert_eq(ghost.form, &"ohm")
	assert_lt(first.hp, first.max_hp)
	assert_lt(second.hp, second.max_hp)


func test_cooldown_active_ghost_and_zero_eagerness_leave_the_gun_aim_alone() -> void:
	var sentry: Fighter = _spawn(&"sentry_turret", Vector2(8, 0))
	var normal: int = PlayerCommand.pack_aim(Vector2.LEFT, actions, 12.0)
	assert_eq(_word(bot, 0.0).buttons, normal)
	ghost.cooldowns[&"ohm"] = 1
	assert_eq(_word(bot, 1.0).buttons, normal)
	ghost.cooldowns.clear()
	ghost.phase = GhostDeploy.Phase.ACTIVE
	assert_eq(_word(bot, 1.0).buttons, normal)
	ghost.phase = GhostDeploy.Phase.IDLE
	sentry.pos = Vector2(20, 0)
	assert_eq(_word(bot, 1.0).buttons, normal)


func test_ohm_requires_a_sentry_or_two_machines_inside_the_same_radius() -> void:
	var first: Fighter = _spawn(&"shield_robot", Vector2(6, 0))
	var other: Fighter = _spawn(&"shield_robot", Vector2(-6, 0))
	assert_eq(_word(bot, 1.0).buttons & q, 0)
	other.pos = first.pos + Vector2(1, 0)
	assert_eq(_word(bot, 1.0).buttons & q, q)


func test_kerf_requires_an_eligible_visible_target() -> void:
	stage.pilot.ghosts.forms.selected = &"kerf"
	var cop: Fighter = _spawn(&"patrol_cop", Vector2(6, 1))
	assert_eq(_word(bot, 1.0).buttons & q, 0)
	var shield: Fighter = _spawn(&"shield_robot", Vector2(5, -1))
	stage.walls.boxes.append(Rect2(2, -3, 1, 3))
	assert_eq(_word(bot, 1.0).buttons & q, 0)
	stage.walls.boxes.clear()
	assert_eq(_word(bot, 1.0).buttons & q, q)
	assert_true(cop.alive() and shield.alive())


func test_tonnage_needs_three_bodies_or_a_walker_and_dent_needs_a_pair() -> void:
	var first: Fighter = _spawn(&"patrol_cop", Vector2(4, 0))
	stage.pilot.ghosts.forms.selected = &"dent"
	assert_eq(_word(bot, 1.0).buttons & q, 0)
	var second: Fighter = _spawn(&"patrol_cop", Vector2(6, 0))
	assert_eq(_word(bot, 1.0).buttons & q, q)
	stage.pilot.ghosts.forms.selected = &"tonnage"
	assert_eq(_word(bot, 1.0).buttons & q, 0)
	var third: Fighter = _spawn(&"patrol_cop", Vector2(5, 1))
	assert_eq(_word(bot, 1.0).buttons & q, q)
	first.hp = 0.0
	second.hp = 0.0
	third.hp = 0.0
	var walker: Fighter = _spawn(&"war_machine", Vector2(7, 0))
	assert_eq(_word(bot, 1.0).buttons & q, q)
	assert_true(walker.alive())


func test_missed_roll_waits_thirty_ticks_and_private_streams_repeat_the_same_words() -> void:
	var sentry: Fighter = _spawn(&"sentry_turret", Vector2(5, 1))
	var registry: RngRegistry = RngRegistry.new(24)
	var chance: float = registry.stream(&"test_player_ghost_deploy").randf() * 0.5
	var twin: GhostDeployBot = GhostDeployBot.new(view, actions, RngRegistry.new(24))
	var initial: TickInput = _word(bot, chance)
	assert_eq(initial.buttons & q, 0)
	assert_eq(initial.pack(), _word(twin, chance).pack())
	for tick: int in range(1, 31):
		stage.tick = tick
		var word: TickInput = _word(bot, 1.0)
		assert_eq(word.buttons & q, q if tick == 30 else 0)
		assert_eq(word.pack(), _word(twin, 1.0).pack())
	assert_true(sentry.alive())


func test_disabled_locked_and_mastery_forms_leave_the_existing_buttons_unchanged() -> void:
	var sentry: Fighter = _spawn(&"sentry_turret", Vector2(5, 1))
	var forms: GhostForms = stage.pilot.ghosts.forms
	var normal: int = PlayerCommand.pack_aim(Vector2.LEFT, actions, 12.0)
	var row: GhostAttacks.DeployRow = ghost.strike.attacks.deploy[&"ohm"]
	row.enabled = false
	assert_eq(_word(bot, 1.0).buttons, normal)
	row.enabled = true
	stage.pilot.ghosts.transform_unlocked = true
	assert_eq(_word(bot, 1.0).buttons, normal)
	stage.pilot.ghosts.transform_unlocked = false
	forms.table.form(&"ohm").unlock = &"ohm"
	forms.locks.on = true
	assert_eq(_word(bot, 1.0).buttons, normal)
	assert_true(sentry.alive())


func test_gauntlet_sample_packs_a_real_release_and_the_wave_observes_it() -> void:
	var sentry: Fighter = _spawn(&"sentry_turret", Vector2(6, 0))
	var forms: GhostForms = stage.pilot.ghosts.forms
	for id: StringName in forms.table.order:
		forms.table.form(id).unlock = id
	forms.apply_locks([&"ohm"])
	var profile: BotProfile = BotProfile.shipped(&"expert")
	profile.form_use = 1.0
	var brain: GauntletBot = GauntletBot.new(view, actions, profile, 24)
	var tally: GhostDeployTally = GhostDeployTally.new()
	tally.begin(stage.tick)
	_drive(brain.sample(stage.tick + 1))
	assert_eq(ghost.phase, GhostDeploy.Phase.AIMING)
	_drive(brain.sample(stage.tick + 1))
	tally.sample(stage)
	var wave: Dictionary = {}
	tally.append_wave(wave)
	var uses: Dictionary = wave.get("deploys", {})
	assert_eq(uses, {&"ohm": 1})
	assert_lt(sentry.hp, sentry.max_hp)
