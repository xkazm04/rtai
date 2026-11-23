extends GutTest

const HUMANS: Array[StringName] = [
	&"", &"patrol_cop", &"riot_cop", &"swat", &"contractor", &"rocket_trooper"
]
const ROBOTS: Array[StringName] = [
	&"robot_thug", &"robot_gunner", &"shield_robot", &"sentry_turret", &"war_machine"
]

var arena: CombatArena
var hands: PlayerMelee


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(51).stream(&"combat"))
	hands = PlayerMelee.new()


func _foe(id: StringName) -> Fighter:
	var target: Fighter = arena.spawn_guard(Vector2.RIGHT)
	target.pos = Vector2.RIGHT
	target.archetype = id
	target.facing = Vector2.RIGHT
	target.hp = 51.0
	target.max_hp = target.hp
	return target


func _swing() -> void:
	for tick: int in hands.combo.table.hits[0].length():
		arena.tick += 1
		@warning_ignore("return_value_discarded")
		hands.step(arena, tick == 0, Vector2.RIGHT)


func test_one_click_finishes_each_exposed_human_even_through_damage_reduction() -> void:
	for id: StringName in HUMANS:
		_foe(id).damage_k = 0.1
	_swing()
	assert_eq(hands.starts, 1)
	assert_eq(arena.kills, HUMANS.size())


func test_named_humans_and_bosses_take_the_rakes_normal_damage() -> void:
	var mulroney: Fighter = _foe(&"sergeant_mulroney")
	var warden: Fighter = _foe(&"appliance_warden")
	var named: Fighter = _foe(&"patrol_cop")
	named.set_meta(MeleeLethal.NAMED, true)
	var boss: Fighter = _foe(&"swat")
	arena.boss = boss
	var typed_boss: Fighter = _foe(&"contractor")
	typed_boss.kind = Fighter.Kind.BOSS
	var owned: Fighter = _foe(&"riot_cop")
	owned.brain_owned = true
	var row_boss: Fighter = _foe(&"")
	row_boss.body_class = &"boss"
	_swing()
	for f: Fighter in [mulroney, warden, named, boss, typed_boss, owned, row_boss]:
		assert_eq(f.hp, f.max_hp - hands.combo.table.hits[0].damage, String(f.archetype))


func test_front_shield_shoves_and_opens_for_forty_ticks() -> void:
	var riot: Fighter = _foe(&"riot_cop")
	riot.facing = Vector2.LEFT
	_swing()
	assert_eq(riot.hp, riot.max_hp)
	assert_gt(riot.pos.x, 1.0)
	var contact: int = hands.last_land_tick
	assert_true(MeleeLethal.shield_open(riot, contact + 39))
	assert_false(MeleeLethal.shield_open(riot, contact + 40))
	_swing()
	assert_eq(hands.starts, 2)
	assert_false(riot.alive())


func test_each_robot_takes_only_the_rakes_normal_damage() -> void:
	for id: StringName in ROBOTS:
		@warning_ignore("return_value_discarded")
		_foe(id)
	_foe(&"").machine = true
	_foe(&"").body_class = &"robot"
	_swing()
	for target: Fighter in arena.hostiles:
		assert_eq(
			target.hp, target.max_hp - hands.combo.table.hits[0].damage, String(target.archetype)
		)


func test_pit_uses_the_same_exemptions_and_front_block() -> void:
	var pit: EnemyPit = EnemyPit.new(EnemyRoster.shipped(EnemyRoster.TABLE, true), null)
	var combo: MeleeCombo = hands.combo
	combo.press()
	for id: StringName in [&"contractor", &"sergeant_mulroney", &"appliance_warden", &"robot_thug"]:
		var agent: EnemyAgent = pit.spawn(id, Vector2.RIGHT)
		agent.hp = 50.0
		agent.facing = Vector2.RIGHT
		pit.hurt(agent, 1.0, Vector2.RIGHT, combo)
		var expected: float = 49.0
		if id == &"contractor":
			expected = 0.0
		assert_eq(agent.hp, expected, String(id))
	var riot: EnemyAgent = pit.spawn(&"riot_cop", Vector2.RIGHT)
	riot.facing = Vector2.LEFT
	var hp: float = riot.hp
	pit.hurt(riot, 1.0, Vector2.RIGHT, combo)
	assert_eq(riot.hp, hp)
	assert_gt(riot.pos.x, 1.0)
	pit.tick += combo.table.hits[0].length()
	pit.hurt(riot, 1.0, Vector2.RIGHT, combo)
	assert_false(riot.alive())


func test_pit_boss_body_flag_takes_precedence_over_the_human_id() -> void:
	var pit: EnemyPit = EnemyPit.new(EnemyRoster.shipped(EnemyRoster.TABLE, true), null)
	var target: EnemyAgent = pit.spawn(&"swat", Vector2.RIGHT)
	target.arch.body = &"boss"
	target.hp = 50.0
	target.facing = Vector2.RIGHT
	hands.combo.press()
	pit.hurt(target, 1.0, Vector2.RIGHT, hands.combo)
	assert_eq(target.hp, 49.0)
