extends GutTest

var rng: RandomNumberGenerator
var arena: CombatArena
var guard: Fighter
var mind: SquadMind


func before_each() -> void:
	rng = RngRegistry.new(12).stream(&"combat")
	arena = CombatArena.new(CombatTuning.shipped(), Events, rng)
	arena.guard_map = GuardRouteMap.new(Rect2(-30, -30, 60, 60), [], null, 0.45)
	arena.squad_ai = ArenaSquad.new(arena.guard_map)
	guard = arena.squad_ai.spawn_member(arena, Vector2.RIGHT)
	@warning_ignore("return_value_discarded")
	arena.squad_ai.assign(arena)
	mind = arena.squad_ai.minds[guard.id]
	mind.agent.arch.danger_m = 0.0  # n31: the trigger at 1 m from Rivet, not the danger run


func test_interrupted_last_round_survives_multiple_ticks_without_a_token() -> void:
	mind.agent.token = false
	guard.burst_left = 1
	guard.burst_gap = 0
	for i: int in 2:
		assert_null(arena.squad_ai.step(guard, arena, rng))
		assert_eq(mind.paused_rounds, 1)
		assert_eq(guard.burst_left, 0)
	mind.agent.token = true
	assert_not_null(arena.squad_ai.step(guard, arena, rng))
	assert_eq(mind.paused_rounds, 0)
	assert_eq(guard.burst_left, 0)
	assert_eq(mind.agent.state, EnemyAgent.State.FIRE)


func test_cooldown_windup_and_inter_round_gap_are_distinct_states() -> void:
	mind.agent.token = true
	guard.cooldown = 1
	assert_null(arena.squad_ai.step(guard, arena, rng))
	assert_eq(mind.agent.state, EnemyAgent.State.RECOVER)
	assert_null(arena.squad_ai.step(guard, arena, rng))
	assert_eq(mind.agent.state, EnemyAgent.State.WINDUP)
	guard.burst_left = 1
	guard.burst_gap = 1
	assert_null(arena.squad_ai.step(guard, arena, rng))
	assert_eq(mind.agent.state, EnemyAgent.State.FIRE)
	assert_eq(guard.burst_left, 1)


func test_one_round_weapon_winds_up_before_firing() -> void:
	arena.tuning.weapon(guard.weapon).burst = 1
	mind.agent.token = true
	guard.cooldown = 0
	assert_null(arena.squad_ai.step(guard, arena, rng))
	assert_eq(guard.burst_left, 1)
	assert_eq(mind.agent.state, EnemyAgent.State.WINDUP)


func test_morale_breaks_only_above_the_fraction_of_enrolled_members_lost() -> void:
	var other: Fighter = arena.squad_ai.spawn_member(arena, Vector2.UP)
	other.hp = 0.0
	mind.agent.arch.morale = 0.5
	arena.step(0)
	assert_false(mind.agent.broke)
	mind.agent.arch.morale = 0.49
	arena.step(1)
	assert_true(mind.agent.broke)
