extends GutTest
## n31 foes b4a: the waiting probe's engaged rule (res://dev/foes_n31/waiting_engaged.gd) on a
## hand-made tick fixture: a foe firing every burst + cooldown never scores idle.

const Engaged = preload("res://dev/foes_n31/waiting_engaged.gd")

## A pistol-like weapon: 1 round, 60-tick cooldown -> window 66 ticks.
const WINDOW: int = 66


func test_window_is_burst_plus_cooldown_plus_slack() -> void:
	assert_eq(Engaged.window_ticks(1, 0, 60), 60 + Engaged.SLACK_TICKS)
	# 3 rounds, 6 ticks apart (5-tick gaps), then a 66-tick cooldown: 12 + 66 + 6.
	assert_eq(Engaged.window_ticks(3, 5, 66), 84)
	assert_eq(Engaged.window_ticks(0, 9, 10), 10 + Engaged.SLACK_TICKS)


func test_fixture_ticks() -> void:
	# tick, last_shot, busy, settling -> engaged
	var rows: Array[Array] = [
		[5, -1, false, false, false],  # never fired, standing: idle
		[5, -1, true, false, true],  # winding up
		[5, -1, false, true, true],  # FoeGait settle window
		[100, 100, true, false, true],  # the round itself
		[166, 100, false, false, true],  # last tick of the window
		[167, 100, false, false, false],  # one past it: idle again
	]
	for r: Array in rows:
		var tick: int = r[0]
		var last_shot: int = r[1]
		var busy: bool = r[2]
		var settle: bool = r[3]
		var want: bool = r[4]
		var got: bool = Engaged.engaged(tick, last_shot, WINDOW, busy, settle)
		assert_eq(got, want, "tick %d last_shot %d" % [tick, last_shot])


func test_non_stop_shooter_is_never_idle_but_strict_says_mostly() -> void:
	var w: int = Engaged.window_ticks(1, 0, 60)
	var last: int = -1
	var loose: int = 0
	var strict: int = 0
	for tick: int in range(600):
		var fired: bool = tick % 61 == 0
		last = tick if fired else last
		loose += int(not Engaged.engaged(tick, last, w, fired, false))
		strict += int(not fired)
	assert_eq(loose, 0)
	assert_gt(strict, 580)


func test_pressing_needs_three_and_a_third() -> void:
	assert_false(Engaged.pressing(2, 2), "fewer than 3 ranged alive never presses")
	assert_false(Engaged.pressing(3, 2))
	assert_true(Engaged.pressing(3, 3))
	assert_true(Engaged.pressing(9, 3))
	assert_false(Engaged.pressing(10, 3), "ceil(10 / 3) = 4")
	assert_true(Engaged.pressing(10, 4))


func test_explicit_spawn_window_reads_its_enemies_json_weapon() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped()
	var arch: EnemyRoster.Archetype = roster.archetype(&"rocket_trooper")
	assert_true(arch.explicit_spawn)
	var w: EnemyWeapon = arch.weapon
	var want: int = Engaged.window_ticks(w.burst, w.burst_gap_ticks, w.cooldown_ticks)
	assert_eq(Engaged.foe_window(arch, Fighter.new(), CombatTuning.shipped(), null), want)
	assert_eq(want, w.cooldown_ticks + Engaged.SLACK_TICKS, "the rocket fires one round")


func test_own_gun_foe_window_reads_its_enemies_json_weapon() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped()
	var arch: EnemyRoster.Archetype = roster.archetype(&"patrol_cop")
	var h: Fighter = Fighter.new()
	h.weapon = arch.production_weapon
	var tuning: CombatTuning = CombatTuning.shipped()
	var rifle: int = Engaged.foe_window(arch, h, tuning, null)
	roster.own_weapons = true
	var w: EnemyWeapon = arch.weapon
	var want: int = Engaged.window_ticks(w.burst, w.burst_gap_ticks, w.cooldown_ticks)
	assert_eq(Engaged.foe_window(arch, h, tuning, roster), want)
	assert_ne(want, rifle, "the own gun cycle differs from the rifle window")
