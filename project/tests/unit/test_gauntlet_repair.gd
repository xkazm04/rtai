extends GutTest

var session: GauntletSession
var waves: GauntletWaves
var arena: GauntletCombat
var view: BotViewArena


func before_each() -> void:
	var run: GauntletRun = GauntletRun.new()
	var pilot: GauntletPilot = GauntletPilot.new()
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	session = GauntletSession.open_street(bus, data, run, pilot)
	waves = GauntletWaves.attach(session, run, pilot, 0)
	waves.manual_picks = true
	arena = session.stage.arena as GauntletCombat
	view = BotViewArena.new(session.stage, session.actions, true)


func after_each() -> void:
	session.close()


func _enter_wounded() -> void:
	arena.rivet.pos.x = session.street.current().end_x() + 0.1
	session.step()
	assert_eq(waves.live_wave_count(), 1)
	for foe: Fighter in arena.hostiles:
		foe.brain_owned = true
	arena.damage(arena.rivet, 80.0, arena.hostiles[0].id, &"baton")


func test_live_wave_blocks_repair_then_clear_restores_the_regen_bonus() -> void:
	_enter_wounded()
	assert_true(session.bonuses.apply(waves.draw.rows[&"stat_regen_25"]))
	var hp: float = arena.rivet.hp
	for i: int in 5 * SimClock.TICK_RATE:
		session.step()
	assert_eq(arena.rivet.hp, hp)
	view.refresh()
	assert_false(view.player().repair_available)
	assert_eq(view.player().street_max_hp, arena.rivet.max_hp)
	for foe: Fighter in arena.hostiles:
		foe.hp = 0.0
	session.step()
	assert_eq(waves.live_wave_count(), 0)
	hp = arena.rivet.hp
	for i: int in SimClock.TICK_RATE:
		session.step()
	assert_almost_eq(arena.rivet.hp - hp, 12.5, 0.00001)
	view.refresh()
	assert_true(view.player().repair_available, "bot rests after the clear")


func test_opt_in_preserves_delayed_repair_and_retreat_inside_the_wave() -> void:
	var rules: DataTable = DataTable.new()
	rules.raw["rivet"] = {"repair_in_wave": true}
	arena.configure_repair(rules)
	_enter_wounded()
	var hp: float = arena.rivet.hp
	for i: int in 3 * SimClock.TICK_RATE - 1:
		session.step()
	assert_eq(arena.rivet.hp, hp)
	for i: int in 2 * SimClock.TICK_RATE + 1:
		session.step()
	assert_almost_eq(arena.rivet.hp - hp, 10.0 * 121 / SimClock.TICK_RATE, 0.00001)
	view.refresh()
	assert_true(view.player().repair_available)


func test_low_hp_bot_engages_without_live_repair_and_waits_after_the_clear() -> void:
	var fixture: BotView = BotView.new()
	var player: BotView.Player = fixture.player()
	player.street_max_hp = 100.0
	player.hp = 10.0
	var target: BotView.Hostile = BotView.Hostile.new()
	target.pos = Vector2(10, 0)
	fixture.hostiles().append(target)
	var brain: GauntletBot = GauntletBot.new(
		fixture, session.actions, BotProfile.shipped(&"expert"), 1
	)
	assert_lt(brain.sample(1).move_x, 0)
	player.repair_available = false
	assert_gt(brain.sample(2).move_x, 0)
	fixture.hostiles().clear()
	player.repair_available = true
	assert_eq(brain.sample(3).move_x, 0)
	player.hp = player.street_max_hp
	assert_gt(brain.sample(4).move_x, 0)
