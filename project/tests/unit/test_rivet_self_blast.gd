extends GutTest

const EPS: float = 0.00001
const FULL: float = 22.0
const ROCKET: StringName = &"rocket_launcher"


class Attribution:
	extends CombatArena
	var killer: int = -1
	var source: StringName
	var cause: StringName

	func damage(
		victim: Fighter,
		amount: float,
		killer_id: int,
		weapon: StringName,
		kind: StringName = &"shot"
	) -> void:
		killer = killer_id
		source = weapon
		cause = kind
		super.damage(victim, amount, killer_id, weapon, kind)


var arena: Attribution
var shot: Shot
var original_conversion: float
var original_k: float
var bus: EventBus


func before_each() -> void:
	bus = autofree(EventBus.new())
	arena = Attribution.new(CombatTuning.shipped(), bus, RngRegistry.new(7).stream(&"combat"))
	arena.rivet.id = 41
	var table: WeaponTable = WeaponTable.shipped()
	arena.gun = GunHand.make(table, ROCKET, RngRegistry.new(7).stream(&"gun"))
	shot = arena.gun.pull(arena.rivet, arena.rivet.pos + Vector2.RIGHT)[0]
	arena.areas = FightAreas.new()
	arena.areas.hp_scale = arena.gun.hp_scale()
	original_conversion = RivetSelfBlast.rivet_hp_per_table_hp
	original_k = RivetSelfBlast.self_k


func after_each() -> void:
	RivetSelfBlast.self_k = original_k
	RivetSelfBlast.rivet_hp_per_table_hp = original_conversion


func test_table_rocket_uses_separate_conversions_for_rivet_and_hostiles() -> void:
	assert_eq(original_k, 1.0)
	assert_eq(original_conversion, 0.1)
	var foe: Fighter = arena.spawn_guard(arena.rivet.pos)
	foe.pos = arena.rivet.pos
	foe.hp = 10.0
	RivetSelfBlast.self_k = 0.4
	arena.areas._splash(arena, shot, null, foe.pos)
	_land(arena, foe.pos)
	assert_almost_eq(10.0 - foe.hp, 2.2, EPS)
	assert_almost_eq(arena.rivet.max_hp - arena.rivet.hp, FULL * 0.4, EPS)


func test_grazing_the_body_falls_to_zero_at_the_outer_edge() -> void:
	for fraction: float in [0.0, 0.5, 0.999, 1.0, 1.1]:
		var hp: float = arena.rivet.hp
		var offset: float = arena.rivet.radius_m + shot.spec.splash_radius_m * fraction
		_land(arena, arena.rivet.pos + Vector2.LEFT * offset)
		assert_almost_eq(hp - arena.rivet.hp, FULL * maxf(1.0 - fraction, 0.0), EPS)


func test_point_blank_self_damage_for_each_blast_weapon() -> void:
	var point_blank: Dictionary[StringName, float] = {
		&"rocket_launcher": 22.0, &"molotov": 4.0, &"homing_shard": 3.0, &"mini_nuke": 150.0
	}
	var table: WeaponTable = WeaponTable.shipped()
	arena.rivet.max_hp = 200.0
	for weapon: StringName in point_blank:
		shot.spec = table.weapon(weapon)
		arena.rivet.hp = arena.rivet.max_hp
		_land(arena, arena.rivet.pos)
		assert_almost_eq(arena.rivet.max_hp - arena.rivet.hp, point_blank[weapon], EPS, weapon)


func test_rocket_ten_hp_and_mini_nuke_lethal_distances() -> void:
	var body_edge: Vector2 = arena.rivet.pos + Vector2.RIGHT * arena.rivet.radius_m
	_land(arena, body_edge + Vector2.RIGHT * (21.0 / 11.0))
	assert_almost_eq(arena.rivet.hp, 90.0, EPS)
	shot.spec = WeaponTable.shipped().weapon(&"mini_nuke")
	arena.rivet.hp = arena.rivet.max_hp
	_land(arena, body_edge + Vector2.RIGHT * 4.01)
	assert_gt(arena.rivet.hp, 0.0)
	arena.rivet.hp = arena.rivet.max_hp
	_land(arena, body_edge + Vector2.RIGHT * 4.0)
	assert_false(arena.rivet.alive())


func test_wall_stops_own_blast_between_impact_and_rivet() -> void:
	arena.walls = ArenaWalls.new()
	arena.walls.boxes.append(Rect2(0.9, -2.0, 0.3, 4.0))
	arena.walls.kinds.append("wall_high")
	_land(arena, Vector2(2, 0))
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_tonnage_plates_reduce_own_blast() -> void:
	var stage: CollectCallStage = CollectCallStage.new(StageLayout.shipped())
	stage.arena = arena
	var hauler: HaulerStage = HaulerStage.shipped()
	@warning_ignore("return_value_discarded")
	hauler.drive(stage, true, false, Vector2.ZERO)
	var k: float = hauler.attacks.num(&"tonnage", &"armor_k")
	assert_eq(arena.rivet.damage_k, k)
	assert_lt(k, 1.0)
	_land(arena, arena.rivet.pos)
	assert_almost_eq(arena.rivet.max_hp - arena.rivet.hp, FULL * k, EPS)


func test_zero_rivet_hp_per_table_hp_gives_no_damage() -> void:
	RivetSelfBlast.rivet_hp_per_table_hp = 0.0
	_land(arena, arena.rivet.pos)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func test_zero_multiplier_gives_no_hit() -> void:
	RivetSelfBlast.self_k = 0.0
	watch_signals(arena)
	_land(arena, arena.rivet.pos)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)
	assert_signal_not_emitted(arena, "struck")


func test_guard_up_takes_the_blast_and_roll_iframes_avoid_it() -> void:
	arena.guard = PlayerGuard.new()
	arena.guard.step(true, true)
	assert_true(arena.guard.up())
	_land(arena, arena.rivet.pos)
	assert_almost_eq(arena.rivet.max_hp - arena.rivet.hp, FULL, EPS)
	assert_eq(arena.guard.meter(), 1.0)
	arena.rivet.exposed = false
	var hp: float = arena.rivet.hp
	_land(arena, arena.rivet.pos)
	assert_eq(arena.rivet.hp, hp)


func test_self_kill_names_rivet_and_the_fired_weapon() -> void:
	arena.rivet.hp = 0.25
	watch_signals(arena)
	_land(arena, arena.rivet.pos)
	assert_false(arena.rivet.alive())
	assert_eq(arena.killer, arena.rivet.id)
	assert_eq(arena.source, ROCKET)
	assert_eq(arena.cause, &"blown")
	assert_signal_emitted_with_parameters(
		arena, "struck", [arena.rivet, Vector2.ZERO, true, ROCKET]
	)


func test_wave_damage_excludes_approach_and_intermission_and_counts_actual_loss() -> void:
	var run: GauntletRun = GauntletRun.new()
	var data: DataStore = autofree(DataStore.new())
	var session: GauntletSession = GauntletSession.open_street(bus, data, run, InputSource.new())
	var stage: ArenaStage = session.stage
	var stats: GauntletWaveStats = GauntletWaveStats.new()
	var r: Fighter = stage.arena.rivet
	_land(stage.arena, r.pos)
	run.begin_wave({})
	stats.begin(stage)
	for i: int in 2:
		_land(stage.arena, r.pos)
	stats.finish(stage, run.waves[-1])
	var first_loss: float = run.waves[0].self_damage
	assert_almost_eq(first_loss, 2.0 * FULL, EPS)
	_land(stage.arena, r.pos)
	run.begin_wave({})
	stats.begin(stage)
	stats.finish(stage, run.waves[-1])
	var empty_loss: float = run.waves[-1].self_damage
	assert_eq(empty_loss, 0.0)
	run.begin_wave({})
	stats.begin(stage)
	r.hp = 0.375
	_land(stage.arena, r.pos)
	stats.finish(stage, run.waves[-1])
	var last_loss: float = run.waves[-1].self_damage
	assert_eq(last_loss, 0.375)
	session.close()


func test_non_player_round_cannot_deal_self_damage() -> void:
	shot.from_rivet = false
	_land(arena, arena.rivet.pos)
	assert_eq(arena.rivet.hp, arena.rivet.max_hp)


func _land(target: CombatArena, at: Vector2) -> void:
	RivetSelfBlast.land(target, shot, at)
