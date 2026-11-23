extends GutTest


func test_pit_uses_the_real_hit_direction_and_weapon_on_each_contact() -> void:
	var roster: EnemyRoster = EnemyRoster.shipped(EnemyRoster.TABLE, true)
	var pit: EnemyPit = EnemyPit.new(roster, null)
	for id: StringName in [&"katana", &"plasma_sword", &"electro_baton", &"chainsaw", &"claw"]:
		var table: MeleeTable = MeleeTable.shipped() if id == &"claw" else MeleeTable.weapon(id)
		var c: MeleeCombo = MeleeCombo.new(table)
		c.press()
		var hit: MeleeHit = c.current()
		var e: EnemyAgent = pit.spawn(&"riot_cop", Vector2.RIGHT)
		e.hp = 70
		e.facing = Vector2.LEFT
		for i: int in hit.length() + hit.grind_min_ticks:
			c.step()
			if c.lands():
				pit.hurt(e, hit.damage, Vector2.RIGHT, c)
				if id == &"chainsaw" and c.ground < hit.grind_min_ticks:
					assert_true(e.alive())
		if id == &"katana":
			assert_eq(e.hp, 70.0)
			assert_gt(e.pos.x, 1.0)
			c.press()
			pit.hurt(e, hit.damage, Vector2.RIGHT, c)
			assert_false(e.alive())
		elif id == &"claw":
			assert_almost_eq(e.hp, 70.0 - hit.damage * e.arch.shield_front_mult, 0.00001)
		else:
			assert_false(e.alive(), String(id))


func test_pit_keeps_normal_weapon_damage_for_robots_and_the_sergeant() -> void:
	var pit: EnemyPit = EnemyPit.new(EnemyRoster.shipped(EnemyRoster.TABLE, true), null)
	var c: MeleeCombo = MeleeCombo.new(MeleeTable.weapon(&"katana"))
	c.press()
	for id: StringName in [&"sergeant_mulroney", &"robot_thug", &"shield_robot"]:
		var e: EnemyAgent = pit.spawn(id, Vector2.RIGHT)
		e.facing = Vector2.RIGHT
		e.hp = 60
		pit.hurt(e, c.current().damage, Vector2.RIGHT, c)
		assert_eq(e.hp, 60.0 - c.current().damage)
