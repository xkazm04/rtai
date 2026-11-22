extends GutTest

const ROCKET: StringName = &"rocket_launcher"


func test_lethal_wave_ends_with_zero_hp_on_hud_and_rocket_in_death_row() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var run: GauntletRun = GauntletRun.new()
	var data: DataStore = autofree(DataStore.new())
	var session: GauntletSession = GauntletSession.open_street(bus, data, run, InputSource.new())
	var waves: GauntletWaves = GauntletWaves.attach(session, run, GauntletWalker.new(), 1)
	var stage: ArenaStage = session.stage
	stage.arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()
	var rivet: Fighter = stage.arena.rivet
	rivet.hp = 0.25
	rivet.hurt_tick = stage.tick
	stage.arena.gun = GunHand.make(WeaponTable.shipped(), ROCKET, RngRegistry.new(7).stream(&"gun"))
	assert_true(stage.arena.rivet_fire(rivet.pos + Vector2.UP))
	for i: int in 10:
		session.step()
		if waves.done:
			break
	assert_true(waves.done)
	assert_false(run.alive)
	var death: Dictionary = run.to_result()["death"]
	var self_loss: float = run.waves[0].self_damage
	var total_loss: float = run.waves[0].damage_taken
	assert_eq(death, {"wave": 1, "by": String(ROCKET)})
	assert_eq(self_loss, 0.25)
	assert_eq(total_loss, 0.25)
	var hud: GauntletHud = GauntletHud.new()
	hud.session = session
	hud.run = run
	hud.waves = waves
	add_child_autofree(hud)
	hud._process(0.0)
	assert_eq(hud._hp.value, 0.0)
	assert_string_contains(hud._health.text, "0 / 100")
	hud.set_process(false)
	session.close()
