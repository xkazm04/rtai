extends GutTest

var stage: ArenaStage
var pilot: StagePilot
var wave: GauntletWaveStats


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	stage = ArenaStage.new(ArenaPlan.shipped(), ArenaStations.new())
	stage.setup(World.build_context(bus, data, 24))
	pilot = StagePilot.new(PlayerActions.shipped(false))
	stage.pilot = pilot
	stage.arena.rivet.pos = Vector2.ZERO
	wave = GauntletWaveStats.new()
	wave.begin(stage)


func _tick(held: bool = false) -> void:
	var bits: int = PlayerCommand.pack_aim(Vector2.RIGHT, pilot.actions, 6.0)
	if held:
		bits |= 1 << pilot.actions.bit(&"ghost_deploy")
	stage.tick += 1
	pilot.drive(stage, TickInput.new(bits))
	wave.sample(stage)


func _finish(stats: GauntletWaveStats) -> Dictionary:
	var row: Dictionary = {}
	stats.finish(stage, row)
	return row


func test_unobserved_effects_are_absent_and_a_measured_miss_has_zero_kills() -> void:
	_tick()
	var empty: Dictionary = _finish(wave)
	for key: String in ["deploys", "deploy_kills", "deploy_stun_s"]:
		assert_false(empty.has(key))
	_tick(true)
	_tick()
	var miss: Dictionary = _finish(wave)
	var deploys: Dictionary = miss["deploys"]
	assert_eq(deploys, {&"tonnage": 1})
	var deploy_kills: Dictionary = miss["deploy_kills"]
	assert_eq(deploy_kills, {&"tonnage": 0})
	assert_false(miss.has("deploy_stun_s"))


func test_overlapping_waves_count_only_their_own_live_machine_ticks() -> void:
	var arena: CombatArena = stage.arena
	var human: Fighter = arena.spawn_guard(Vector2(5, 0))
	human.pos = Vector2(5, 0)
	var gun: Fighter = arena.squad_ai.spawn_member(arena, Vector2(6, 1), &"sentry_turret")
	gun.pos = Vector2(6, 1)
	pilot.ghosts.forms.selected = OhmStage.GHOST
	_tick(true)
	_tick()
	wave.sample(stage)
	var later: GauntletWaveStats = GauntletWaveStats.new()
	later.begin(stage)
	_tick()
	later.sample(stage)
	arena.damage(gun, 9999.0, arena.rivet.id, &"gloria")
	_tick()
	later.sample(stage)
	var row: Dictionary = _finish(wave)
	var deploys: Dictionary = row["deploys"]
	assert_eq(deploys, {&"ohm": 1})
	var deploy_kills: Dictionary = row["deploy_kills"]
	assert_eq(deploy_kills, {&"ohm": 1})
	var measured_s: float = row["deploy_stun_s"]["ohm"]
	assert_almost_eq(measured_s, 2.0 * SimClock.TICK_DT, 0.00001)
	var overlapping: Dictionary = _finish(later)
	assert_false(overlapping.has("deploys"))
	assert_false(overlapping.has("deploy_kills"))
	var overlap_s: float = overlapping["deploy_stun_s"]["ohm"]
	assert_almost_eq(overlap_s, SimClock.TICK_DT, 0.00001)


func test_replaced_or_expired_machine_stuns_stop_counting() -> void:
	var arena: CombatArena = stage.arena
	var first: Fighter = arena.squad_ai.spawn_member(arena, Vector2(6, 1), &"sentry_turret")
	var second: Fighter = arena.squad_ai.spawn_member(arena, Vector2(6, -1), &"shield_robot")
	first.pos = Vector2(6, 1)
	second.pos = Vector2(6, -1)
	pilot.ghosts.forms.selected = OhmStage.GHOST
	_tick(true)
	_tick()
	var strike: GhostDeployStrike = pilot.ghosts.deploy.strike
	assert_eq(strike.stunned_count(arena, stage.tick), 2)
	var until: int = arena.squad_ai.mind_for(first).stun_until
	arena.squad_ai.mind_for(second).stun_until += 1
	assert_eq(strike.stunned_count(arena, stage.tick), 1)
	assert_eq(strike.stunned_count(arena, until), 0)


func test_ohm_wounding_only_humans_records_no_short_circuit() -> void:
	var arena: CombatArena = stage.arena
	var human: Fighter = arena.spawn_guard(Vector2(6, 0))
	human.pos = Vector2(6, 0)
	human.hp = 10.0
	pilot.ghosts.forms.selected = OhmStage.GHOST
	_tick(true)
	_tick()
	var row: Dictionary = {}
	arena.move_tally.append_wave(row)
	assert_eq(10.0 - human.hp, pilot.ohm.num(&"bolt_damage"))
	assert_false(row.has("moves"))
