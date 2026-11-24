extends GutTest

var stage: ArenaStage
var pilot: StagePilot
var forms: GhostForms


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.new())
	stage.setup(World.build_context(bus, data, 24))
	pilot = StagePilot.new(PlayerActions.shipped(true))
	stage.pilot = pilot
	forms = pilot.ghosts.forms
	stage.arena.rivet.pos = Vector2.ZERO


func _drive(bits: int = 0) -> void:
	stage.tick += 1
	pilot.drive(stage, TickInput.new(bits))


func _press(action: StringName) -> void:
	_drive(1 << pilot.actions.bit(action))
	_drive()


func test_number_release_credits_stunned_targets_once_even_if_a_wave_samples_twice() -> void:
	var arena: CombatArena = stage.arena
	var foe: Fighter = arena.squad_ai.spawn_member(arena, Vector2(6, 0), &"sentry_turret")
	foe.pos = Vector2(6, 0)
	var guard: Fighter = arena.spawn_guard(foe.pos)
	guard.hp = 1.0
	guard.pos = foe.pos
	var wave: GhostDeployTally = GhostDeployTally.new()
	wave.begin(stage.tick)
	var aim: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	_drive(aim | (1 << pilot.actions.bit(&"ghost_deploy_3")))
	_drive(aim)
	wave.sample(stage)
	wave.sample(stage)
	assert_eq(wave.stuns, {&"ohm": 1})
	assert_false(guard.alive())
	assert_eq(forms.bond.value(&"ohm"), forms.table.per_kill + forms.table.per_stun)
	_drive()
	wave.sample(stage)
	assert_eq(forms.bond.value(&"ohm"), forms.table.per_kill + forms.table.per_stun)


func test_t_needs_a_taken_offer_and_uses_the_single_mastered_form() -> void:
	forms.bond.record(&"ohm", 30, 0)
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.transforms, 0)
	assert_true(forms.bond.master(&"ohm"))
	forms.bond.record(&"kerf", 3, 0)
	_press(&"power_hauler")
	assert_eq(forms.to_id, &"ohm")
	assert_gt(pilot.ghosts.powers.madness, 0.0)
	for tick: int in forms.table.form(&"ohm").enter_ticks:
		_drive()
	_press(&"power_gearbox")
	assert_true(pilot.ghosts.settled_in(&"ohm"))
	_press(&"power_hauler")
	assert_eq(forms.phase, GhostForms.EXITING)


func test_t_with_two_mastered_uses_the_last_deployed_and_g_skips_unmastered() -> void:
	for id: StringName in [&"kerf", &"tonnage"]:
		forms.bond.record(id, 30, 0)
		assert_true(forms.bond.master(id))
	forms.bond.record(&"kerf", 0, 0)
	_press(&"power_hauler")
	assert_eq(forms.to_id, &"kerf")
	for tick: int in forms.table.form(&"kerf").enter_ticks:
		_drive()
	_press(&"power_gearbox")
	assert_eq(forms.to_id, &"tonnage")


func test_disabled_keeps_the_selected_form_override_and_original_deploy() -> void:
	forms.bond.enabled = false
	forms.selected = &"dent"
	_press(&"power_hauler")
	assert_eq(pilot.ghosts.transforms, 0)
	_press(&"ghost_deploy_3")
	assert_eq(pilot.ghosts.deploy.form, &"ohm")
	for tick: int in pilot.ghosts.deploy.ticks_left:
		_drive()
	pilot.ghosts.transform_unlocked = true
	_press(&"power_hauler")
	assert_eq(forms.to_id, &"dent")
