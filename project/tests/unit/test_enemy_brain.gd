extends GutTest
## Synthetic combatants keep these decisions independent of shipped balance tables.

const S := EnemyAgent.State

var _pit: EnemyPit
var _e: EnemyAgent
var _a: EnemyRoster.Archetype
var _w: EnemyRoster.Weapon


func before_each() -> void:
	var roster: EnemyRoster = EnemyRoster.new()
	roster.sight_m = 50.0
	roster.hearing_m = 10.0
	roster.aim_lock_ticks = 2
	roster.aim_lead = 0.5
	roster.recover_ticks = 4
	roster.panic_ticks = 6
	_pit = EnemyPit.new(roster, RngRegistry.new(1).stream(&"enemy_ai"))
	_w = EnemyRoster.Weapon.new()
	_w.burst = 2
	_w.burst_gap_ticks = 2
	_w.cooldown_ticks = 7
	_w.reach_m = 2.0
	_w.lunge_m = 3.0
	_w.lunge_mps = 12.0
	_a = EnemyRoster.Archetype.new()
	_a.weapon = _w
	_a.morale = 1.0
	_a.attack_m = 8.0
	_a.reaction_ticks = 3
	_a.telegraph_ticks = 5
	_a.accel_mps2 = 1000.0
	_e = EnemyAgent.make(2, _a, Vector2.ZERO)
	_pit.rivet_pos = Vector2(6.0, 0.0)
	_pit.agents = [_e]


func _step(state: EnemyAgent.State) -> void:
	EnemyBrain.step(_e, _pit)
	assert_eq(_e.state, state)


func test_patrol_walks_to_goal_until_sight_starts_reaction() -> void:
	_e.facing = Vector2.LEFT
	_e.goal = Vector2(0.0, 4.0)
	_step(S.PATROL)
	assert_between(_e.vel.length(), 0.01, _a.speed_mps - 0.01, "patrols walk")
	_e.facing = Vector2.RIGHT
	_e.vel = Vector2.ZERO
	_step(S.ALERT)
	assert_eq(_e.last_seen, _pit.rivet_pos)
	assert_eq(_e.timer, _a.reaction_ticks - 1)
	_step(S.ALERT)
	_step(S.ENGAGE)


func test_only_current_audible_noise_alerts_a_blind_patrol() -> void:
	_e.facing = Vector2.LEFT
	_pit.noise_pos = Vector2(0.0, _pit.roster.hearing_m)
	_pit.noise_tick = _pit.tick - 1
	_step(S.PATROL)
	_pit.noise_tick = _pit.tick
	_step(S.ALERT)
	assert_eq(_e.last_seen, _pit.noise_pos)


func test_timed_states_wait_until_expiry_then_return_the_token() -> void:
	for state: EnemyAgent.State in [S.DEAD, S.DOWN, S.STAGGER, S.RECOVER, S.PANIC]:
		_e.pos = Vector2.ZERO
		_e.vel = Vector2.RIGHT
		_e.enter(state, 2)
		_e.token = true
		_e.cooldown = 4
		_step(state)
		assert_true(_e.token)
		if state == S.DEAD:
			assert_eq(_e.timer, 2)
			assert_eq(_e.cooldown, 4)
			continue
		if state == S.DOWN or state == S.STAGGER:
			assert_eq(_e.pos, Vector2.ZERO, "incapacitation suppresses the motor")
		elif state == S.PANIC:
			assert_lt(_e.pos.x, 0.0, "panic flees Rivet")
		else:
			assert_eq(_e.vel, Vector2.ZERO, "recovery stops movement")
		_step(S.ENGAGE)
		assert_false(_e.token)


func test_attacks_require_token_cooldown_sight_and_inclusive_weapon_range() -> void:
	for melee: bool in [false, true]:
		_w.melee = melee
		var reach: float = _w.reach_m + _w.lunge_m if melee else _a.attack_m
		for gate: String in ["ready", "token", "cooldown", "sight", "range"]:
			_e.pos = Vector2.ZERO
			_e.enter(S.ENGAGE)
			_e.token = gate != "token"
			_e.cooldown = 2 if gate == "cooldown" else 1
			_pit.rivet_pos = Vector2(reach + (1.0 if gate == "range" else 0.0), 0.0)
			_pit.roster.sight_m = 1.0 if gate == "sight" else 50.0
			_step(S.WINDUP if gate == "ready" else S.ENGAGE)
			if gate == "ready":
				assert_eq(_e.timer, _a.telegraph_ticks)
	assert_eq(_pit.stats["tells"], 2.0)
	assert_eq(_e.cooldown, 0)


func test_morale_breaks_only_above_threshold_once_and_before_attack() -> void:
	_a.morale = 0.5
	var fallen: EnemyAgent = EnemyAgent.make(3, _a, Vector2(-10.0, 0.0))
	fallen.enter(S.DEAD)
	_pit.agents.append(fallen)
	_e.enter(S.ENGAGE)
	EnemyBrain.step(_e, _pit)
	assert_false(_e.broke, "equal losses do not break morale")
	_a.morale = 0.4
	_e.token = true
	_step(S.PANIC)
	assert_eq(_e.timer, _pit.roster.panic_ticks)
	assert_false(_e.token)
	_e.enter(S.ENGAGE)
	EnemyBrain.step(_e, _pit)
	assert_ne(_e.state, S.PANIC, "regrouped survivors do not panic forever")


func test_strafe_reverses_on_schedule_except_ranged_flankers() -> void:
	for melee: bool in [false, true]:
		for flank: bool in [false, true]:
			_w.melee = melee
			_a.flanks = flank
			_e.enter(S.ENGAGE)
			_e.strafe_sign = 1.0
			_e.state_ticks = EnemyBrain.STRAFE_FLIP_TICKS - 3
			EnemyBrain.step(_e, _pit)
			assert_eq(_e.strafe_sign, 1.0)
			EnemyBrain.step(_e, _pit)
			assert_eq(_e.strafe_sign, 1.0 if flank and not melee else -1.0)


func test_reposition_prefers_cover_and_falls_back_to_flanking() -> void:
	_a.uses_cover = true
	_a.flanks = true
	_e.sees = true
	_pit.cover = [Rect2(2.0, -1.0, 1.0, 2.0)]
	var desired: Vector2 = EnemyBrain._reposition(_e, _pit)
	assert_eq(_e.state, S.COVER)
	assert_true(EnemySenses.blocked(_e.goal, _pit.rivet_pos, _pit.cover))
	_pit.cover.clear()
	desired = EnemyBrain._reposition(_e, _pit)
	assert_eq(_e.state, S.FLANK)
	assert_gt(desired.length(), 0.0)
	_e.token = true
	desired = EnemyBrain._reposition(_e, _pit)
	assert_eq(_e.state, S.ENGAGE, "a token holder keeps its firing position")


func test_windup_tracks_then_locks_and_fires_a_spaced_burst_before_recovery() -> void:
	_e.enter(S.WINDUP, _pit.roster.aim_lock_ticks + 2)
	_pit.rivet_vel = Vector2(0.0, 3.0)
	var travel: float = _pit.roster.aim_lock_ticks * SimClock.TICK_DT + 6.0 / _w.speed_mps
	var expected: Vector2 = (Vector2(6.0, 0.0) + _pit.rivet_vel * travel * 0.5).normalized()
	EnemyBrain.step(_e, _pit)
	assert_almost_eq(_e.aim, expected, Vector2.ONE * 0.0001)
	_pit.rivet_pos = Vector2(0.0, 6.0)
	EnemyBrain.step(_e, _pit)
	assert_almost_eq(_e.aim, expected, Vector2.ONE * 0.0001, "locked at the boundary")
	for tick: int in _pit.roster.aim_lock_ticks:
		EnemyBrain.step(_e, _pit)
	assert_eq(_e.burst_left, _w.burst)
	assert_eq(_pit.stats["shots"], 0.0, "the tell completes before the shot")
	EnemyBrain.step(_e, _pit)
	assert_eq(_pit.stats["shots"], 1.0)
	for tick: int in _w.burst_gap_ticks:
		EnemyBrain.step(_e, _pit)
		assert_eq(_pit.stats["shots"], 1.0)
	EnemyBrain.step(_e, _pit)
	assert_eq(_pit.stats["shots"], float(_w.burst))
	assert_eq(_e.state, S.RECOVER)
	assert_eq(_e.timer, _pit.roster.recover_ticks)
	assert_eq(_e.cooldown, _w.cooldown_ticks)


func test_melee_lunges_along_locked_aim_before_swinging() -> void:
	_w.melee = true
	_w.burst = 1
	_e.enter(S.WINDUP, 1)
	_e.aim = Vector2.RIGHT
	EnemyBrain.step(_e, _pit)
	var ticks: int = ceili(_w.lunge_m / (_w.lunge_mps * SimClock.TICK_DT))
	assert_eq(_e.timer, ticks, "lunge distance is capped")
	_pit.rivet_pos = Vector2(0.0, 6.0)
	for tick: int in ticks:
		EnemyBrain.step(_e, _pit)
		assert_eq(_e.vel, Vector2.RIGHT * _w.lunge_mps)
		assert_eq(_pit.stats["swings"], 0.0)
	EnemyBrain.step(_e, _pit)
	assert_eq(_pit.stats["swings"], 1.0)
	assert_eq(_e.state, S.RECOVER)
