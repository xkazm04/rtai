extends GutTest

const HUMANS: Array[StringName] = [
	&"patrol_cop", &"riot_cop", &"swat", &"contractor", &"rocket_trooper"
]
const WEAPONS: Array[StringName] = [&"katana", &"electro_baton", &"plasma_sword", &"chainsaw"]

var arena: CombatArena


func before_each() -> void:
	var bus: EventBus = autofree(EventBus.new())
	arena = CombatArena.new(CombatTuning.shipped(), bus, RngRegistry.new(51).stream(&"combat"))


func _fighter(id: StringName, facing: Vector2 = Vector2.LEFT) -> Fighter:
	var f: Fighter = arena.spawn_guard(Vector2.ZERO)
	f.pos = Vector2.RIGHT
	f.facing = facing
	f.archetype = id
	f.hp = 91.25
	f.max_hp = f.hp
	return f


func _click(m: PlayerMelee, count: int = 60) -> void:
	for i: int in count:
		arena.tick += 1
		@warning_ignore("return_value_discarded")
		m.step(arena, i == 0, Vector2.RIGHT)


func test_every_weapon_and_bearing_against_each_wave_human() -> void:
	for weapon: StringName in WEAPONS:
		var table: MeleeTable = MeleeTable.weapon(weapon)
		assert_true(table.kills_human)
		for facing: Vector2 in [Vector2.LEFT, Vector2.UP, Vector2.RIGHT]:
			arena.hostiles.clear()
			var m: PlayerMelee = PlayerMelee.new(table)
			for id: StringName in HUMANS:
				var f: Fighter = _fighter(id, facing)
				f.damage_k = 0.01
			_click(m)
			assert_eq(m.starts, 1)
			for f: Fighter in arena.hostiles:
				var blocked: bool = (
					weapon == &"katana" and f.archetype == &"riot_cop" and facing == Vector2.LEFT
				)
				assert_eq(f.alive(), blocked, "%s %s %s" % [weapon, f.archetype, facing])


func test_claw_boss_owned_mulroney_machines_and_covered_targets() -> void:
	var claw: MeleeTable = MeleeTable.shipped()
	assert_false(claw.kills_human)
	var guard: Fighter = _fighter(&"patrol_cop")
	_click(PlayerMelee.new(claw))
	assert_eq(guard.hp, guard.max_hp - claw.hits[0].damage)
	arena.hostiles.clear()
	var covered: Fighter = _fighter(&"swat")
	covered.exposed = false
	var exempt: Array[Fighter] = [
		_fighter(&"sergeant_mulroney"),
		_fighter(&"robot_thug"),
		_fighter(&"shield_robot"),
		_fighter(&"swat"),
		_fighter(&"swat"),
		_fighter(&""),
		_fighter(&""),
		_fighter(&"")
	]
	exempt[3].brain_owned = true
	exempt[4].machine = true
	exempt[5].body_class = &"robot"
	exempt[6].kind = Fighter.Kind.BOSS
	arena.boss = exempt[7]
	var blade: MeleeTable = MeleeTable.weapon(&"katana")
	_click(PlayerMelee.new(blade))
	for f: Fighter in exempt:
		assert_eq(f.hp, f.max_hp - blade.hits[0].damage)
	assert_eq(covered.hp, covered.max_hp)


func test_riot_block_shoves_and_opens_only_until_the_break_expires() -> void:
	var table: MeleeTable = MeleeTable.weapon(&"katana")
	var m: PlayerMelee = PlayerMelee.new(table)
	var riot: Fighter = _fighter(&"riot_cop")
	var signals: Array[StringName] = []
	@warning_ignore("return_value_discarded")
	arena.wounded.connect(func(_f: Fighter, w: StringName) -> void: signals.append(w))
	_click(m, table.hits[0].length())
	assert_eq(riot.hp, riot.max_hp)
	assert_gt(riot.pos.x, 1.0)
	assert_eq(signals, [MeleeLethal.BLOCK])
	_click(m)
	assert_false(riot.alive())
	riot = _fighter(&"riot_cop")
	_click(m, table.shield_break_ticks)
	_click(m, table.hits[0].windup)
	assert_eq(riot.hp, riot.max_hp, "the front recovers exactly on the expiry tick")


func test_three_in_plasma_sweep_die_once_and_rear_survives() -> void:
	for degrees: int in [-100, 0, 100, 180]:
		var f: Fighter = _fighter(&"swat")
		f.pos = Vector2.RIGHT.rotated(deg_to_rad(degrees)) * 1.5
	var table: MeleeTable = MeleeTable.weapon(&"plasma_sword")
	_click(PlayerMelee.new(table))
	assert_eq(arena.kills, 3)
	assert_true(arena.hostiles[-1].alive())


func test_saw_holds_its_first_contact_until_the_teeth_pull_free() -> void:
	var m: PlayerMelee = PlayerMelee.new(MeleeTable.weapon(&"chainsaw"))
	var hit: MeleeHit = m.combo.table.hits[0]
	var weak: Fighter = _fighter(&"patrol_cop")
	weak.hp = 0.01
	var heavy: Fighter = _fighter(&"riot_cop")
	_click(m, hit.windup)
	assert_true(weak.alive())
	weak.pos = Vector2.LEFT * 2.0
	for i: int in hit.active - 1 + hit.grind_min_ticks:
		m.combo.holding = true
		@warning_ignore("return_value_discarded")
		m.step(arena, false, Vector2.RIGHT)
		assert_true(heavy.alive())
		assert_true(weak.alive())
	@warning_ignore("return_value_discarded")
	m.step(arena, false, Vector2.RIGHT)
	assert_eq(m.combo.phase(), MeleeCombo.Phase.RECOVERY)
	assert_eq(arena.kills, 2)


func test_changing_one_weapon_value_changes_the_live_outcome() -> void:
	var row: MeleeTable = MeleeTable.weapon(&"katana")
	var riot: Fighter = _fighter(&"riot_cop")
	row.kills_human = false
	_click(PlayerMelee.new(row))
	assert_eq(riot.hp, riot.max_hp - row.hits[0].damage)
	row.kills_human = true
	row.vs_shield = &"through"
	_click(PlayerMelee.new(row))
	assert_false(riot.alive())
